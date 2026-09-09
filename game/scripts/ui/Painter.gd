@tool
class_name Painter
extends RefCounted
## Helpers de dessin partages par tous les widgets du lobby.

const FONT_PATH := "res://assets/fonts/game.ttf"

static var _font: Font = null
static var _font_checked := false


## Police du jeu. Deposez un .ttf dans assets/fonts/game.ttf (style Lilita One /
## Luckiest Guy) pour retrouver le rendu exact Supercell, sinon police par defaut.
static func font(ctl: Control) -> Font:
	if not _font_checked:
		_font_checked = true
		if ResourceLoader.exists(FONT_PATH):
			var res := load(FONT_PATH)
			if res is Font:
				_font = res
	if _font != null:
		return _font
	var f := ctl.get_theme_font("font", "Label")
	if f == null:
		f = ThemeDB.fallback_font
	return f


## Texte centre verticalement dans `rect`, avec contour facon cartoon.
static func text(ci: CanvasItem, f: Font, rect: Rect2, txt: String, fsize: int,
		color: Color = UiSkin.TEXT, align: int = HORIZONTAL_ALIGNMENT_CENTER,
		outline: int = 0, ocolor: Color = UiSkin.OUTLINE, shadow_dy: float = 0.0) -> void:
	if f == null or txt.is_empty():
		return
	var asc := f.get_ascent(fsize)
	var desc := f.get_descent(fsize)
	var y := rect.position.y + (rect.size.y - asc - desc) * 0.5 + asc
	var pos := Vector2(rect.position.x, y)
	if shadow_dy > 0.0 and outline > 0:
		ci.draw_string_outline(f, pos + Vector2(0.0, shadow_dy), txt, align, rect.size.x,
				fsize, outline, Color(ocolor, 0.55))
	if outline > 0:
		ci.draw_string_outline(f, pos, txt, align, rect.size.x, fsize, outline, ocolor)
	ci.draw_string(f, pos, txt, align, rect.size.x, fsize, color)


## Vide le cache statique. Appele a l'extinction du jeu : sans ca la police
## restee en variable statique est signalee comme fuite par le moteur.
static func release_cache() -> void:
	_font = null
	_font_checked = false


static func text_width(f: Font, txt: String, fsize: int) -> float:
	if f == null:
		return 0.0
	return f.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fsize).x


## Rectangle arrondi.
static func rr(ci: CanvasItem, rect: Rect2, color: Color, radius: int,
		border: int = 0, bcolor: Color = UiSkin.OUTLINE) -> void:
	ci.draw_style_box(UiSkin.box(color, radius, border, bcolor), rect)


## Ombre portee sous un element : c'est elle qui donne le relief facon Supercell.
static func shadow(ci: CanvasItem, rect: Rect2, radius: int, dy: float = 7.0,
		alpha: float = 0.30) -> void:
	rr(ci, Rect2(rect.position + Vector2(0.0, dy), rect.size), Color(0, 0, 0, alpha), radius)


## Panneau complet : ombre + fond + gros contour + liseré clair en haut.
static func card(ci: CanvasItem, rect: Rect2, color: Color = UiSkin.PANEL,
		radius: int = 20, border: int = 5, dy: float = 7.0) -> void:
	shadow(ci, rect, radius, dy)
	rr(ci, rect, UiSkin.rim(color), radius, 0)
	vgrad(ci, rect.grow(-float(border)), color, maxi(radius - border + 1, 3), 0.16, 0.18)
	var lip := Rect2(rect.position + Vector2(border + 2.0, border + 1.0),
			Vector2(rect.size.x - (border + 2.0) * 2.0, clampf(rect.size.y * 0.18, 4.0, 16.0)))
	ci.draw_style_box(UiSkin.box_top(Color(1, 1, 1, 0.10), maxi(radius - border, 2)), lip)


## Banniere penchee (titres de section facon Brawl Stars).
static func banner(ci: CanvasItem, rect: Rect2, color: Color, skew: float = 10.0) -> void:
	var pts := PackedVector2Array([
		rect.position + Vector2(skew, 0.0),
		rect.position + Vector2(rect.size.x, 0.0),
		rect.position + Vector2(rect.size.x - skew, rect.size.y),
		rect.position + Vector2(0.0, rect.size.y)])
	var sh := PackedVector2Array()
	for p in pts:
		sh.append(p + Vector2(0.0, 5.0))
	ci.draw_colored_polygon(sh, Color(0, 0, 0, 0.28))
	var closed := pts.duplicate()
	closed.append(pts[0])
	ci.draw_polyline(closed, UiSkin.OUTLINE, 7.0, true)
	ci.draw_colored_polygon(pts, color)


