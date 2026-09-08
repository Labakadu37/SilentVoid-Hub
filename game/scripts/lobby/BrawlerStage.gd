@tool
class_name BrawlerStage
extends Control
## Le centre du lobby : le brawler sous les projecteurs, sa fiche au-dessus de
## la tete, les emplacements d'equipe de chaque cote, sa plaque de nom dessous.

signal team_slot_pressed(slot: int)
signal brawler_pressed

const FLOOR_RATIO := 0.76      # hauteur du tapis, calee sur le decor

var _char: CharacterView
var _left: ChunkyButton
var _right: ChunkyButton
var _slots: Array[ChunkyButton] = []
var _hit: Button
var _feet := 0.0
var _t := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_hit = Button.new()
	_hit.flat = true
	_hit.focus_mode = Control.FOCUS_NONE
	for s in ["normal", "hover", "pressed", "focus", "disabled"]:
		_hit.add_theme_stylebox_override(s, UiSkin.empty())
	_hit.pressed.connect(func(): brawler_pressed.emit())
	add_child(_hit)

	_char = CharacterView.new()
	add_child(_char)

	for i in 2:
		var s := ChunkyButton.new()
		s.base_color = Color(1, 1, 1, 0.16)
		s.icon_kind = "plus"
		s.icon_color = Color(1, 1, 1, 0.85)
		s.corner_radius = 14
		s.lip = 5.0
		var idx := i
		s.pressed.connect(func(): team_slot_pressed.emit(idx))
		add_child(s)
		_slots.append(s)

	_left = _arrow("left")
	_right = _arrow("right")
	_left.pressed.connect(func(): GameState.select_brawler(GameState.selected_brawler - 1))
	_right.pressed.connect(func(): GameState.select_brawler(GameState.selected_brawler + 1))

	if not Engine.is_editor_hint():
		GameState.brawler_selected.connect(_on_brawler_selected)
	resized.connect(_layout)
	_layout()
	_refresh()
	set_process(not Engine.is_editor_hint())


func _arrow(kind: String) -> ChunkyButton:
	var b := ChunkyButton.new()
	b.base_color = UiSkin.PANEL_LIGHT
	b.icon_kind = kind
	b.icon_color = UiSkin.GOLD
	b.corner_radius = 14
	b.lip = 6.0
	add_child(b)
	return b


func _cx() -> float:
	return size.x * 0.58


func _layout() -> void:
	_feet = size.y * FLOOR_RATIO
	var ch := size.y * 0.58
	var cw := ch * 0.78
	_char.size = Vector2(cw, ch)
	_char.position = Vector2(_cx() - cw * 0.5, _feet - ch)
	_hit.position = _char.position
	_hit.size = _char.size

	for i in _slots.size():
		var sx := _cx() + (-1.0 if i == 0 else 1.0) * (cw * 0.5 + 34.0) - 27.0
		_slots[i].size = Vector2(54, 54)
		_slots[i].position = Vector2(sx, _feet - ch * 0.52)

	var plate_w := 360.0
	_left.size = Vector2(46, 46)
	_right.size = Vector2(46, 46)
	_left.position = Vector2(_cx() - plate_w * 0.5 - 54.0, _feet + 12.0)
	_right.position = Vector2(_cx() + plate_w * 0.5 + 8.0, _feet + 12.0)
	queue_redraw()


func _refresh() -> void:
	var b := GameState.current_brawler()
	_char.data = b
	_char.locked = not bool(b.get("unlocked", true))
	queue_redraw()


func _on_brawler_selected(_index: int) -> void:
	_refresh()
	_char.play_swap()


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	var f := Painter.font(self)
	var b := GameState.current_brawler()
	var rarity: Color = b.get("rarity_color", UiSkin.GOLD)
	var cx := _cx()

	# ombre au sol
	Painter.ellipse(self, Vector2(cx, _feet + 4.0), Vector2(size.y * 0.12, size.y * 0.028),
			Color(0, 0, 0, 0.30))

	# --- fiche au-dessus de la tete
	var strip := Rect2(Vector2(cx - 150.0, _char.position.y - 46.0), Vector2(300, 38))
	Painter.card(self, strip, UiSkin.PANEL_DARK, 12, 4, 5.0)
	var rank := Rect2(strip.position + Vector2(5, 4), Vector2(30, 30))
	Painter.rr(self, rank, rarity, 8, 3, UiSkin.OUTLINE)
	Icons.draw(self, "brawler", rank.grow(-6.0), UiSkin.TEXT)
	Icons.draw(self, "trophy", Rect2(strip.position + Vector2(44, 9), Vector2(20, 20)), UiSkin.GOLD)
	Painter.text(self, f, Rect2(strip.position + Vector2(68, 0), Vector2(80, 38)),
			str(int(b.get("trophies", 0))), 18, UiSkin.TEXT, HORIZONTAL_ALIGNMENT_LEFT, 3)
	var pw := Rect2(strip.position + Vector2(strip.size.x - 78.0, 4.0), Vector2(34, 30))
	Painter.rr(self, pw, UiSkin.PURPLE, 8, 3, UiSkin.OUTLINE)
	Painter.text(self, f, pw, str(int(b.get("power", 1))), 17, UiSkin.TEXT, HORIZONTAL_ALIGNMENT_CENTER, 3)
	var sp := Rect2(strip.position + Vector2(strip.size.x - 38.0, 4.0), Vector2(33, 30))
	var has_sp := int(b.get("power", 1)) >= 9
	Painter.rr(self, sp, UiSkin.PANEL_LIGHT if has_sp else UiSkin.PANEL, 8, 3, UiSkin.OUTLINE)
	Icons.draw(self, "star", sp.grow(-6.0), UiSkin.GOLD if has_sp else UiSkin.PANEL_DARK)

	# --- plaque de nom
	var plate := Rect2(Vector2(cx - 180.0, _feet + 10.0), Vector2(360, 50))
	Painter.card(self, plate, UiSkin.PANEL_DARK, 14, 5, 6.0)
	Painter.text(self, f, Rect2(plate.position + Vector2(0, 1), Vector2(plate.size.x, 30.0)),
			str(b.get("name", "")), 25, UiSkin.TEXT, HORIZONTAL_ALIGNMENT_CENTER, 5)
	var sub := "%s  -  %s" % [str(b.get("rarity", "")), str(b.get("role", ""))]
	Painter.text(self, f, Rect2(plate.position + Vector2(0, 29), Vector2(plate.size.x, 18.0)),
			sub, 12, rarity, HORIZONTAL_ALIGNMENT_CENTER, 0)

	# --- perso verrouille : prix en gemmes
	if not bool(b.get("unlocked", true)):
		var buy := Rect2(Vector2(cx - 110.0, plate.end.y + 8.0), Vector2(220, 32))
		Painter.card(self, buy, UiSkin.GREEN, 12, 4, 5.0)
		Icons.draw(self, "gem", Rect2(buy.position + Vector2(52, 6), Vector2(20, 20)), UiSkin.TEXT)
		Painter.text(self, f, Rect2(buy.position + Vector2(20, 0), Vector2(220, 32)),
				"DEBLOQUER  %d" % int(b.get("price", 0)), 15, UiSkin.TEXT, HORIZONTAL_ALIGNMENT_CENTER, 3)
