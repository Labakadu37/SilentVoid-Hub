@tool
class_name CharacterView
extends Control
## Le perso du lobby, entierement dessine (pas de sprite a fournir).
## Le dessin est fait dans un repere "design" de 200 x 260 px, puis mis a
## l'echelle pour remplir le Control : ca reste net en 4K comme sur mobile.

const DW := 200.0
const DH := 260.0

@export var data: Dictionary = {}:
	set(value):
		data = value
		queue_redraw()
@export var idle_speed := 2.2
@export var locked := false:
	set(value):
		locked = value
		queue_redraw()

var _t := 0.0
var _blink := 0.0
var _entry := 1.0     # 0 -> 1 : animation d'apparition


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(not Engine.is_editor_hint())


func _process(delta: float) -> void:
	_t += delta
	_blink -= delta
	if _blink <= 0.0:
		_blink = randf_range(2.0, 5.0)
	queue_redraw()


## Petit rebond quand on change de perso.
func play_swap() -> void:
	_t = 0.0
	_entry = 0.0
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "_entry", 1.0, 0.35)


func _c(key: String, fallback: Color) -> Color:
	var v = data.get(key, fallback)
	return v if v is Color else fallback


# ------------------------------------------------------------------ dessin

func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var u := minf(size.x / DW, size.y / DH)
	var origin := Vector2((size.x - DW * u) * 0.5, size.y - DH * u)
	var bob := sin(_t * idle_speed) * 5.0
	var squash := 1.0 + sin(_t * idle_speed + PI) * 0.03
	var scale_in := lerpf(0.85, 1.0, clampf(_entry, 0.0, 1.5))

	# ombre au sol (elle ne suit pas le rebond : elle retrecit quand le perso monte)
	Painter.ellipse(self, origin + Vector2(DW * 0.5, DH - 8.0) * u,
			Vector2(64.0 - bob, 15.0 - bob * 0.2) * u, Color(0, 0, 0, 0.28))

	# tout le corps, dans le repere design
	var s := Vector2(u * scale_in, u * squash * scale_in)
	var o := origin + Vector2((DW * u - DW * s.x) * 0.5, DH * u - DH * s.y) + Vector2(0.0, bob * u)
	self.draw_set_transform(o, 0.0, s)

	var suit := _c("suit", UiSkin.PURPLE)
	var accent := _c("accent", UiSkin.GOLD)
	var skin_col := _c("skin", Color("f5c69a"))
	var hair := _c("hair", Color("2f2a3f"))
	if locked:
		suit = suit.lerp(Color("2a2450"), 0.75)
		accent = accent.lerp(Color("2a2450"), 0.75)
		skin_col = skin_col.lerp(Color("2a2450"), 0.75)
		hair = hair.lerp(Color("221d45"), 0.75)

	_legs(suit)
	_arm_back(suit, skin_col)
	_body(suit, accent)
	_arm_front(suit, skin_col)
	_head(skin_col, hair, accent)
	_weapon(accent, suit)

	self.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	if locked:
		var lr := Rect2(Vector2(size.x * 0.5 - 34.0, size.y * 0.42), Vector2(68, 68))
		Icons.draw(self, "lock", lr, UiSkin.GOLD)


func _rr(x1: float, y1: float, x2: float, y2: float, color: Color, radius: int) -> void:
	self.draw_style_box(UiSkin.box(color, radius, 4, UiSkin.OUTLINE), Rect2(x1, y1, x2 - x1, y2 - y1))


func _disc(c: Vector2, r: float, color: Color) -> void:
	self.draw_circle(c, r + 4.0, UiSkin.OUTLINE)
	self.draw_circle(c, r, color)


func _legs(suit: Color) -> void:
	var dark := suit.darkened(0.35)
	var swing := sin(_t * idle_speed) * 2.0
	_rr(74.0, 196.0 + swing, 94.0, 246.0, dark, 10)
	_rr(106.0, 196.0 - swing, 126.0, 246.0, dark, 10)
	_rr(68.0, 236.0 + swing, 96.0, 252.0, UiSkin.OUTLINE.lightened(0.15), 8)
	_rr(104.0, 236.0 - swing, 132.0, 252.0, UiSkin.OUTLINE.lightened(0.15), 8)


func _body(suit: Color, accent: Color) -> void:
	_rr(60.0, 126.0, 140.0, 208.0, suit, 26)
	# ceinture
	self.draw_style_box(UiSkin.box(accent, 6, 0), Rect2(62.0, 176.0, 76.0, 14.0))
	self.draw_style_box(UiSkin.box(accent.darkened(0.25), 4, 0), Rect2(92.0, 174.0, 16.0, 18.0))
	# plastron
	self.draw_colored_polygon(PackedVector2Array([
		Vector2(84, 128), Vector2(116, 128), Vector2(100, 162)]), suit.lightened(0.22))


func _arm_back(suit: Color, skin_col: Color) -> void:
	var sway := sin(_t * idle_speed + 0.6) * 3.0
	_rr(42.0, 136.0 + sway, 66.0, 190.0 + sway, suit.darkened(0.18), 12)
	_disc(Vector2(54.0, 194.0 + sway), 13.0, skin_col)


