@tool
class_name EventCard
extends Button
## Une carte d'evenement : grosse tuile d'icone a gauche, mode + map + timer a droite.

signal card_selected(index: int)

var mode_index := 0
var mode: Dictionary = {}
var selected := false:
	set(value):
		if selected == value:
			return
		selected = value
		_animate_selection()
		queue_redraw()

var _t := 0.0


func _ready() -> void:
	custom_minimum_size = Vector2(280, 108)
	focus_mode = Control.FOCUS_NONE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	text = ""
	for s in ["normal", "hover", "pressed", "focus", "disabled"]:
		add_theme_stylebox_override(s, UiSkin.empty())
	resized.connect(func(): pivot_offset = Vector2(0.0, size.y * 0.5))
	pressed.connect(func(): card_selected.emit(mode_index))
	pivot_offset = Vector2(0.0, size.y * 0.5)
	set_process(not Engine.is_editor_hint())


func setup(index: int, data: Dictionary) -> void:
	mode_index = index
	mode = data
	queue_redraw()


func _animate_selection() -> void:
	if Engine.is_editor_hint():
		return
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2.ONE * (1.05 if selected else 1.0), 0.22)


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	if mode.is_empty():
		return
	var f := Painter.font(self)
	var col: Color = mode.get("color", UiSkin.PURPLE)
	var r := Rect2(Vector2.ZERO, size)

	Painter.card(self, r, UiSkin.PANEL if not selected else UiSkin.PANEL_LIGHT, 18, 5, 6.0)
	if selected:
		var pulse := 0.5 + 0.5 * sin(_t * 3.0)
		Painter.rr(self, r.grow(3.0), Color(0, 0, 0, 0.0), 21, 5,
				UiSkin.GOLD.lerp(Color.WHITE, pulse * 0.55))

	# tuile d'icone
	var side := size.y - 22.0
	var tile := Rect2(Vector2(11, 11), Vector2(side, side))
	Painter.rr(self, tile, col, 14, 4, UiSkin.OUTLINE)
	self.draw_style_box(UiSkin.box_top(Color(1, 1, 1, 0.18), 10),
			Rect2(tile.position + Vector2(5, 4), Vector2(tile.size.x - 10.0, tile.size.y * 0.40)))
	Icons.draw(self, str(mode.get("icon", "gem")), tile.grow(-17.0), UiSkin.TEXT)

	var x := tile.position.x + tile.size.x + 12.0
	var w := size.x - x - 12.0

	Painter.text(self, f, Rect2(Vector2(x, 12.0), Vector2(w, 17.0)), str(mode.get("name", "")),
			13, col.lightened(0.45), HORIZONTAL_ALIGNMENT_LEFT, 3)
	Painter.text(self, f, Rect2(Vector2(x, 29.0), Vector2(w, 26.0)), str(mode.get("map", "")),
			20, UiSkin.TEXT, HORIZONTAL_ALIGNMENT_LEFT, 4)

	var badge := Rect2(Vector2(x, size.y - 36.0), Vector2(50, 23))
	Painter.rr(self, badge, col, 8, 3, UiSkin.OUTLINE)
	Painter.text(self, f, badge, str(mode.get("team", "3v3")), 12, UiSkin.TEXT, HORIZONTAL_ALIGNMENT_CENTER, 0)
	Icons.draw(self, "clock", Rect2(Vector2(x + 58.0, size.y - 34.0), Vector2(18, 18)), UiSkin.TEXT_DIM)
	Painter.text(self, f, Rect2(Vector2(x + 80.0, size.y - 36.0), Vector2(w - 80.0, 23.0)),
			GameState.format_timer(float(mode.get("timer", 0.0))), 13, UiSkin.TEXT_DIM,
			HORIZONTAL_ALIGNMENT_LEFT, 0)

	if bool(mode.get("special", false)):
		var st := Rect2(Vector2(size.x - 38.0, 8.0), Vector2(26, 26))
		Icons.draw(self, "star", st, UiSkin.GOLD)
