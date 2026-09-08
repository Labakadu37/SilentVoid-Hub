@tool
class_name Icons
extends RefCounted
## Icones vectorielles dessinees en code : zero asset a importer, elles
## restent nettes a toutes les resolutions.
##
## Toutes les formes sont definies en coordonnees normalisees (0..1) puis
## projetees dans le rectangle demande.

static func _p(r: Rect2, x: float, y: float) -> Vector2:
	return r.position + Vector2(x * r.size.x, y * r.size.y)


static func _poly(r: Rect2, pts: Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in pts:
		out.append(_p(r, p[0], p[1]))
	return out


static func _shape(ci: CanvasItem, r: Rect2, pts: Array, color: Color, outline: bool = true) -> void:
	var poly := _poly(r, pts)
	if outline:
		var closed := poly.duplicate()
		closed.append(poly[0])
		ci.draw_polyline(closed, UiSkin.OUTLINE, maxf(2.0, r.size.x * 0.09), true)
	ci.draw_colored_polygon(poly, color)


static func _disc(ci: CanvasItem, r: Rect2, cx: float, cy: float, rad: float, color: Color, outline: bool = true) -> void:
	var c := _p(r, cx, cy)
	var radius := rad * minf(r.size.x, r.size.y)
	if outline:
		ci.draw_circle(c, radius + maxf(1.5, r.size.x * 0.045), UiSkin.OUTLINE)
	ci.draw_circle(c, radius, color)


## Point d'entree unique : Icons.draw(self, "gem", rect, couleur)
static func draw(ci: CanvasItem, kind: String, r: Rect2, color: Color, outline: bool = true) -> void:
	match kind:
		"trophy": _trophy(ci, r, color, outline)
		"gem": _gem(ci, r, color, outline)
		"coin": _coin(ci, r, color, outline)
		"ticket": _ticket(ci, r, color, outline)
		"star": _star(ci, r, color, outline)
		"play": _shape(ci, r, [[0.26, 0.12], [0.88, 0.5], [0.26, 0.88]], color, outline)
		"clock": _clock(ci, r, color, outline)
		"plus": _plus(ci, r, color, outline)
		"gear": _gear(ci, r, color, outline)
		"shop": _shop(ci, r, color, outline)
		"brawler": _brawler(ci, r, color, outline)
		"news": _news(ci, r, color, outline)
		"club": _shape(ci, r, [[0.5, 0.06], [0.92, 0.24], [0.86, 0.62], [0.5, 0.94], [0.14, 0.62], [0.08, 0.24]], color, outline)
		"chat": _chat(ci, r, color, outline)
		"friends": _friends(ci, r, color, outline)
		"lock": _lock(ci, r, color, outline)
		"menu": _menu(ci, r, color)
		"quest": _quest(ci, r, color, outline)
		"skull": _skull(ci, r, color, outline)
		"ball": _ball(ci, r, color, outline)
		"left": _chevron(ci, r, color, true)
		"right": _chevron(ci, r, color, false)
		_: _disc(ci, r, 0.5, 0.5, 0.4, color, outline)


# ------------------------------------------------------------------ formes

static func _trophy(ci: CanvasItem, r: Rect2, color: Color, o: bool) -> void:
	var w := maxf(2.0, r.size.x * 0.09)
	ci.draw_arc(_p(r, 0.22, 0.3), r.size.x * 0.15, PI * 0.4, PI * 1.6, 12, UiSkin.OUTLINE, w + 3.0)
	ci.draw_arc(_p(r, 0.78, 0.3), r.size.x * 0.15, -PI * 0.6, PI * 0.6, 12, UiSkin.OUTLINE, w + 3.0)
	ci.draw_arc(_p(r, 0.22, 0.3), r.size.x * 0.15, PI * 0.4, PI * 1.6, 12, color, w)
	ci.draw_arc(_p(r, 0.78, 0.3), r.size.x * 0.15, -PI * 0.6, PI * 0.6, 12, color, w)
	_shape(ci, r, [[0.26, 0.08], [0.74, 0.08], [0.70, 0.46], [0.60, 0.58], [0.40, 0.58], [0.30, 0.46]], color, o)
	_shape(ci, r, [[0.44, 0.58], [0.56, 0.58], [0.58, 0.74], [0.42, 0.74]], color, o)
	_shape(ci, r, [[0.28, 0.94], [0.72, 0.94], [0.66, 0.74], [0.34, 0.74]], color, o)


static func _gem(ci: CanvasItem, r: Rect2, color: Color, o: bool) -> void:
	_shape(ci, r, [[0.5, 0.06], [0.92, 0.38], [0.5, 0.94], [0.08, 0.38]], color, o)
	ci.draw_colored_polygon(_poly(r, [[0.5, 0.08], [0.86, 0.38], [0.5, 0.5], [0.14, 0.38]]), color.lightened(0.35))


static func _coin(ci: CanvasItem, r: Rect2, color: Color, o: bool) -> void:
	_disc(ci, r, 0.5, 0.5, 0.45, color, o)
	_disc(ci, r, 0.5, 0.5, 0.33, color.lightened(0.3), false)
	_star(ci, Rect2(_p(r, 0.28, 0.28), r.size * 0.44), color.darkened(0.25), false)


static func _ticket(ci: CanvasItem, r: Rect2, color: Color, o: bool) -> void:
	_shape(ci, r, [[0.08, 0.24], [0.92, 0.24], [0.92, 0.42], [0.86, 0.5], [0.92, 0.58],
			[0.92, 0.76], [0.08, 0.76], [0.08, 0.58], [0.14, 0.5], [0.08, 0.42]], color, o)


static func _star(ci: CanvasItem, r: Rect2, color: Color, o: bool) -> void:
	var pts := []
	for i in 10:
		var a := -PI * 0.5 + float(i) * PI / 5.0
		var rad := 0.46 if i % 2 == 0 else 0.20
		pts.append([0.5 + cos(a) * rad, 0.5 + sin(a) * rad])
	_shape(ci, r, pts, color, o)


static func _clock(ci: CanvasItem, r: Rect2, color: Color, o: bool) -> void:
	_disc(ci, r, 0.5, 0.5, 0.42, color, o)
	var w := maxf(2.0, r.size.x * 0.09)
	ci.draw_line(_p(r, 0.5, 0.5), _p(r, 0.5, 0.24), UiSkin.OUTLINE, w)
	ci.draw_line(_p(r, 0.5, 0.5), _p(r, 0.72, 0.58), UiSkin.OUTLINE, w)


static func _plus(ci: CanvasItem, r: Rect2, color: Color, o: bool) -> void:
	_shape(ci, r, [[0.40, 0.12], [0.60, 0.12], [0.60, 0.40], [0.88, 0.40],
			[0.88, 0.60], [0.60, 0.60], [0.60, 0.88], [0.40, 0.88],
			[0.40, 0.60], [0.12, 0.60], [0.12, 0.40], [0.40, 0.40]], color, o)


static func _gear(ci: CanvasItem, r: Rect2, color: Color, o: bool) -> void:
	var c := _p(r, 0.5, 0.5)
	var rad := minf(r.size.x, r.size.y)
	for i in 8:
		var a := float(i) * PI / 4.0
		var dir := Vector2(cos(a), sin(a))
		var side := Vector2(-dir.y, dir.x) * rad * 0.11
		var pts := PackedVector2Array([
			c + dir * rad * 0.28 + side, c + dir * rad * 0.50 + side * 0.7,
			c + dir * rad * 0.50 - side * 0.7, c + dir * rad * 0.28 - side])
		ci.draw_colored_polygon(pts, color)
	_disc(ci, r, 0.5, 0.5, 0.30, color, o)
	_disc(ci, r, 0.5, 0.5, 0.13, UiSkin.PANEL_DARK, false)


static func _shop(ci: CanvasItem, r: Rect2, color: Color, o: bool) -> void:
	var w := maxf(2.0, r.size.x * 0.09)
	ci.draw_arc(_p(r, 0.5, 0.34), r.size.x * 0.20, PI, TAU, 14, UiSkin.OUTLINE, w + 3.0)
	ci.draw_arc(_p(r, 0.5, 0.34), r.size.x * 0.20, PI, TAU, 14, color, w)
	_shape(ci, r, [[0.14, 0.32], [0.86, 0.32], [0.94, 0.92], [0.06, 0.92]], color, o)


static func _brawler(ci: CanvasItem, r: Rect2, color: Color, o: bool) -> void:
	_disc(ci, r, 0.5, 0.26, 0.19, color, o)
	_shape(ci, r, [[0.16, 0.94], [0.24, 0.60], [0.40, 0.50], [0.60, 0.50], [0.76, 0.60], [0.84, 0.94]], color, o)


static func _news(ci: CanvasItem, r: Rect2, color: Color, o: bool) -> void:
	_shape(ci, r, [[0.08, 0.16], [0.92, 0.16], [0.92, 0.84], [0.08, 0.84]], color, o)
	var line := UiSkin.OUTLINE
	for i in 3:
		var y := 0.34 + float(i) * 0.17
		ci.draw_line(_p(r, 0.2, y), _p(r, 0.8 - float(i) * 0.12, y), line, maxf(2.0, r.size.x * 0.07))


static func _chat(ci: CanvasItem, r: Rect2, color: Color, o: bool) -> void:
	_shape(ci, r, [[0.08, 0.14], [0.92, 0.14], [0.92, 0.68], [0.52, 0.68],
			[0.34, 0.92], [0.32, 0.68], [0.08, 0.68]], color, o)


static func _friends(ci: CanvasItem, r: Rect2, color: Color, o: bool) -> void:
	_disc(ci, r, 0.70, 0.32, 0.15, color.darkened(0.2), o)
	_shape(ci, r, [[0.46, 0.90], [0.52, 0.60], [0.88, 0.60], [0.96, 0.90]], color.darkened(0.2), o)
	_disc(ci, r, 0.34, 0.30, 0.18, color, o)
	_shape(ci, r, [[0.04, 0.92], [0.12, 0.58], [0.56, 0.58], [0.64, 0.92]], color, o)


static func _menu(ci: CanvasItem, r: Rect2, color: Color) -> void:
	for i in 3:
		var y := 0.26 + float(i) * 0.24
		ci.draw_line(_p(r, 0.14, y), _p(r, 0.86, y), UiSkin.OUTLINE, maxf(4.0, r.size.x * 0.20))
		ci.draw_line(_p(r, 0.14, y), _p(r, 0.86, y), color, maxf(2.0, r.size.x * 0.13))


static func _quest(ci: CanvasItem, r: Rect2, color: Color, o: bool) -> void:
	_shape(ci, r, [[0.14, 0.14], [0.86, 0.14], [0.86, 0.94], [0.14, 0.94]], color, o)
	_shape(ci, r, [[0.34, 0.04], [0.66, 0.04], [0.66, 0.22], [0.34, 0.22]], color.darkened(0.3), o)
	var w := maxf(3.0, r.size.x * 0.11)
	ci.draw_polyline(PackedVector2Array([_p(r, 0.30, 0.56), _p(r, 0.45, 0.70), _p(r, 0.72, 0.38)]),
			UiSkin.OUTLINE, w, true)


static func _lock(ci: CanvasItem, r: Rect2, color: Color, o: bool) -> void:
	var w := maxf(2.0, r.size.x * 0.12)
	ci.draw_arc(_p(r, 0.5, 0.40), r.size.x * 0.22, PI, TAU, 16, UiSkin.OUTLINE, w + 3.0)
	ci.draw_arc(_p(r, 0.5, 0.40), r.size.x * 0.22, PI, TAU, 16, color, w)
	_shape(ci, r, [[0.16, 0.40], [0.84, 0.40], [0.84, 0.92], [0.16, 0.92]], color, o)


static func _skull(ci: CanvasItem, r: Rect2, color: Color, o: bool) -> void:
	_shape(ci, r, [[0.14, 0.44], [0.22, 0.14], [0.78, 0.14], [0.86, 0.44],
			[0.78, 0.68], [0.66, 0.72], [0.66, 0.90], [0.34, 0.90], [0.34, 0.72], [0.22, 0.68]], color, o)
	_disc(ci, r, 0.35, 0.46, 0.11, UiSkin.OUTLINE, false)
	_disc(ci, r, 0.65, 0.46, 0.11, UiSkin.OUTLINE, false)


static func _ball(ci: CanvasItem, r: Rect2, color: Color, o: bool) -> void:
	_disc(ci, r, 0.5, 0.5, 0.44, color, o)
	_star(ci, Rect2(_p(r, 0.24, 0.24), r.size * 0.52), UiSkin.OUTLINE, false)


static func _chevron(ci: CanvasItem, r: Rect2, color: Color, left: bool) -> void:
	var w := maxf(3.0, r.size.x * 0.16)
	var pts := PackedVector2Array()
	if left:
		pts = PackedVector2Array([_p(r, 0.68, 0.14), _p(r, 0.32, 0.5), _p(r, 0.68, 0.86)])
	else:
		pts = PackedVector2Array([_p(r, 0.32, 0.14), _p(r, 0.68, 0.5), _p(r, 0.32, 0.86)])
	ci.draw_polyline(pts, UiSkin.OUTLINE, w + 4.0, true)
	ci.draw_polyline(pts, color, w, true)