func _arm_front(suit: Color, skin_col: Color) -> void:
	var sway := sin(_t * idle_speed - 0.6) * 3.0
	_rr(134.0, 136.0 + sway, 158.0, 190.0 + sway, suit, 12)
	_disc(Vector2(146.0, 194.0 + sway), 13.0, skin_col)


func _weapon(accent: Color, suit: Color) -> void:
	var sway := sin(_t * idle_speed - 0.6) * 3.0
	var kind := str(data.get("weapon", "gun"))
	var steel := (Color("cbd5e1") if not locked else Color("3a3468"))
	match kind:
		"gun":
			_rr(140.0, 176.0 + sway, 194.0, 196.0 + sway, steel, 8)
			_disc(Vector2(192.0, 186.0 + sway), 13.0, accent)
		"hammer":
			_rr(154.0, 116.0 + sway, 166.0, 202.0 + sway, (Color("7c4a1e") if not locked else steel), 6)
			_rr(146.0, 96.0 + sway, 198.0, 136.0 + sway, steel, 10)
			self.draw_style_box(UiSkin.box(accent, 4, 0), Rect2(151.0, 104.0 + sway, 42.0, 8.0))
		"bow":
			self.draw_arc(Vector2(168.0, 160.0 + sway), 46.0, -PI * 0.55, PI * 0.55, 18, UiSkin.OUTLINE, 11.0)
			self.draw_arc(Vector2(168.0, 160.0 + sway), 46.0, -PI * 0.55, PI * 0.55, 18, accent, 7.0)
			self.draw_line(Vector2(192.0, 121.0 + sway), Vector2(192.0, 199.0 + sway), Color(1, 1, 1, 0.7), 3.0)
		"staff":
			_rr(152.0, 70.0 + sway, 164.0, 206.0 + sway, suit.darkened(0.4), 6)
			_disc(Vector2(158.0, 58.0 + sway), 24.0, accent)
			self.draw_circle(Vector2(151.0, 51.0 + sway), 8.0, Color(1, 1, 1, 0.65))
		_:  # "fist" : gros gants
			_disc(Vector2(150.0, 196.0 + sway), 20.0, accent)


func _head(skin_col: Color, hair: Color, accent: Color) -> void:
	var head := Vector2(100.0, 88.0)
	_disc(head, 46.0, skin_col)

	# yeux
	var look := sin(_t * 0.8) * 3.0
	var closed := _blink < 0.12
	for i in 2:
		var ec := head + Vector2(-15.0 + float(i) * 30.0, -2.0)
		if closed:
			self.draw_line(ec + Vector2(-11, 0), ec + Vector2(11, 0), UiSkin.OUTLINE, 5.0)
		else:
			self.draw_circle(ec, 15.0, UiSkin.OUTLINE)
			self.draw_circle(ec, 12.0, Color.WHITE)
			self.draw_circle(ec + Vector2(look, 2.0), 6.5, UiSkin.OUTLINE)
			self.draw_circle(ec + Vector2(look - 2.0, -1.0), 2.2, Color.WHITE)
	# sourcils
	self.draw_line(head + Vector2(-27, -22), head + Vector2(-6, -27), UiSkin.OUTLINE, 5.0)
	self.draw_line(head + Vector2(27, -22), head + Vector2(6, -27), UiSkin.OUTLINE, 5.0)
	# bouche
	self.draw_arc(head + Vector2(0, 14.0), 15.0, 0.25 * PI, 0.75 * PI, 12, UiSkin.OUTLINE, 5.0)

	match str(data.get("hat", "hair")):
		"cap":
			self.draw_arc(head, 46.0, PI, TAU, 22, hair, 26.0)
			self.draw_style_box(UiSkin.box(hair.darkened(0.2), 8, 3, UiSkin.OUTLINE), Rect2(head.x - 6.0, head.y - 40.0, 62.0, 16.0))
		"helmet":
			self.draw_arc(head, 48.0, PI, TAU, 22, hair.lightened(0.15), 26.0)
			self.draw_style_box(UiSkin.box(accent, 5, 0), Rect2(head.x - 4.0, head.y - 62.0, 8.0, 26.0))
		"hood":
			self.draw_arc(head, 52.0, PI * 0.86, TAU * 1.07, 26, hair, 30.0)
			self.draw_circle(head + Vector2(0, -46), 8.0, accent)
		"crown":
			self.draw_colored_polygon(PackedVector2Array([
				Vector2(head.x - 34, head.y - 34), Vector2(head.x - 24, head.y - 62),
				Vector2(head.x - 10, head.y - 44), Vector2(head.x, head.y - 70),
				Vector2(head.x + 10, head.y - 44), Vector2(head.x + 24, head.y - 62),
				Vector2(head.x + 34, head.y - 34)]), accent)
		_:
			self.draw_arc(head, 46.0, PI * 0.95, TAU * 1.05, 24, hair, 24.0)
			self.draw_circle(head + Vector2(-30, -36), 13.0, hair)
			self.draw_circle(head + Vector2(30, -36), 13.0, hair)
