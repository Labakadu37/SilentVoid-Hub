class_name ArenaStub
extends Control
## Ecran temoin de la partie. Le gameplay viendra ici (etape suivante) ;
## il sert deja a valider la boucle lobby -> matchmaking -> partie -> lobby.

signal quit_requested

var mode: Dictionary = {}
var _back: ChunkyButton
var _t := 0.0


func _ready() -> void:
	_back = ChunkyButton.new()
	_back.base_color = UiSkin.GOLD
	_back.title = "RETOUR AU LOBBY"
	_back.title_size = 22
	_back.corner_radius = 20
	_back.lip = 9.0
	_back.pressed.connect(func(): quit_requested.emit())
	add_child(_back)
	resized.connect(_layout)
	_layout()
	set_process(not Engine.is_editor_hint())


func setup(m: Dictionary) -> void:
	mode = m
	queue_redraw()


func _layout() -> void:
	if _back:
		_back.size = Vector2(300, 66)
		_back.position = Vector2((size.x - 300.0) * 0.5, size.y * 0.68)
	queue_redraw()


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	var f := Painter.font(self)
	var col: Color = mode.get("color", UiSkin.PURPLE)
	self.draw_rect(Rect2(Vector2.ZERO, size), UiSkin.BG_BOTTOM)
	Painter.glow(self, size * 0.5, size.y * 0.7, Color(col, 0.5))
	Painter.text(self, f, Rect2(Vector2(0, size.y * 0.30), Vector2(size.x, 60)),
			str(mode.get("name", "PARTIE")), 44, UiSkin.TEXT, HORIZONTAL_ALIGNMENT_CENTER, 8)
	Painter.text(self, f, Rect2(Vector2(0, size.y * 0.40), Vector2(size.x, 36)),
			str(mode.get("map", "")), 22, UiSkin.TEXT_DIM, HORIZONTAL_ALIGNMENT_CENTER, 4)
	var pulse := 0.6 + 0.4 * sin(_t * 2.4)
	Painter.text(self, f, Rect2(Vector2(0, size.y * 0.52), Vector2(size.x, 34)),
			"GAMEPLAY EN CONSTRUCTION", 20, Color(UiSkin.GOLD, pulse), HORIZONTAL_ALIGNMENT_CENTER, 5)
