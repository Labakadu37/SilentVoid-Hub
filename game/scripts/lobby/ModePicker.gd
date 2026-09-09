@tool
class_name ModePicker
extends Control
## Popup de choix du mode de jeu, ouvert depuis la carte d'evenement du bas.

signal closed

var _panel := Rect2()
var _close: ChunkyButton
var _cards: Array[EventCard] = []
var _list: VBoxContainer


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 10)
	add_child(_list)

	for i in GameState.modes.size():
		var card := EventCard.new()
		_list.add_child(card)
		card.setup(i, GameState.modes[i])
		card.selected = (i == GameState.selected_mode)
		card.card_selected.connect(_on_pick)
		_cards.append(card)

	_close = ChunkyButton.new()
	_close.base_color = UiSkin.GREEN
	_close.title = "CHOISIR CE MODE"
	_close.title_size = 18
	_close.corner_radius = 13
	_close.lip = 8.0
	_close.pressed.connect(func(): closed.emit())
	add_child(_close)

	resized.connect(_layout)
	_layout()
	modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 0.15)


func _on_pick(index: int) -> void:
	GameState.select_mode(index)
	for c in _cards:
		c.selected = (c.mode_index == index)
	queue_redraw()


func _layout() -> void:
	var w := minf(size.x * 0.52, 440.0)
	var rows := float(_cards.size())
	var h := 66.0 + rows * 108.0 + (rows - 1.0) * 10.0 + 178.0
	_panel = Rect2(Vector2((size.x - w) * 0.5, (size.y - h) * 0.5), Vector2(w, h))
	_list.position = _panel.position + Vector2(16, 58)
	_list.size = Vector2(_panel.size.x - 32.0, rows * 108.0 + (rows - 1.0) * 10.0)
	if _close:
		_close.size = Vector2(240, 54)
		_close.position = _panel.position + Vector2((w - 240.0) * 0.5, h - 68.0)
	queue_redraw()


func _draw() -> void:
	var f := Painter.font(self)
	self.draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.03, 0.07, 0.72))
	Painter.card(self, _panel, UiSkin.PANEL, 22, 6, 8.0)
	Painter.text(self, f, Rect2(_panel.position + Vector2(0, 12), Vector2(_panel.size.x, 34.0)),
			"MODES DE JEU", 24, UiSkin.TEXT, HORIZONTAL_ALIGNMENT_CENTER, 6)

	# le but du mode selectionne : c'est ce qui distingue nos modes
	var m := GameState.current_mode()
	var col: Color = m.get("color", UiSkin.CYAN)
	var box := Rect2(_list.position + Vector2(0, _list.size.y + 12.0), Vector2(_list.size.x, 96))
	Painter.rr(self, box, UiSkin.PANEL_DARK, 16, 4, UiSkin.rim(col))
	Painter.text(self, f, Rect2(box.position + Vector2(12, 8), Vector2(box.size.x - 24.0, 20.0)),
			str(m.get("goal", "")), 13, col.lightened(0.35), HORIZONTAL_ALIGNMENT_CENTER, 3)
	_wrapped(f, str(m.get("rules", "")), Rect2(box.position + Vector2(14, 30),
			Vector2(box.size.x - 28.0, 60.0)), 12)


## Petit retour a la ligne maison (Painter.text dessine une seule ligne).
func _wrapped(f: Font, txt: String, rect: Rect2, fsize: int) -> void:
	var words := txt.split(" ", false)
	var line := ""
	var y := 0.0
	var lh := float(fsize) + 4.0
	for w in words:
		var test := line + (" " if not line.is_empty() else "") + w
		if Painter.text_width(f, test, fsize) > rect.size.x and not line.is_empty():
			Painter.text(self, f, Rect2(rect.position + Vector2(0, y), Vector2(rect.size.x, lh)),
					line, fsize, UiSkin.TEXT_DIM, HORIZONTAL_ALIGNMENT_CENTER, 0)
			y += lh
			line = w
			if y + lh > rect.size.y:
				return
		else:
			line = test
	if not line.is_empty():
		Painter.text(self, f, Rect2(rect.position + Vector2(0, y), Vector2(rect.size.x, lh)),
				line, fsize, UiSkin.TEXT_DIM, HORIZONTAL_ALIGNMENT_CENTER, 0)
