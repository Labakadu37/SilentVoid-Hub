@tool
class_name PlayDock
extends Control
## Le gros bouton JOUER + le bouton "equipe", en bas a droite.

signal play_pressed
signal team_pressed

var _play: ChunkyButton
var _team: ChunkyButton


func _ready() -> void:
	_play = ChunkyButton.new()
	_play.base_color = UiSkin.GOLD
	_play.title = "JOUER"
	_play.title_size = 40
	_play.subtitle_size = 15
	_play.corner_radius = 22
	_play.lip = 10.0
	_play.shine = true
	_play.pressed.connect(func(): play_pressed.emit())
	add_child(_play)

	_team = ChunkyButton.new()
	_team.base_color = UiSkin.BLUE
	_team.icon_kind = "friends"
	_team.corner_radius = 20
	_team.lip = 9.0
	_team.pressed.connect(func(): team_pressed.emit())
	add_child(_team)

	if not Engine.is_editor_hint():
		GameState.mode_selected.connect(func(_i: int): _refresh())
	resized.connect(_layout)
	_layout()
	_refresh()
	_breathe()


func _layout() -> void:
	var th := size.y
	_team.size = Vector2(th, th)
	_team.position = Vector2(size.x - th, 0.0)
	_play.size = Vector2(size.x - th - 14.0, size.y)
	_play.position = Vector2.ZERO


func _refresh() -> void:
	_play.subtitle = str(GameState.current_mode().get("name", ""))


## Le bouton respire doucement pour attirer l'oeil, comme dans Brawl Stars.
func _breathe() -> void:
	if Engine.is_editor_hint():
		return
	var tw := create_tween().set_loops()
	tw.set_trans(Tween.TRANS_SINE)
	tw.tween_property(_play, "scale", Vector2(1.03, 1.03), 0.9)
	tw.tween_property(_play, "scale", Vector2.ONE, 0.9)
