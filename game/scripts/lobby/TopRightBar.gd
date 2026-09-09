@tool
class_name TopRightBar
extends Control
## Coin haut-droit : le bandeau noir des monnaies + le bouton menu.

signal shop_shortcut(currency_id: String)
signal menu_pressed

const H := 50.0
const ENTRIES := [
	{"id": "power", "icon": "star"},
	{"id": "coins", "icon": "coin"},
	{"id": "gems", "icon": "gem"},
]

var _menu: ChunkyButton
var _hits: Array[Button] = []
var _shown := {}


func _ready() -> void:
	custom_minimum_size = Vector2(430, H)
	for e in ENTRIES:
		_shown[e["id"]] = float(GameState.currencies.get(e["id"], 0))
	_menu = ChunkyButton.new()
	_menu.base_color = UiSkin.PANEL_LIGHT
	_menu.icon_kind = "menu"
	_menu.icon_color = UiSkin.TEXT
	_menu.corner_radius = 11
	_menu.lip = 6.0
	_menu.badge = 4
	_menu.pressed.connect(func(): menu_pressed.emit())
	add_child(_menu)

	for i in ENTRIES.size():
		var b := Button.new()
		b.flat = true
		b.focus_mode = Control.FOCUS_NONE
		b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		for s in ["normal", "hover", "pressed", "focus", "disabled"]:
			b.add_theme_stylebox_override(s, UiSkin.empty())
		var id := str(ENTRIES[i]["id"])
		b.pressed.connect(func(): shop_shortcut.emit(id))
		add_child(b)
		_hits.append(b)

	if not Engine.is_editor_hint():
		GameState.currency_changed.connect(_on_changed)
	resized.connect(_layout)
	_layout()
	set_process(not Engine.is_editor_hint())


func _layout() -> void:
	var strip_w := size.x - 60.0
	var cw := strip_w / float(ENTRIES.size())
	for i in _hits.size():
		_hits[i].position = Vector2(float(i) * cw, 0.0)
		_hits[i].size = Vector2(cw, H)
	if _menu:
		_menu.size = Vector2(52, 50)
		_menu.position = Vector2(size.x - 52.0, 0.0)
	queue_redraw()


func _on_changed(id: String, value: int) -> void:
	if not _shown.has(id):
		return
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_method(func(v: float): _shown[id] = v; queue_redraw(),
			float(_shown[id]), float(value), 0.5)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var f := Painter.font(self)
	var strip := Rect2(Vector2.ZERO, Vector2(size.x - 60.0, H))
	Painter.card(self, strip, Color(0.04, 0.05, 0.11, 0.88), 14, 5, 5.0)
	var cw := strip.size.x / float(ENTRIES.size())
	for i in ENTRIES.size():
		var e: Dictionary = ENTRIES[i]
		var cell := Rect2(Vector2(float(i) * cw, 0.0), Vector2(cw, H))
		Icons.draw(self, str(e["icon"]), Rect2(cell.position + Vector2(10, 12), Vector2(26, 26)),
				UiSkin.currency_color(str(e["id"])))
		Painter.text(self, f, Rect2(cell.position + Vector2(42, 0), Vector2(cw - 48.0, H)),
				GameState.format_number(int(round(float(_shown.get(e["id"], 0.0))))), 19,
				UiSkin.TEXT, HORIZONTAL_ALIGNMENT_LEFT, 3)
		if i < ENTRIES.size() - 1:
			self.draw_line(Vector2(cell.end.x, 10.0), Vector2(cell.end.x, H - 10.0),
					Color(1, 1, 1, 0.12), 2.0)
