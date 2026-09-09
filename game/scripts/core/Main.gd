extends Control
## Racine du jeu : gere le passage lobby <-> partie.
## Pour l'instant la partie est un ecran temoin, le lobby est la premiere brique.

const LOBBY_PATH := "res://scenes/lobby/Lobby.tscn"
const ARENA_SCENE := preload("res://scenes/ArenaStub.tscn")

var _current: Node = null


func _ready() -> void:
	if _start_dedicated_server():
		return
	_auto_join()
	GameState.match_started.connect(_on_match_started)
	_boot()


## Ecran de chargement, puis le lobby.
func _boot() -> void:
	var loader := LoadingScreen.new()
	loader.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(loader)
	loader.begin(LOBBY_PATH)
	loader.finished.connect(func():
		# on instancie la scene reellement chargee par l'ecran de chargement,
		# sinon son travail est jete et la ressource reste en cache.
		var packed := loader.get_loaded_scene()
		loader.queue_free()
		_swap((packed if packed != null else load(LOBBY_PATH)).instantiate()))


## `godot --path game -- --join 192.168.1.20 [port]` rejoint un serveur au demarrage.
func _auto_join() -> void:
	var args := OS.get_cmdline_user_args()
	var i := args.find("--join")
	if i < 0 or i + 1 >= args.size():
		Net.auto_connect()   # cas normal : le joueur n'a rien a configurer
		return
	var host := str(args[i + 1])
	var port := Net.DEFAULT_PORT
	if i + 2 < args.size() and args[i + 2].is_valid_int():
		port = int(args[i + 2])
	Net.connect_to_server(host, port)


## `godot --path game -- --server [port]` demarre un serveur sans interface.
func _start_dedicated_server() -> bool:
	var args := OS.get_cmdline_user_args()
	if not args.has("--server"):
		return false
	var port := Net.DEFAULT_PORT
	var i := args.find("--server")
	if i >= 0 and i + 1 < args.size() and args[i + 1].is_valid_int():
		port = int(args[i + 1])
	if not Net.start_server(port):
		get_tree().quit(1)
		return true
	print("[SilentVoid] Serveur pret. Ctrl+C pour arreter.")
	return true


func show_lobby() -> void:
	_swap((load(LOBBY_PATH) as PackedScene).instantiate())


func _exit_tree() -> void:
	if _current and is_instance_valid(_current):
		_current.queue_free()


func _on_match_started(mode: Dictionary) -> void:
	var arena := ARENA_SCENE.instantiate() as ArenaStub
	_swap(arena)
	arena.setup(mode)
	arena.quit_requested.connect(show_lobby)


func _swap(node: Node) -> void:
	if _current and is_instance_valid(_current):
		_current.queue_free()
	_current = node
	add_child(node)
	if node is Control:
		(node as Control).set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
