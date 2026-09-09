@tool
class_name IconTab
extends Button
## Onglet lateral : une tuile d'icone en relief posee sur une plaque sombre,
## avec le libelle en dessous.
##
## C'est volontairement different d'un ChunkyButton : dans Brawl Stars les
## onglets des bords ne sont pas des blocs colores identiques, c'est l'icone qui
## porte la couleur et le libelle repose sur une plaque neutre. Varier les
## formes est ce qui enleve l'effet "grille de boutons generes".

@export var accent: Color = Color("9b5cf0"):
	set(value):
		accent = value
		queue_redraw()
@export var label: String = "":
	set(value):
		label = value
		queue_redraw()
@export var icon_kind: String = "":
	set(value):
		icon_kind = value
		queue_redraw()
@export var badge: int = 0:
	set(value):
		badge = value
		queue_redraw()
@export var compact := false

var _hover := false


func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	text = ""
	for s in ["normal", "hover", "pressed", "focus", "disabled"]:
		add_theme_stylebox_override(s, UiSkin.empty())
	resized.connect(func(): pivot_offset = size * 0.5)
	mouse_entered.connect(func(): _hover = true; _pop(1.06))
	mouse_exited.connect(func(): _hover = false; _pop(1.0))
	button_down.connect(func(): _pop(0.95))
	button_up.connect(func(): _pop(1.0))
	pivot_offset = size * 0.5


func _pop(target: float) -> void:
	if Engine.is_editor_hint():
		return
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2.ONE * target, 0.14)


func _draw() -> void:
	var f := Painter.font(self)
	var press := 3.0 if button_pressed else 0.0
	var lbl_h := 20.0 if compact else 22.0

	# plaque sombre translucide, juste a la largeur du texte
	var pw := minf(size.x, Painter.text_width(f, label, 13 if compact else 14) + 22.0)
	var plate := Rect2(Vector2((size.x - pw) * 0.5, size.y - lbl_h - 2.0), Vector2(pw, lbl_h + 2.0))
	Painter.rr(self, plate, Color(0.05, 0.06, 0.12, 0.72), int(lbl_h * 0.45), 3,
			Color(0.02, 0.03, 0.07, 0.85))
	Painter.text(self, f, plate, label, 13 if compact else 14, UiSkin.TEXT,
			HORIZONTAL_ALIGNMENT_CENTER, 4)

	# tuile d'icone, plus large que haute, posee au-dessus de la plaque
	var tile_h := size.y - lbl_h - 10.0
	var tile_w := minf(size.x - 8.0, tile_h * 1.25)
	var tile := Rect2(Vector2((size.x - tile_w) * 0.5, press), Vector2(tile_w, tile_h))
	var col := accent.lightened(0.10) if _hover else accent
	Painter.shadow(self, tile, 11, 6.0, 0.32)
	Painter.rr(self, tile, UiSkin.rim(col), 11, 0)
	Painter.vgrad(self, tile.grow(-4.0), col, 8, 0.30, 0.20)
	self.draw_style_box(UiSkin.box_top(Color(1, 1, 1, 0.40), 8),
			Rect2(tile.position + Vector2(7.0, 5.0), Vector2(tile.size.x - 14.0, 3.0)))
	if not icon_kind.is_empty():
		var s := minf(tile.size.x, tile.size.y) * 0.74
		Icons.draw(self, icon_kind,
				Rect2(tile.position + (tile.size - Vector2(s, s)) * 0.5, Vector2(s, s)), UiSkin.TEXT)

	if badge > 0:
		var c := Vector2(size.x - 12.0, 4.0)
		self.draw_circle(c, 15.0, UiSkin.rim(UiSkin.RED))
		self.draw_circle(c, 12.0, UiSkin.RED)
		self.draw_circle(c + Vector2(0, -4), 8.0, Color(1, 1, 1, 0.22))
		Painter.text(self, f, Rect2(c - Vector2(15, 15), Vector2(30, 30)), str(badge), 14,
				UiSkin.TEXT, HORIZONTAL_ALIGNMENT_CENTER, 0)
