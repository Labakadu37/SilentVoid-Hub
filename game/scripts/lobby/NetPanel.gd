@tool
class_name NetPanel
extends Control
## Panneau multijoueur : se connecter a un serveur, voir son etat.
##
## Sans serveur le jeu reste jouable : les parties se remplissent de bots.

signal closed

const PREF_PATH := "user://server.txt"

var _panel := Rect2()
var _addr: LineEdit
var _connect: ChunkyButton
var _close: ChunkyButton
var _status := ""


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	_addr = LineEdit.new()
	_addr.text = _load_pref()
	_addr.placeholder_text = "adresse:port"
	_addr.alignment = HORIZONTAL_ALIGNMENT_CENTER
	_addr.add_theme_font_override("font", Painter.font(self))
	_addr.add_theme_font_size_override("font_size", 18)
	_addr.add_theme_color_override("font_color", UiSkin.TEXT)
	_addr.add_theme_stylebox_override("normal", UiSkin.box(UiSkin.PANEL_DARK, 12, 4, UiSkin.OUTLINE))
	_addr.add_theme_stylebox_override("focus", UiSkin.box(UiSkin.PANEL_DARK, 12, 4, UiSkin.GOLD))
	add_child(_addr)

	_connect = ChunkyButton.new()
	_connect.base_color = UiSkin.GREEN
	_connect.title_size = 19
	_connect.corner_radius = 16
	_connect.lip = 8.0
	_connect.pressed.connect(_toggle)
	add_child(_connect)

	_close = ChunkyButton.new()
	_close.base_color = UiSkin.PANEL_LIGHT
	_close.title = "FERMER"
	_close.title_size = 17
	_close.corner_radius = 16
	_close.lip = 8.0
	_close.pressed.connect(func(): closed.emit())
	add_child(_close)

	if not Engine.is_editor_hint():
		Net.state_changed.connect(func(_s: int): _refresh())
	resized.connect(_layout)
	_layout()
	_refresh()
	modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 0.15)


func _load_pref() -> String:
	if FileAccess.file_exists(PREF_PATH):
		var f := FileAccess.open(PREF_PATH, FileAccess.READ)
		if f:
			var t := f.get_as_text().strip_edges()
			f.close()
			if not t.is_empty():
				return t
	return "%s:%d" % [Net.DEFAULT_HOST, Net.DEFAULT_PORT]


func _save_pref(value: String) -> void:
	var f := FileAccess.open(PREF_PATH, FileAccess.WRITE)
	if f:
		f.store_string(value)
		f.close()


func _toggle() -> void:
	if Net.is_online():
		Net.disconnect_from_server()
		return
	var raw := _addr.text.strip_edges()
	var host := raw
	var port := Net.DEFAULT_PORT
	if raw.contains(":"):
		var parts := raw.rsplit(":", true, 1)
		host = parts[0]
		if parts[1].is_valid_int():
			port = int(parts[1])
	if host.is_empty():
		_status = "Adresse vide."
		queue_redraw()
		return
	_save_pref(raw)
	Net.connect_to_server(host, port)
	_refresh()


func _refresh() -> void:
	match Net.state:
		Net.State.ONLINE, Net.State.QUEUED:
			_status = "Connecte : tu joueras avec de vrais joueurs."
			_connect.title = "SE DECONNECTER"
			_connect.base_color = UiSkin.RED
		Net.State.CONNECTING:
			_status = "Connexion en cours..."
			_connect.title = "CONNEXION..."
			_connect.base_color = UiSkin.GOLD
		_:
			_status = Net.last_error if not Net.last_error.is_empty() \
				else "Hors ligne : les parties se remplissent de bots."
			_connect.title = "SE CONNECTER"
			_connect.base_color = UiSkin.GREEN
	queue_redraw()


func _layout() -> void:
	var w := minf(size.x * 0.62, 560.0)
	var h := 328.0
	_panel = Rect2(Vector2((size.x - w) * 0.5, (size.y - h) * 0.5), Vector2(w, h))
	_addr.position = _panel.position + Vector2(40, 112)
	_addr.size = Vector2(w - 80.0, 46)
	_connect.size = Vector2(w - 80.0, 56)
	_connect.position = _panel.position + Vector2(40, 176)
	_close.size = Vector2(160, 46)
	_close.position = _panel.position + Vector2((w - 160.0) * 0.5, h - 60.0)
	queue_redraw()


func _draw() -> void:
	var f := Painter.font(self)
	self.draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.03, 0.07, 0.72))
	Painter.card(self, _panel, UiSkin.PANEL, 22, 6, 8.0)
	Painter.text(self, f, Rect2(_panel.position + Vector2(0, 14), Vector2(_panel.size.x, 34.0)),
			"MULTIJOUEUR", 24, UiSkin.TEXT, HORIZONTAL_ALIGNMENT_CENTER, 6)
	var online := Net.is_online()
	Painter.text(self, f, Rect2(_panel.position + Vector2(20, 54), Vector2(_panel.size.x - 40.0, 22.0)),
			_status, 14, (UiSkin.GREEN if online else UiSkin.TEXT_DIM), HORIZONTAL_ALIGNMENT_CENTER, 0)
	Painter.text(self, f, Rect2(_panel.position + Vector2(20, 82), Vector2(_panel.size.x - 40.0, 22.0)),
			"Adresse du serveur", 13, UiSkin.TEXT_DIM, HORIZONTAL_ALIGNMENT_CENTER, 0)
	Painter.text(self, f, Rect2(_panel.position + Vector2(20, 244), Vector2(_panel.size.x - 40.0, 22.0)),
			"Heberger ton propre serveur : voir le README du projet", 12, UiSkin.TEXT_DIM, HORIZONTAL_ALIGNMENT_CENTER, 0)
