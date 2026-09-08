extends Control
## Racine du jeu : gere le passage lobby <-> partie.
## Pour l'instant la partie est un ecran temoin, le lobby est la premiere brique.

const LOBBY_SCENE := preload("res://scenes/lobby/Lobby.tscn")
const ARENA_SCENE := preload("res://scenes/ArenaStub.tscn")

var _current: Node = null


func _ready() -> void:
	GameState.match_started.connect(_on_match_started)
	show_lobby()


func show_lobby() -> void:
	_swap(LOBBY_SCENE.instantiate())


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
