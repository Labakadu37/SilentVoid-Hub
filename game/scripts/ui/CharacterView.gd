@tool
class_name CharacterView
extends Control
## Le brawler du lobby, entierement dessine (pas de sprite a fournir).
##
## Le dessin est fait dans un repere "design" de 200 x 260 px, puis mis a
## l'echelle pour remplir le Control : ca reste net en 4K comme sur mobile.
## L'ordre des couches : cape -> jambes -> bras arriere -> torse -> bras avant
## -> tete -> arme. Chaque piece est cerclee de noir, comme chez Supercell.

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


## Petit rebond quand on change de brawler.
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

	var s := Vector2(u * scale_in, u * squash * scale_in)
	var o := origin + Vector2((DW * u - DW * s.x) * 0.5, DH * u - DH * s.y) + Vector2(0.0, bob * u)
	self.draw_set_transform(o, 0.0, s)

	var suit := _c("suit", UiSkin.PURPLE)
	var accent := _c("accent", UiSkin.GOLD)
	var skin_col := _c("skin", Color("f5c69a"))
	var hair := _c("hair", Color("2f2a3f"))
	if locked:
		suit = suit.lerp(Color("2b2f4a"), 0.78)
		accent = accent.lerp(Color("2b2f4a"), 0.78)
		skin_col = skin_col.lerp(Color("2b2f4a"), 0.78)
		hair = hair.lerp(Color("22253d"), 0.78)

	if bool(data.get("cape", false)):
		_cape(suit, accent)
	_legs(suit)
	_arm_back(suit, skin_col)
	_body(suit, accent)
	_arm_front(suit, skin_col)
	_head(skin_col, hair, accent)
	_weapon(accent, suit)

	self.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	if locked:
		var lr := Rect2(Vector2(size.x * 0.5 - 36.0, size.y * 0.40), Vector2(72, 72))
		Icons.draw(self, "lock", lr, UiSkin.GOLD)


func _rr(x1: float, y1: float, x2: float, y2: float, color: Color, radius: int) -> void:
	self.draw_style_box(UiSkin.box(color, radius, 5, UiSkin.OUTLINE), Rect2(x1, y1, x2 - x1, y2 - y1))


func _disc(c: Vector2, r: float, color: Color) -> void:
	self.draw_circle(c, r + 5.0, UiSkin.OUTLINE)
	self.draw_circle(c, r, color)


## Cape qui ondule derriere le brawler.
func _cape(suit: Color, accent: Color) -> void:
	var wave := sin(_t * 1.5) * 7.0
	var pts := PackedVector2Array([
		Vector2(74, 118), Vector2(126, 118),
		Vector2(150 + wave, 190), Vector2(158 + wave * 1.4, 236),
		Vector2(120, 224), Vector2(100, 232), Vector2(80, 222),
		Vector2(44 - wave * 1.2, 236), Vector2(52 - wave, 190)])
	var closed := pts.duplicate()
	closed.append(pts[0])
	self.draw_polyline(closed, UiSkin.OUTLINE, 7.0, true)
	self.draw_colored_polygon(pts, suit.darkened(0.42))
	self.draw_colored_polygon(PackedVector2Array([
		Vector2(88, 120), Vector2(112, 120), Vector2(104, 168), Vector2(96, 168)]),
		accent.darkened(0.2))


func _legs(suit: Color) -> void:
	var dark := suit.darkened(0.35)
	var swing := sin(_t * idle_speed) * 2.0
	_rr(72.0, 194.0 + swing, 94.0, 244.0, dark, 11)
	_rr(106.0, 194.0 - swing, 128.0, 244.0, dark, 11)
	_rr(66.0, 232.0 + swing, 96.0, 250.0, UiSkin.OUTLINE.lightened(0.18), 9)
	_rr(104.0, 232.0 - swing, 134.0, 250.0, UiSkin.OUTLINE.lightened(0.18), 9)


