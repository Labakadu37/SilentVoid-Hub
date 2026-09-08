extends Node
## Reseau du jeu : salon, file d'attente et remplissage par des bots.
##
## Trois facons de jouer, toutes gerees ici :
##   1. SERVEUR DEDIE   godot --path game -- --server [port]
##      Un processus sans interface qui heberge les parties.
##   2. CLIENT          le jeu se connecte a un serveur et cherche de vrais joueurs.
##   3. HORS LIGNE      pas de serveur joignable -> la partie se remplit de bots.
##
## Regle demandee : on attend de vrais humains, et si la file ne se remplit pas
## assez vite, des bots prennent le relais pour que la partie parte quand meme.

signal state_changed(state: int)
signal queue_updated(count: int, needed: int)
signal roster_updated(roster: Array)
signal match_ready(roster: Array)

enum State { OFFLINE, CONNECTING, ONLINE, QUEUED, IN_MATCH }

const DEFAULT_PORT := 8910
const DEFAULT_HOST := "127.0.0.1"
const MAX_CLIENTS := 64
## Delai avant que les bots completent la partie (secondes de recherche).
const BOT_FILL_AFTER := 5.0
## Temps entre deux bots ajoutes, pour que le remplissage reste lisible.
const BOT_STEP := 0.7

var state: State = State.OFFLINE
var peer: ENetMultiplayerPeer = null
var is_server := false
var last_error := ""

# --- cote serveur -------------------------------------------------------
var _players := {}          # peer_id -> {name, brawler}
var _queues := {}           # mode_id -> {slots, waiting: [peer_id], since: float}

# --- cote client / hors ligne -------------------------------------------
var _local_roster: Array = []
var _local_mode: Dictionary = {}
var _local_timer := 0.0
var _searching := false


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	set_process(true)


# ====================================================================== API

## Lance un serveur dedie (aucune interface). Retourne true si le port est pris.
func start_server(port: int = DEFAULT_PORT) -> bool:
	peer = ENetMultiplayerPeer.new()
	var err := peer.create_server(port, MAX_CLIENTS)
	if err != OK:
		last_error = "Impossible d'ouvrir le port %d (code %d)" % [port, err]
		push_error(last_error)
		peer = null
		return false
	multiplayer.multiplayer_peer = peer
	is_server = true
	_set_state(State.ONLINE)
	print("[Net] Serveur en ecoute sur le port %d" % port)
	return true


## Connecte le jeu a un serveur. L'echec n'est pas bloquant : on jouera hors ligne.
func connect_to_server(host: String = DEFAULT_HOST, port: int = DEFAULT_PORT) -> void:
	disconnect_from_server()
	peer = ENetMultiplayerPeer.new()
	var err := peer.create_client(host, port)
	if err != OK:
		last_error = "Connexion impossible a %s:%d" % [host, port]
		peer = null
		_set_state(State.OFFLINE)
		return
	multiplayer.multiplayer_peer = peer
	_set_state(State.CONNECTING)


func disconnect_from_server() -> void:
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer = null
	peer = null
	is_server = false
	if state != State.OFFLINE:
		_set_state(State.OFFLINE)


func is_online() -> bool:
	return state == State.ONLINE or state == State.QUEUED


## Demande une partie. Marche en ligne comme hors ligne.
func find_match(mode: Dictionary) -> void:
	_local_mode = mode
	_local_timer = 0.0
	_searching = true
	_local_roster = [_self_entry()]
	roster_updated.emit(_local_roster)
	queue_updated.emit(_local_roster.size(), int(mode.get("slots", 6)))
	if is_online():
		_set_state(State.QUEUED)
		_join_queue.rpc_id(1, str(mode.get("id", "gems")), int(mode.get("slots", 6)))


func cancel_match() -> void:
	_searching = false
	_local_roster.clear()
	if is_online():
		_leave_queue.rpc_id(1)
		_set_state(State.ONLINE)


func _self_entry() -> Dictionary:
	return {
		"name": GameState.player_name,
		"brawler": str(GameState.current_brawler().get("name", "VOID")),
		"bot": false,
		"me": true,
	}


# ====================================================================== boucle

func _process(delta: float) -> void:
	if is_server:
		_server_tick(delta)
	elif _searching:
		_offline_tick(delta)


## Hors ligne (ou en attendant que des humains arrivent) : les bots completent.
func _offline_tick(delta: float) -> void:
	var needed := int(_local_mode.get("slots", 6))
	if _local_roster.size() >= needed:
		return
	_local_timer += delta
	var humans := 0
	for p in _local_roster:
		if not bool(p.get("bot", false)):
			humans += 1
	# on laisse d'abord sa chance aux vrais joueurs, puis les bots prennent le relais
	var wait := BOT_FILL_AFTER if (is_online() and humans < needed) else 0.8
	if _local_timer < wait:
		return
	_local_timer = wait - BOT_STEP
	_local_roster.append(_make_bot())
	roster_updated.emit(_local_roster)
	queue_updated.emit(_local_roster.size(), needed)
	if _local_roster.size() >= needed:
		_searching = false
		match_ready.emit(_local_roster)


