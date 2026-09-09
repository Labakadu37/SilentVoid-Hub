@tool
class_name ChunkyButton
extends Button
## Bouton "Supercell" : face coloree, levre sombre dessous qui s'ecrase quand on
## appuie, reflet en haut, contour noir. Tout est dessine, aucune texture.

@export var base_color: Color = Color("3ddc84"):
	set(value):
		base_color = value
		queue_redraw()
@export var title: String = "":
	set(value):
		title = value
		queue_redraw()
@export var subtitle: String = "":
	set(value):
		subtitle = value
		queue_redraw()
@export var icon_kind: String = "":
	set(value):
		icon_kind = value
		queue_redraw()
@export var icon_color: Color = Color("ffffff"):
	set(value):
		icon_color = value
		queue_redraw()
@export var corner_radius: int = 12
@export var lip: float = 8.0
@export var title_size: int = 24
@export var subtitle_size: int = 14
@export var vertical: bool = false          # icone au-dessus du texte (nav du bas)
@export var badge: int = 0:
	set(value):
		badge = value
		queue_redraw()
@export var shine: bool = false             # balayage lumineux (bouton JOUER)

var _hover := false
var _shine_node: Control = null
var _shine_tween: Tween = null


func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	text = ""
	for s in ["normal", "hover", "pressed", "focus", "disabled"]:
		add_theme_stylebox_override(s, UiSkin.empty())
	resized.connect(_on_resized)
	mouse_entered.connect(func(): _hover = true; _pop(1.04); queue_redraw())
	mouse_exited.connect(func(): _hover = false; _pop(1.0); queue_redraw())
	button_down.connect(func(): _pop(0.96))
	button_up.connect(func(): _pop(1.04 if _hover else 1.0))
	_on_resized()
	if shine and not Engine.is_editor_hint():
		_setup_shine()


func _on_resized() -> void:
	pivot_offset = size * 0.5
	if _shine_node:
		_shine_node.size = Vector2(size.x, size.y - lip)
	queue_redraw()


func _pop(target: float) -> void:
	if Engine.is_editor_hint():
		return
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2.ONE * target, 0.14)


## Bande blanche oblique qui traverse le bouton en boucle.
func _setup_shine() -> void:
	_shine_node = Control.new()
	_shine_node.clip_contents = true
	_shine_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shine_node.size = Vector2(size.x, size.y - lip)
	add_child(_shine_node)
	var band := ColorRect.new()
	band.color = Color(1, 1, 1, 0.28)
	band.size = Vector2(46, size.y * 3.0)
	band.pivot_offset = band.size * 0.5
	band.rotation = deg_to_rad(20.0)
	band.position = Vector2(-120, -size.y)
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shine_node.add_child(band)
	# tween infini : on le garde pour pouvoir l'arreter, sinon il survit au noeud
	_shine_tween = create_tween().set_loops()
	_shine_tween.tween_property(band, "position:x", size.x + 120.0, 0.75).set_delay(1.8)
	_shine_tween.tween_callback(func(): band.position.x = -120.0)


func _exit_tree() -> void:
	if _shine_tween != null and _shine_tween.is_valid():
		_shine_tween.kill()
	_shine_tween = null


func _draw() -> void:
	var col := base_color if not disabled else base_color.darkened(0.4).lerp(Color("55507a"), 0.6)
	var face := Painter.chunky(self, Rect2(Vector2.ZERO, size), col, corner_radius, lip, button_pressed, _hover)
	var f := Painter.font(self)
	var ol := maxi(4, int(float(title_size) * 0.16))   # contour proportionnel au corps
	var pad := 12.0
	var content := Rect2(face.position + Vector2(pad, 0), face.size - Vector2(pad * 2.0, 0))

	if vertical:
		if not icon_kind.is_empty():
			var s := minf(content.size.x, content.size.y) * 0.52
			var ir := Rect2(content.position + Vector2((content.size.x - s) * 0.5, content.size.y * 0.10), Vector2(s, s))
			Icons.draw(self, icon_kind, ir, icon_color)
			Painter.text(self, f, Rect2(content.position + Vector2(0, content.size.y * 0.62),
					Vector2(content.size.x, content.size.y * 0.30)), title, title_size, UiSkin.TEXT,
					HORIZONTAL_ALIGNMENT_CENTER, 4, UiSkin.OUTLINE, 2.0)
		else:
			Painter.text(self, f, content, title, title_size, UiSkin.TEXT, HORIZONTAL_ALIGNMENT_CENTER, 4)
	else:
		var text_rect := content
		if not icon_kind.is_empty():
			var s := content.size.y * 0.56
			var centered := title.is_empty() and subtitle.is_empty()
			var ix := content.position.x + ((content.size.x - s) * 0.5 if centered else 2.0)
			var ir := Rect2(Vector2(ix, content.position.y + (content.size.y - s) * 0.5), Vector2(s, s))
			Icons.draw(self, icon_kind, ir, icon_color)
			if not centered:
				text_rect = Rect2(content.position + Vector2(s + 10.0, 0), content.size - Vector2(s + 10.0, 0))
		if subtitle.is_empty():
			Painter.text(self, f, text_rect, title, title_size, UiSkin.TEXT,
					HORIZONTAL_ALIGNMENT_CENTER, ol, UiSkin.OUTLINE, 3.0)
		else:
			Painter.text(self, f, Rect2(text_rect.position + Vector2(0, text_rect.size.y * 0.06),
					Vector2(text_rect.size.x, text_rect.size.y * 0.52)), title, title_size,
					UiSkin.TEXT, HORIZONTAL_ALIGNMENT_CENTER, ol, UiSkin.OUTLINE, 3.0)
			Painter.text(self, f, Rect2(text_rect.position + Vector2(0, text_rect.size.y * 0.56),
					Vector2(text_rect.size.x, text_rect.size.y * 0.36)), subtitle, subtitle_size,
					Color(1, 1, 1, 0.85), HORIZONTAL_ALIGNMENT_CENTER, 3)

	if badge > 0:
		var br := Rect2(Vector2(size.x - 26.0, -6.0), Vector2(30, 30))
		self.draw_circle(br.position + br.size * 0.5, 16.0, UiSkin.OUTLINE)
		self.draw_circle(br.position + br.size * 0.5, 13.0, UiSkin.RED)
		Painter.text(self, f, br, str(badge), 15, UiSkin.TEXT, HORIZONTAL_ALIGNMENT_CENTER, 0)