## Degrade vertical dans un rectangle arrondi, obtenu en empilant des bandes
## arrondies : plus clair en haut, plus sombre en bas. C'est ce que fait
## Supercell, et c'est ce qui manquait le plus a nos boutons.
static func vgrad(ci: CanvasItem, rect: Rect2, color: Color, radius: int,
		top_boost: float = 0.30, bottom_shade: float = 0.22) -> void:
	rr(ci, rect, color, radius)
	# eclaircissement progressif depuis le haut
	var bands := 9
	for i in bands:
		var t := float(i) / float(bands)
		var h := rect.size.y * (0.70 - t * 0.072)
		if h <= 2.0:
			continue
		var a := top_boost * (1.0 - t) / float(bands) * 2.4
		ci.draw_style_box(UiSkin.box_top(Color(1, 1, 1, a), maxi(radius - 2, 2)),
				Rect2(rect.position + Vector2(2.0, 1.0), Vector2(rect.size.x - 4.0, h)))
	# assombrissement du bas
	var bh := rect.size.y * 0.34
	for i in 5:
		var t := float(i) / 5.0
		var h := bh * (1.0 - t * 0.7)
		if h <= 2.0:
			continue
		ci.draw_style_box(UiSkin.box_bottom(Color(0, 0, 0, bottom_shade / 5.0), maxi(radius - 2, 2)),
				Rect2(rect.position + Vector2(2.0, rect.size.y - h - 1.0),
					Vector2(rect.size.x - 4.0, h)))


## Bouton facon Supercell, construit comme le vrai :
##   1. un contour sombre teinte qui englobe tout
##   2. la levre (teinte chaude) qui remplit l'interieur
##   3. la face en degrade posee par-dessus, laissant depasser la levre en bas
##   4. un liseré clair juste a l'interieur du contour de la face
## Les coins restent volontairement peu arrondis : c'est ce qui distingue un
## bouton de jeu d'une pilule d'interface web.
static func chunky(ci: CanvasItem, rect: Rect2, color: Color, radius: int,
		lip: float, pressed: bool = false, hovered: bool = false) -> Rect2:
	var r := mini(radius, int(rect.size.y * 0.26))
	shadow(ci, rect, r, 7.0, 0.32)

	# 1. contour
	rr(ci, rect, UiSkin.rim(color), r)

	# 2. levre chaude, elle remplit tout l'interieur
	var inner := rect.grow(-4.0)
	var ir := maxi(r - 3, 2)
	rr(ci, inner, UiSkin.lip(color), ir)

	# 3. face
	var face := Rect2(inner.position + Vector2(0.0, lip if pressed else 0.0),
			Vector2(inner.size.x, inner.size.y - lip))
	var fill := color.lightened(0.09) if hovered else color
	vgrad(ci, face, fill, ir, 0.17, 0.07)

	# 4. liseré clair a l'interieur du bord de la face
	var line := face.grow(-2.0)
	ci.draw_style_box(UiSkin.box(Color(0, 0, 0, 0.0), maxi(ir - 1, 1), 2, Color(UiSkin.inner(fill), 0.55)), line)

	return face


## Ellipse pleine (Godot ne fournit que draw_circle).
static func ellipse(ci: CanvasItem, center: Vector2, radii: Vector2, color: Color) -> void:
	ci.draw_set_transform(center, 0.0, radii)
	ci.draw_circle(Vector2.ZERO, 1.0, color)
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Halo radial : quelques cercles concentriques de plus en plus transparents.
static func glow(ci: CanvasItem, center: Vector2, radius: float, color: Color, steps: int = 32) -> void:
	for i in range(steps, 0, -1):
		var t := float(i) / float(steps)
		var c := color
		c.a = color.a * pow(1.0 - t, 1.35) * 0.13
		ci.draw_circle(center, radius * t, c)


## Barre de progression arrondie.
static func bar(ci: CanvasItem, rect: Rect2, ratio: float, color: Color, bg: Color = UiSkin.PANEL_DARK) -> void:
	var radius := int(rect.size.y * 0.5)
	rr(ci, rect, bg, radius, 2, UiSkin.OUTLINE)
	var w := maxf(rect.size.y, rect.size.x * clampf(ratio, 0.0, 1.0))
	if ratio > 0.0:
		rr(ci, Rect2(rect.position + Vector2(2, 2), Vector2(w - 4.0, rect.size.y - 4.0)), color, maxi(radius - 2, 1))
