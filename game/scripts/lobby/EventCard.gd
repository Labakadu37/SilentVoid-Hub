@tool
class_name EventCard
extends Button
## Une carte d'evenement de la colonne de gauche (mode + map + timer + recompense).

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
	custom_minimum_size = Vector2(280, 104)
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

	Painter.rr(self, r, UiSkin.PANEL, 18, 4, UiSkin.OUTLINE)
	if selected:
		var pulse := 0.5 + 0.5 * sin(_t * 3.2)
		Painter.rr(self, r, Color(0, 0, 0, 0.0), 18, 4, UiSkin.GOLD.lerp(Color.WHITE, pulse * 0.4))

	# bandeau de mode
	var head := Rect2(Vector2(4, 4), Vector2(size.x - 8.0, 34.0))
	self.draw_style_box(UiSkin.box_top(col, 14), head)
	Icons.draw(self, str(mode.get("icon", "gem")), Rect2(head.position + Vector2(6, 4), Vector2(26, 26)), UiSkin.TEXT)
	Painter.text(self, f, Rect2(head.position + Vector2(38, 0), Vector2(head.size.x - 44.0, head.size.y)),
			str(mode.get("name", "")), 15, UiSkin.TEXT, HORIZONTAL_ALIGNMENT_LEFT, 4)

	# apercu de map stylise
	var prev := Rect2(Vector2(8, 42), Vector2(78, size.y - 50.0))
	Painter.rr(self, prev, col.darkened(0.55), 12, 3, UiSkin.OUTLINE)
	_draw_mini_map(prev, col)

	var x := prev.position.x + prev.size.x + 10.0
	var w := size.x - x - 10.0
	Painter.text(self, f, Rect2(Vector2(x, 42.0), Vector2(w, 20.0)), str(mode.get("map", "")), 16,
			UiSkin.TEXT, HORIZONTAL_ALIGNMENT_LEFT, 4)

	# equipe + recompense
	var tag := Rect2(Vector2(x, 64.0), Vector2(46, 20))
	Painter.rr(self, tag, col, 8, 2, UiSkin.OUTLINE)
	Painter.text(self, f, tag, str(mode.get("team", "3v3")), 12, UiSkin.TEXT, HORIZONTAL_ALIGNMENT_CENTER, 0)
	if bool(mode.get("special", false)):
		var sp := Rect2(Vector2(x + 52.0, 64.0), Vector2(maxf(w - 52.0, 10.0), 20.0))
		Painter.rr(self, sp, UiSkin.GOLD, 8, 2, UiSkin.OUTLINE)
		Painter.text(self, f, sp, str(mode.get("reward", "")), 12, UiSkin.OUTLINE, HORIZONTAL_ALIGNMENT_CENTER, 0)

	# compte a rebours
	Icons.draw(self, "clock", Rect2(Vector2(x, size.y - 20.0), Vector2(15, 15)), UiSkin.TEXT_DIM)
	Painter.text(self, f, Rect2(Vector2(x + 19.0, size.y - 22.0), Vector2(w - 19.0, 18.0)),
			GameState.format_timer(float(mode.get("timer", 0.0))), 12, UiSkin.TEXT_DIM,
			HORIZONTAL_ALIGNMENT_LEFT, 0)


## Petite vignette : des blocs facon plan de map, differents selon le mode.
func _draw_mini_map(r: Rect2, col: Color) -> void:
	var seed_val := int(str(mode.get("id", "x")).hash())
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_val
	for i in 7:
		var w := rng.randf_range(0.14, 0.34)
		var h := rng.randf_range(0.10, 0.26)
		var px := rng.randf_range(0.06, 0.94 - w)
		var py := rng.randf_range(0.08, 0.92 - h)
		self.draw_rect(Rect2(r.position + Vector2(px * r.size.x, py * r.size.y),
				Vector2(w * r.size.x, h * r.size.y)), col.lerp(Color.WHITE, 0.18 + 0.06 * float(i % 3)))
	Icons.draw(self, str(mode.get("icon", "gem")),
			Rect2(r.position + r.size * 0.5 - Vector2(14, 14), Vector2(28, 28)), UiSkin.TEXT)
