@tool
class_name MatchmakingOverlay
extends Control
## Ecran de recherche de partie : les slots se remplissent un par un, puis
## "PARTIE TROUVEE" et on lance le match.

signal cancelled
signal ready_to_play

var mode: Dictionary = {}
var _slots := 6
var _t := 0.0
var _found := false
var _panel_rect := Rect2()
var _cancel: ChunkyButton
var _players: Array[Dictionary] = []
var _cols := 3
var _rows := 2
var _grid := Rect2()


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_cancel = ChunkyButton.new()
	_cancel.base_color = UiSkin.RED
	_cancel.title = "ANNULER"
	_cancel.title_size = 20
	_cancel.corner_radius = 13
	_cancel.lip = 8.0
	_cancel.pressed.connect(func(): Net.cancel_match(); cancelled.emit())
	add_child(_cancel)
	resized.connect(_layout)
	_layout()
	set_process(true)


func start(m: Dictionary) -> void:
	mode = m
	_slots = int(m.get("slots", 6))
	_found = false
	_t = 0.0
	_players.clear()
	Net.roster_updated.connect(_on_roster)
	Net.match_ready.connect(_on_match_ready)
	Net.find_match(m)
	modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 0.2)
	_layout()


func _on_roster(roster: Array) -> void:
	_players = []
	for e in roster:
		_players.append(e as Dictionary)
	queue_redraw()


func _on_match_ready(roster: Array) -> void:
	_on_roster(roster)
	_on_full()


func _exit_tree() -> void:
	if Net.roster_updated.is_connected(_on_roster):
		Net.roster_updated.disconnect(_on_roster)
	if Net.match_ready.is_connected(_on_match_ready):
		Net.match_ready.disconnect(_on_match_ready)


const CELL := Vector2(96, 94)
const GAP := Vector2(12, 26)


func _layout() -> void:
	# une ligne par equipe (3v3 -> 3 + 3, solo -> 2 lignes de 5)
	_rows = (1 if _slots <= 5 else 2)
	_cols = int(ceil(float(_slots) / float(_rows)))
	var grid_size := Vector2(
		float(_cols) * CELL.x + float(_cols - 1) * GAP.x,
		float(_rows) * CELL.y + float(_rows - 1) * GAP.y)

	var w := clampf(grid_size.x + 80.0, 420.0, maxf(size.x * 0.86, 420.0))
	var h := 118.0 + grid_size.y + 122.0
	_panel_rect = Rect2(Vector2((size.x - w) * 0.5, (size.y - h) * 0.5), Vector2(w, h))
	_grid = Rect2(_panel_rect.position + Vector2((w - grid_size.x) * 0.5, 112.0), grid_size)
	if _cancel:
		_cancel.size = Vector2(210, 58)
		_cancel.position = _panel_rect.position + Vector2((w - 210.0) * 0.5, h - 72.0)
	queue_redraw()


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _on_full() -> void:
	_found = true
	_cancel.visible = false
	var tw := create_tween()
	tw.tween_interval(0.9)
	tw.tween_callback(func(): ready_to_play.emit())


func _draw() -> void:
	var f := Painter.font(self)
	self.draw_rect(Rect2(Vector2.ZERO, size), Color(0.03, 0.01, 0.09, 0.78))

	Painter.card(self, _panel_rect, UiSkin.PANEL, 24, 6, 9.0)
	var col: Color = mode.get("color", UiSkin.PURPLE)
	var head := Rect2(_panel_rect.position + Vector2(6, 6), Vector2(_panel_rect.size.x - 12.0, 54.0))
	self.draw_style_box(UiSkin.box_top(col, 22), head)
	Icons.draw(self, str(mode.get("icon", "gem")), Rect2(head.position + Vector2(12, 11), Vector2(32, 32)), UiSkin.TEXT)
	Painter.text(self, f, Rect2(head.position + Vector2(52, 0), Vector2(head.size.x - 64.0, head.size.y)),
			"%s  -  %s" % [str(mode.get("name", "")), str(mode.get("map", ""))],
			20, UiSkin.TEXT, HORIZONTAL_ALIGNMENT_CENTER, 5)

	var title := ("PARTIE TROUVEE !" if _found else "RECHERCHE DE JOUEURS" + ".".repeat(1 + int(_t * 2.0) % 3))
	var tcol := (UiSkin.GOLD if _found else UiSkin.TEXT)
	Painter.text(self, f, Rect2(_panel_rect.position + Vector2(0, 66.0), Vector2(_panel_rect.size.x, 44.0)),
			title, 26, tcol, HORIZONTAL_ALIGNMENT_CENTER, 6)

	# slots joueurs : une ligne par equipe
	for i in _slots:
		var cx := _grid.position.x + float(i % _cols) * (CELL.x + GAP.x)
		var cy := _grid.position.y + float(i / _cols) * (CELL.y + GAP.y)
		var r := Rect2(Vector2(cx, cy), Vector2(CELL.x, CELL.y - 20.0))
		if i < _players.size():
			var p: Dictionary = _players[i]
			var pc: Color = (UiSkin.GOLD if bool(p.get("me", false)) else col)
			Painter.rr(self, r, pc.darkened(0.25), 16, 4, UiSkin.OUTLINE)
			Icons.draw(self, "brawler", r.grow(-16.0), UiSkin.TEXT)
			if bool(p.get("bot", false)):
				var bt := Rect2(r.position + Vector2(r.size.x - 30.0, -6.0), Vector2(32, 18))
				Painter.rr(self, bt, UiSkin.PANEL_LIGHT, 6, 3, UiSkin.OUTLINE)
				Painter.text(self, f, bt, "BOT", 10, UiSkin.TEXT_DIM, HORIZONTAL_ALIGNMENT_CENTER, 0)
			Painter.text(self, f, Rect2(Vector2(cx, cy + CELL.y - 22.0), Vector2(CELL.x, 20.0)),
					str(p.get("name", "")), 12, UiSkin.TEXT, HORIZONTAL_ALIGNMENT_CENTER, 3)
		else:
			Painter.rr(self, r, UiSkin.PANEL_DARK, 16, 3, UiSkin.OUTLINE)
			var dots := ".".repeat(1 + (int(_t * 3.0) + i) % 3)
			Painter.text(self, f, r, dots, 24, UiSkin.TEXT_DIM, HORIZONTAL_ALIGNMENT_CENTER, 0)

	# "VS" entre les deux equipes
	if _rows == 2 and _slots == 6:
		var vs := Rect2(Vector2(_grid.position.x, _grid.position.y + CELL.y - 2.0),
				Vector2(_grid.size.x, GAP.y + 4.0))
		Painter.text(self, f, vs, "VS", 18, UiSkin.GOLD, HORIZONTAL_ALIGNMENT_CENTER, 4)

	if not _found:
		var online := Net.is_online()
		var status := "EN LIGNE - recherche de vrais joueurs" if online else "HORS LIGNE - des bots completent"
		Painter.text(self, f, Rect2(Vector2(_panel_rect.position.x, _grid.position.y + _grid.size.y + 4.0),
				Vector2(_panel_rect.size.x, 22.0)),
				"%d / %d joueurs" % [_players.size(), _slots], 15, UiSkin.TEXT, HORIZONTAL_ALIGNMENT_CENTER, 0)
		Painter.text(self, f, Rect2(Vector2(_panel_rect.position.x, _grid.position.y + _grid.size.y + 24.0),
				Vector2(_panel_rect.size.x, 20.0)),
				status, 12, (UiSkin.GREEN if online else UiSkin.TEXT_DIM), HORIZONTAL_ALIGNMENT_CENTER, 0)
