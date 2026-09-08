extends Node
## Test de bout en bout du reseau, sans interface.
##
##   godot --headless --path game res://scenes/dev/NetSmokeTest.tscn -- --join 127.0.0.1 --as Alice
##
## Le client se connecte, entre en file d'attente et affiche la composition de
## la partie des qu'elle est formee. Sert de verification rapide du matchmaking.

var _elapsed := 0.0


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var i := args.find("--as")
	if i >= 0 and i + 1 < args.size():
		GameState.player_name = str(args[i + 1])

	var j := args.find("--join")
	if j >= 0 and j + 1 < args.size():
		var port := Net.DEFAULT_PORT
		if j + 2 < args.size() and args[j + 2].is_valid_int():
			port = int(args[j + 2])
		Net.connect_to_server(str(args[j + 1]), port)

	Net.match_ready.connect(_on_match_ready)
	Net.state_changed.connect(func(s: int): print("[%s] etat reseau -> %d" % [GameState.player_name, s]))
	# on laisse une seconde a la connexion avant de chercher une partie
	await get_tree().create_timer(1.0).timeout
	print("[%s] recherche d'une partie (en ligne: %s)" % [GameState.player_name, Net.is_online()])
	Net.find_match(GameState.current_mode())


func _on_match_ready(roster: Array) -> void:
	var humans := 0
	var bots := 0
	var names: Array[String] = []
	for e in roster:
		var d := e as Dictionary
		if bool(d.get("bot", false)):
			bots += 1
		else:
			humans += 1
		names.append("%s%s" % [str(d.get("name", "?")), ("(bot)" if bool(d.get("bot", false)) else "")])
	print("[%s] PARTIE TROUVEE : %d humains + %d bots -> %s" % [
		GameState.player_name, humans, bots, ", ".join(names)])
	await get_tree().create_timer(0.4).timeout
	get_tree().quit(0)


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed > 25.0:
		print("[%s] ECHEC : aucune partie formee en 25 s" % GameState.player_name)
		get_tree().quit(2)
