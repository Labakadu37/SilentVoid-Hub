@tool
class_name NetPanel
extends Control
## Panneau multijoueur : se connecter a un serveur, voir son etat.
##
## Sans serveur le jeu reste jouable : les parties se remplissent de bots.

signal closed

var _panel := Rect2()
var _addr: LineEdit
var _connect: ChunkyButton
var _close: ChunkyButton



var _advanced := false
var _custom: ChunkyButton


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	_addr = LineEdit.new()
	_addr.text = Net.configured_server()
	_addr.placeholder_text = "adresse:port"
	_addr.alignment = HORIZONTAL_ALIGNMENT_CENTER
	_addr.add_theme_font_override("font", Painter.font(self))
	_addr.add_theme_font_size_override("font_size", 17)
	_addr.add_theme_color_override("font_color", UiSkin.TEXT)
	_addr.add_theme_stylebox_override("normal", UiSkin.box(UiSkin.PANEL_DARK, 12, 4, UiSkin.rim(UiSkin.PANEL)))
	_addr.add_theme_stylebox_override("focus", UiSkin.box(UiSkin.PANEL_DARK, 12, 4, UiSkin.GOLD))
	_addr.visible = false
	add_child(_addr)

	_connect = ChunkyButton.new()
	_connect.title = "SE CONNECTER"
	_connect.base_color = UiSkin.GREEN
	_connect.title_size = 18
	_connect.corner_radius = 13
	_connect.lip = 8.0
	_connect.visible = false
	_connect.pressed.connect(_apply_custom)
	add_child(_connect)

	_custom = ChunkyButton.new()
	_custom.title = "UTILISER MON SERVEUR"
	_custom.base_color = UiSkin.PANEL_LIGHT
	_custom.title_size = 15
	_custom.corner_radius = 12
	_custom.lip = 7.0
	_custom.pressed.connect(_toggle_advanced)
	add_child(_custom)

	_close = ChunkyButton.new()
	_close.base_color = UiSkin.RED
	_close.title = "FERMER"
	_close.title_size = 17
	_close.corner_radius = 13
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


func _toggle_advanced() -> void:
	_advanced = not _advanced
	_addr.visible = _advanced
	_connect.visible = _advanced
	_custom.title = "MASQUER" if _advanced else "UTILISER MON SERVEUR"
	_layout()


func _apply_custom() -> void:
	if Net.is_online():
		Net.disconnect_from_server()
		return
	Net.set_custom_server(_addr.text)
	Net.auto_connect()
	_refresh()


func _refresh() -> void:
	if _connect:
		_connect.title = "SE DECONNECTER" if Net.is_online() else "SE CONNECTER"
		_connect.base_color = UiSkin.RED if Net.is_online() else UiSkin.GREEN
	queue_redraw()


func _layout() -> void:
	var w := minf(size.x * 0.62, 560.0)
	var h := 300.0 if _advanced else 196.0
	_panel = Rect2(Vector2((size.x - w) * 0.5, (size.y - h) * 0.5), Vector2(w, h))
	_custom.size = Vector2(w - 80.0, 44)
	_custom.position = _panel.position + Vector2(40, 108)
	_addr.position = _panel.position + Vector2(40, 162)
	_addr.size = Vector2(w - 80.0, 44)
	_connect.size = Vector2(w - 80.0, 50)
	_connect.position = _panel.position + Vector2(40, 214)
	_close.size = Vector2(150, 44)
	_close.position = _panel.position + Vector2((w - 150.0) * 0.5, h - 56.0)
	queue_redraw()


func _draw() -> void:
	var f := Painter.font(self)
	self.draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.03, 0.07, 0.72))
	Painter.card(self, _panel, UiSkin.PANEL, 22, 6, 8.0)
	Painter.text(self, f, Rect2(_panel.position + Vector2(0, 14), Vector2(_panel.size.x, 32.0)),
			"MULTIJOUEUR", 23, UiSkin.TEXT, HORIZONTAL_ALIGNMENT_CENTER, 6)

	# pastille d'etat
	var online := Net.is_online()
	var connecting := Net.state == Net.State.CONNECTING
	var dot_col := UiSkin.GREEN if online else (UiSkin.GOLD if connecting else UiSkin.TEXT_DIM)
	var row := Rect2(_panel.position + Vector2(30, 52), Vector2(_panel.size.x - 60.0, 44))
	Painter.rr(self, row, UiSkin.PANEL_DARK, 14, 4, UiSkin.rim(UiSkin.PANEL))
	self.draw_circle(row.position + Vector2(24, row.size.y * 0.5), 10.0, UiSkin.OUTLINE)
	self.draw_circle(row.position + Vector2(24, row.size.y * 0.5), 7.0, dot_col)
	var label := "EN LIGNE" if online else ("CONNEXION..." if connecting else "HORS LIGNE")
	Painter.text(self, f, Rect2(row.position + Vector2(42, 2), Vector2(row.size.x - 52.0, 22.0)),
			label, 16, dot_col, HORIZONTAL_ALIGNMENT_LEFT, 3)
	var detail := "Tu joueras contre de vrais joueurs." if online \
		else ("Recherche du serveur..." if connecting \
		else "Les parties se remplissent de bots. Appuie sur JOUER, ca marche quand meme.")
	Painter.text(self, f, Rect2(row.position + Vector2(42, 21), Vector2(row.size.x - 52.0, 20.0)),
			detail, 12, UiSkin.TEXT_DIM, HORIZONTAL_ALIGNMENT_LEFT, 0)