func _body(suit: Color, accent: Color) -> void:
	_rr(58.0, 122.0, 142.0, 206.0, suit, 28)
	# epaulieres
	_disc(Vector2(64.0, 134.0), 17.0, suit.lightened(0.18))
	_disc(Vector2(136.0, 134.0), 17.0, suit.lightened(0.18))
	# ceinture
	self.draw_style_box(UiSkin.box(accent, 6, 0), Rect2(60.0, 174.0, 80.0, 15.0))
	self.draw_style_box(UiSkin.box(accent.darkened(0.3), 5, 0), Rect2(91.0, 171.0, 18.0, 21.0))
	# emblème sur le torse
	self.draw_colored_polygon(PackedVector2Array([
		Vector2(100, 132), Vector2(115, 150), Vector2(100, 168), Vector2(85, 150)]),
		accent)
	self.draw_colored_polygon(PackedVector2Array([
		Vector2(100, 138), Vector2(109, 150), Vector2(100, 162), Vector2(91, 150)]),
		suit.darkened(0.25))


func _arm_back(suit: Color, skin_col: Color) -> void:
	var sway := sin(_t * idle_speed + 0.6) * 3.0
	_rr(40.0, 138.0 + sway, 66.0, 190.0 + sway, suit.darkened(0.2), 13)
	_disc(Vector2(53.0, 195.0 + sway), 14.0, skin_col)


func _arm_front(suit: Color, skin_col: Color) -> void:
	var sway := sin(_t * idle_speed - 0.6) * 3.0
	_rr(134.0, 138.0 + sway, 160.0, 190.0 + sway, suit, 13)
	_disc(Vector2(147.0, 195.0 + sway), 14.0, skin_col)


func _weapon(accent: Color, suit: Color) -> void:
	var sway := sin(_t * idle_speed - 0.6) * 3.0
	var kind := str(data.get("weapon", "gun"))
	var steel := (Color("cbd5e1") if not locked else Color("3a3f60"))
	match kind:
		"gun":
			_rr(142.0, 178.0 + sway, 198.0, 198.0 + sway, steel, 8)
			_disc(Vector2(196.0, 188.0 + sway), 14.0, accent)
		"hammer":
			_rr(154.0, 116.0 + sway, 166.0, 202.0 + sway, (Color("7c4a1e") if not locked else steel), 6)
			_rr(146.0, 96.0 + sway, 198.0, 136.0 + sway, steel, 10)
			self.draw_style_box(UiSkin.box(accent, 4, 0), Rect2(151.0, 104.0 + sway, 42.0, 8.0))
		"bow":
			self.draw_arc(Vector2(170.0, 162.0 + sway), 48.0, -PI * 0.55, PI * 0.55, 20, UiSkin.OUTLINE, 12.0)
			self.draw_arc(Vector2(170.0, 162.0 + sway), 48.0, -PI * 0.55, PI * 0.55, 20, accent, 7.0)
			self.draw_line(Vector2(195.0, 121.0 + sway), Vector2(195.0, 203.0 + sway), Color(1, 1, 1, 0.7), 3.0)
		"staff":
			_rr(152.0, 66.0 + sway, 166.0, 204.0 + sway, suit.darkened(0.45), 7)
			# orbe : halo + noyau + reflet
			var oc := Vector2(159.0, 54.0 + sway)
			if not locked:
				for i in 6:
					self.draw_circle(oc, 34.0 - float(i) * 4.0, Color(accent, 0.07))
			_disc(oc, 25.0, accent)
			self.draw_circle(oc + Vector2(-7, -8), 8.0, Color(1, 1, 1, 0.7))
		_:  # "fist" : gros gants
			_disc(Vector2(152.0, 196.0 + sway), 21.0, accent)


