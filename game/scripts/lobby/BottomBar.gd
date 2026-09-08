@tool
class_name BottomBar
extends Control
## Bandeau du bas : passe de combat + quetes a gauche, carte d'evenement et
## gros bouton JOUER a droite (meme organisation que Brawl Stars).

signal play_pressed
signal quests_pressed
signal pass_pressed
signal event_pressed

const H := 92.0

var _play: ChunkyButton
var _quests: ChunkyButton
var _pass_hit: Button
var _event_hit: Button
var _pass_rect := Rect2()
var _event_rect := Rect2()


func _ready() -> void:
	_play = ChunkyButton.new()
	_play.base_color = UiSkin.GOLD
	_play.title = "JOUER"
	_play.title_size = 38
	_play.corner_radius = 20
	_play.lip = 10.0
	_play.shine = true
	_play.pressed.connect(func(): play_pressed.emit())
	add_child(_play)

	_quests = ChunkyButton.new()
	_quests.base_color = UiSkin.BLUE
	_quests.icon_kind = "quest"
	_quests.title = "QUETES"
	_quests.vertical = true
	_quests.title_size = 12
	_quests.corner_radius = 16
	_quests.lip = 8.0
	_quests.badge = 3
	_quests.pressed.connect(func(): quests_pressed.emit())
	add_child(_quests)

	_pass_hit = _hit()
	_pass_hit.pressed.connect(func(): pass_pressed.emit())
	_event_hit = _hit()
	_event_hit.pressed.connect(func(): event_pressed.emit())

	if not Engine.is_editor_hint():
		GameState.mode_selected.connect(func(_i: int): queue_redraw())
	resized.connect(_layout)
	_layout()
	set_process(not Engine.is_editor_hint())


func _hit() -> Button:
	var b := Button.new()
	b.flat = true
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	for s in ["normal", "hover", "pressed", "focus", "disabled"]:
		b.add_theme_stylebox_override(s, UiSkin.empty())
	add_child(b)
	return b


func _layout() -> void:
	_pass_rect = Rect2(Vector2(0, 6), Vector2(258, H - 12.0))
	_quests.size = Vector2(84, H - 12.0)
	_quests.position = Vector2(266, 6)
	var play_w := 268.0
	_play.size = Vector2(play_w, H)
	_play.position = Vector2(size.x - play_w, 0.0)
	var ev_w := clampf(size.x - play_w - 380.0, 260.0, 420.0)
	_event_rect = Rect2(Vector2(size.x - play_w - ev_w - 12.0, 6), Vector2(ev_w, H - 12.0))
	_pass_hit.position = _pass_rect.position
	_pass_hit.size = _pass_rect.size
	_event_hit.position = _event_rect.position
	_event_hit.size = _event_rect.size
	queue_redraw()


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var f := Painter.font(self)

	# --- passe de combat
	Painter.card(self, _pass_rect, UiSkin.PANEL_DARK, 16, 5, 6.0)
	var tick := Rect2(_pass_rect.position + Vector2(8, 12), Vector2(56, 56))
	Painter.rr(self, tick, UiSkin.GOLD, 12, 4, UiSkin.OUTLINE)
	Icons.draw(self, "ticket", tick.grow(-8.0), UiSkin.CREAM)
	Painter.text(self, f, Rect2(_pass_rect.position + Vector2(72, 8), Vector2(120, 24)),
			"PASSE", 16, UiSkin.GOLD, HORIZONTAL_ALIGNMENT_LEFT, 3)
	var lvl := Rect2(_pass_rect.position + Vector2(_pass_rect.size.x - 52.0, 10.0), Vector2(42, 34))
	Painter.rr(self, lvl, UiSkin.PANEL_LIGHT, 10, 4, UiSkin.OUTLINE)
	Painter.text(self, f, lvl, str(GameState.pass_level), 19, UiSkin.TEXT, HORIZONTAL_ALIGNMENT_CENTER, 3)
	Painter.bar(self, Rect2(_pass_rect.position + Vector2(72, 40), Vector2(_pass_rect.size.x - 84.0, 20.0)),
			GameState.pass_progress(), UiSkin.GOLD)
	Painter.text(self, f, Rect2(_pass_rect.position + Vector2(72, 39), Vector2(_pass_rect.size.x - 84.0, 22.0)),
			"%d / %d" % [GameState.pass_xp, GameState.pass_xp_needed], 12,
			UiSkin.TEXT, HORIZONTAL_ALIGNMENT_CENTER, 0)

	# --- carte d'evenement
	var m := GameState.current_mode()
	var col: Color = m.get("color", UiSkin.PURPLE)
	Painter.card(self, _event_rect, UiSkin.PANEL_DARK, 16, 5, 6.0)
	var tile := Rect2(_event_rect.position + Vector2(8, 10), Vector2(60, 60))
	Painter.rr(self, tile, col, 12, 4, UiSkin.OUTLINE)
	Icons.draw(self, str(m.get("icon", "gem")), tile.grow(-12.0), UiSkin.TEXT)
	var tx := tile.end.x + 10.0
	var tw2 := _event_rect.end.x - tx - 12.0
	Painter.text(self, f, Rect2(Vector2(tx, _event_rect.position.y + 8.0), Vector2(tw2, 26.0)),
			str(m.get("name", "")), 20, UiSkin.TEXT, HORIZONTAL_ALIGNMENT_LEFT, 4)
	Painter.text(self, f, Rect2(Vector2(tx, _event_rect.position.y + 33.0), Vector2(tw2, 22.0)),
			str(m.get("map", "")), 15, col.lightened(0.45), HORIZONTAL_ALIGNMENT_LEFT, 3)
	Icons.draw(self, "clock", Rect2(Vector2(tx, _event_rect.end.y - 26.0), Vector2(16, 16)), UiSkin.TEXT_DIM)
	Painter.text(self, f, Rect2(Vector2(tx + 20.0, _event_rect.end.y - 28.0), Vector2(tw2 - 20.0, 20.0)),
			"Nouveau mode dans " + GameState.format_timer(float(m.get("timer", 0.0))), 12,
			UiSkin.TEXT_DIM, HORIZONTAL_ALIGNMENT_LEFT, 0)
	if bool(m.get("special", false)):
		var tag := Rect2(Vector2(_event_rect.end.x - 74.0, _event_rect.position.y + 8.0), Vector2(64, 22))
		Painter.rr(self, tag, UiSkin.RED, 8, 3, UiSkin.OUTLINE)
		Painter.text(self, f, tag, "NOUVEAU", 11, UiSkin.TEXT, HORIZONTAL_ALIGNMENT_CENTER, 0)


func play_intro() -> void:
	for n in [_play, _quests]:
		n.modulate.a = 0.0
		n.scale = Vector2(0.8, 0.7)
		n.pivot_offset = n.size * 0.5
		var tw := create_tween()
		tw.tween_property(n, "modulate:a", 1.0, 0.25)
		tw.parallel().tween_property(n, "scale", Vector2.ONE, 0.45) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