const BOT_NAMES := ["Kyro", "Mina", "Blaze", "Nox", "Pixel", "Sasha", "Ryu", "Wave", "Tako", "Vega"]

func _make_bot() -> Dictionary:
	var pool: Array = GameState.brawlers
	var b: Dictionary = pool[randi() % pool.size()]
	return {
		"name": BOT_NAMES[randi() % BOT_NAMES.size()] + str(randi() % 90 + 10),
		"brawler": str(b.get("name", "VOID")),
		"bot": true,
		"me": false,
	}


# ====================================================================== serveur

func _server_tick(delta: float) -> void:
	for mode_id in _queues.keys():
		var q: Dictionary = _queues[mode_id]
		q["since"] = float(q["since"]) + delta
		var waiting: Array = q["waiting"]
		var slots := int(q["slots"])
		if waiting.size() >= slots or (waiting.size() > 0 and float(q["since"]) >= BOT_FILL_AFTER):
			_form_match(str(mode_id), q)


func _form_match(mode_id: String, q: Dictionary) -> void:
	var waiting: Array = q["waiting"]
	var slots := int(q["slots"])
	var taken: Array = waiting.slice(0, mini(slots, waiting.size()))
	var roster: Array = []
	for pid in taken:
		var info: Dictionary = _players.get(pid, {})
		roster.append({
			"name": str(info.get("name", "Joueur")),
			"brawler": str(info.get("brawler", "VOID")),
			"bot": false, "peer": pid,
		})
	while roster.size() < slots:
		roster.append(_make_bot())

	for pid in taken:
		var personal: Array = []
		for entry in roster:
			var e := (entry as Dictionary).duplicate()
			e["me"] = (int(e.get("peer", 0)) == pid)
			personal.append(e)
		_match_formed.rpc_id(pid, personal)

	q["waiting"] = waiting.slice(taken.size())
	q["since"] = 0.0
	print("[Net] Partie formee sur '%s' : %d humains, %d bots" % [mode_id, taken.size(), slots - taken.size()])


func _on_peer_connected(id: int) -> void:
	if is_server:
		_players[id] = {"name": "Joueur %d" % id, "brawler": "VOID"}
		print("[Net] Joueur %d connecte (%d en ligne)" % [id, _players.size()])


func _on_peer_disconnected(id: int) -> void:
	if not is_server:
		return
	_players.erase(id)
	for mode_id in _queues.keys():
		var q: Dictionary = _queues[mode_id]
		var w: Array = q["waiting"]
		w.erase(id)
	print("[Net] Joueur %d deconnecte" % id)


func _on_connected() -> void:
	_set_state(State.ONLINE)
	_register.rpc_id(1, GameState.player_name, str(GameState.current_brawler().get("name", "VOID")))
	print("[Net] Connecte au serveur")


func _on_connection_failed() -> void:
	last_error = "Serveur injoignable : la partie se jouera avec des bots."
	disconnect_from_server()


func _on_server_disconnected() -> void:
	last_error = "Connexion au serveur perdue."
	disconnect_from_server()


func _set_state(s: State) -> void:
	if state == s:
		return
	state = s
	state_changed.emit(s)


# ====================================================================== RPC

@rpc("any_peer", "call_remote", "reliable")
func _register(pname: String, brawler: String) -> void:
	if not is_server:
		return
	var id := multiplayer.get_remote_sender_id()
	_players[id] = {"name": pname, "brawler": brawler}


@rpc("any_peer", "call_remote", "reliable")
func _join_queue(mode_id: String, slots: int) -> void:
	if not is_server:
		return
	var id := multiplayer.get_remote_sender_id()
	if not _queues.has(mode_id):
		_queues[mode_id] = {"slots": slots, "waiting": [], "since": 0.0}
	var q: Dictionary = _queues[mode_id]
	var w: Array = q["waiting"]
	if not w.has(id):
		w.append(id)
	_queue_size.rpc_id(id, w.size(), slots)


@rpc("any_peer", "call_remote", "reliable")
func _leave_queue() -> void:
	if not is_server:
		return
	var id := multiplayer.get_remote_sender_id()
	for mode_id in _queues.keys():
		var q: Dictionary = _queues[mode_id]
		var w: Array = q["waiting"]
		w.erase(id)


@rpc("authority", "call_remote", "reliable")
func _queue_size(count: int, needed: int) -> void:
	queue_updated.emit(count, needed)


@rpc("authority", "call_remote", "reliable")
func _match_formed(roster: Array) -> void:
	_searching = false
	_local_roster = roster
	_set_state(State.IN_MATCH)
	roster_updated.emit(roster)
	match_ready.emit(roster)
