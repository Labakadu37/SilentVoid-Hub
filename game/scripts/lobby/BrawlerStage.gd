@tool
class_name BrawlerStage
extends Control
## Zone centrale : le perso sur son estrade, sa plaque de nom, son niveau de
## puissance, et les fleches pour changer de perso.

var _char: CharacterView
var _left: ChunkyButton
var _right: ChunkyButton
var _floor_y := 0.0
var _t := 0.0


func _ready() -> void:
	_char = CharacterView.new()
	add_child(_char)

	_left = _make_arrow("left")
	_right = _make_arrow("right")
	_left.pressed.connect(func(): GameState.select_brawler(GameState.selected_brawler - 1))
	_right.pressed.connect(func(): GameState.select_brawler(GameState.selected_brawler + 1))

	if not Engine.is_editor_hint():
		GameState.brawler_selected.connect(_on_brawler_selected)
	resized.connect(_layout)
	_layout()
	_refresh()
	set_process(not Engine.is_editor_hint())


func _make_arrow(kind: String) -> ChunkyButton:
	var b := ChunkyButton.new()
	b.base_color = UiSkin.PANEL_LIGHT
	b.icon_kind = kind
	b.icon_color = UiSkin.GOLD
	b.corner_radius = 16
	b.lip = 6.0
	add_child(b)
	return b


func _layout() -> void:
	var cw := minf(size.x * 0.50, 320.0)
	var ch := maxf(size.y - 126.0, 140.0)
	_char.size = Vector2(cw, ch)
	_char.position = Vector2((size.x - cw) * 0.5, 0.0)
	_floor_y = ch - 6.0
	var by := ch * 0.40
	_left.size = Vector2(56, 56)
	_right.size = Vector2(56, 56)
	_left.position = Vector2(size.x * 0.5 - cw * 0.5 - 74.0, by)
	_right.position = Vector2(size.x * 0.5 + cw * 0.5 + 18.0, by)
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

	# estrade lumineuse
	var floor_y := _floor_y
	Painter.glow(self, Vector2(size.x * 0.5, floor_y), size.x * 0.26, Color(rarity, 0.45), 10)
	Painter.ellipse(self, Vector2(size.x * 0.5, floor_y), Vector2(size.x * 0.19, 26.0),
			rarity.darkened(0.45))
	Painter.ellipse(self, Vector2(size.x * 0.5, floor_y - 4.0), Vector2(size.x * 0.175, 23.0),
			rarity.lerp(UiSkin.PANEL, 0.35))

	# plaque de nom
	var plate := Rect2(Vector2(size.x * 0.5 - 165.0, size.y - 118.0), Vector2(330, 44))
	Painter.rr(self, plate, UiSkin.PANEL_DARK, 16, 4, UiSkin.OUTLINE)
	Painter.text(self, f, plate, str(b.get("name", "")), 30, UiSkin.TEXT, HORIZONTAL_ALIGNMENT_CENTER, 6)

	# rarete
	var rar := Rect2(plate.position + Vector2(plate.size.x * 0.5 - 90.0, -16.0), Vector2(180, 26))
	Painter.rr(self, rar, rarity, 10, 3, UiSkin.OUTLINE)
	Painter.text(self, f, rar, str(b.get("rarity", "")), 14, UiSkin.OUTLINE, HORIZONTAL_ALIGNMENT_CENTER, 0)

	var unlocked := bool(b.get("unlocked", true))
	var line := Rect2(Vector2(size.x * 0.5 - 165.0, plate.position.y + 50.0), Vector2(330, 30))
	if unlocked:
		# badge de puissance
		var pw := Rect2(line.position, Vector2(104, 30))
		Painter.rr(self, pw, UiSkin.GOLD, 10, 3, UiSkin.OUTLINE)
		Painter.text(self, f, pw, "PUISS. %d" % int(b.get("power", 1)), 15, UiSkin.OUTLINE, HORIZONTAL_ALIGNMENT_CENTER, 0)
		# trophees du perso
		var tr := Rect2(line.position + Vector2(114.0, 0.0), Vector2(120, 30))
		Painter.rr(self, tr, UiSkin.PANEL_DARK, 10, 3, UiSkin.OUTLINE)
		Icons.draw(self, "trophy", Rect2(tr.position + Vector2(6, 5), Vector2(20, 20)), UiSkin.GOLD)
		Painter.text(self, f, Rect2(tr.position + Vector2(28, 0), Vector2(86, 30)),
				str(int(b.get("trophies", 0))), 16, UiSkin.TEXT, HORIZONTAL_ALIGNMENT_LEFT, 3)
		# etoiles de puissance
		for i in 3:
			var sr := Rect2(line.position + Vector2(244.0 + float(i) * 30.0, 3.0), Vector2(24, 24))
			var on := int(b.get("power", 1)) >= 7 + i * 2
			Icons.draw(self, "star", sr, (UiSkin.GOLD if on else UiSkin.PANEL_LIGHT))
	else:
		var buy := Rect2(line.position, Vector2(330, 30))
		Painter.rr(self, buy, UiSkin.GREEN, 10, 3, UiSkin.OUTLINE)
		Icons.draw(self, "gem", Rect2(buy.position + Vector2(96, 4), Vector2(22, 22)), UiSkin.TEXT)
		Painter.text(self, f, Rect2(buy.position + Vector2(24, 0), Vector2(330, 30)),
				"DEBLOQUER   %d" % int(b.get("price", 0)), 16, UiSkin.TEXT, HORIZONTAL_ALIGNMENT_CENTER, 3)

	# accroche du perso
	Painter.text(self, f, Rect2(Vector2(size.x * 0.5 - 230.0, line.position.y + 34.0), Vector2(460, 18)),
			str(b.get("tagline", "")), 13, UiSkin.TEXT_DIM, HORIZONTAL_ALIGNMENT_CENTER, 0)