func _head(skin_col: Color, hair: Color, accent: Color) -> void:
	var head := Vector2(100.0, 84.0)
	_disc(head, 50.0, skin_col)

	var glow := bool(data.get("glow_eyes", false)) and not locked
	var look := sin(_t * 0.8) * 3.0
	var closed := _blink < 0.12
	for i in 2:
		var ec := head + Vector2(-16.0 + float(i) * 32.0, -1.0)
		if closed:
			self.draw_line(ec + Vector2(-12, 0), ec + Vector2(12, 0), UiSkin.OUTLINE, 5.0)
		elif glow:
			self.draw_circle(ec, 17.0, Color(accent, 0.30))
			self.draw_circle(ec, 12.0, accent)
			self.draw_circle(ec + Vector2(look, 1.0), 6.0, Color(1, 1, 1, 0.9))
		else:
			self.draw_circle(ec, 16.0, UiSkin.OUTLINE)
			self.draw_circle(ec, 13.0, Color.WHITE)
			self.draw_circle(ec + Vector2(look, 2.0), 7.0, UiSkin.OUTLINE)
			self.draw_circle(ec + Vector2(look - 2.0, -1.0), 2.4, Color.WHITE)
	# sourcils
	self.draw_line(head + Vector2(-30, -24), head + Vector2(-7, -30), UiSkin.OUTLINE, 6.0)
	self.draw_line(head + Vector2(30, -24), head + Vector2(7, -30), UiSkin.OUTLINE, 6.0)
	# bouche
	self.draw_arc(head + Vector2(0, 16.0), 16.0, 0.25 * PI, 0.75 * PI, 14, UiSkin.OUTLINE, 5.0)

	match str(data.get("hat", "hair")):
		"cap":
			self.draw_arc(head, 50.0, PI, TAU, 24, hair, 28.0)
			self.draw_style_box(UiSkin.box(hair.darkened(0.2), 8, 4, UiSkin.OUTLINE),
					Rect2(head.x - 6.0, head.y - 44.0, 66.0, 17.0))
		"helmet":
			self.draw_arc(head, 52.0, PI, TAU, 24, hair.lightened(0.15), 28.0)
			self.draw_style_box(UiSkin.box(accent, 5, 0), Rect2(head.x - 5.0, head.y - 68.0, 10.0, 28.0))
		"hood":
			# capuche : coque exterieure + ombre interieure
			self.draw_colored_polygon(PackedVector2Array([
				Vector2(head.x - 8, head.y - 78), Vector2(head.x + 8, head.y - 78),
				Vector2(head.x + 4, head.y - 44), Vector2(head.x - 4, head.y - 44)]), UiSkin.OUTLINE)
			self.draw_circle(head + Vector2(0, -4), 57.0, UiSkin.OUTLINE)
			self.draw_circle(head + Vector2(0, -4), 52.0, hair)
			self.draw_circle(head + Vector2(0, 8), 49.0, skin_col.darkened(0.28))
			self.draw_circle(head + Vector2(0, 11), 47.0, skin_col)
			self.draw_circle(head + Vector2(0, -74), 9.0, accent)
			# on redessine le visage par-dessus l'ombre de la capuche
			for i in 2:
				var ec2 := head + Vector2(-16.0 + float(i) * 32.0, 4.0)
				if glow:
					self.draw_circle(ec2, 17.0, Color(accent, 0.35))
					self.draw_circle(ec2, 12.0, accent)
					self.draw_circle(ec2 + Vector2(look, 1.0), 6.0, Color(1, 1, 1, 0.9))
				else:
					self.draw_circle(ec2, 16.0, UiSkin.OUTLINE)
					self.draw_circle(ec2, 13.0, Color.WHITE)
					self.draw_circle(ec2 + Vector2(look, 2.0), 7.0, UiSkin.OUTLINE)
			self.draw_arc(head + Vector2(0, 24.0), 16.0, 0.25 * PI, 0.75 * PI, 14, UiSkin.OUTLINE, 5.0)
		"crown":
			self.draw_colored_polygon(PackedVector2Array([
				Vector2(head.x - 36, head.y - 38), Vector2(head.x - 26, head.y - 68),
				Vector2(head.x - 11, head.y - 48), Vector2(head.x, head.y - 76),
				Vector2(head.x + 11, head.y - 48), Vector2(head.x + 26, head.y - 68),
				Vector2(head.x + 36, head.y - 38)]), accent)
		_:
			self.draw_arc(head, 50.0, PI * 0.95, TAU * 1.05, 26, hair, 26.0)
			self.draw_circle(head + Vector2(-33, -39), 14.0, hair)
			self.draw_circle(head + Vector2(33, -39), 14.0, hair)
