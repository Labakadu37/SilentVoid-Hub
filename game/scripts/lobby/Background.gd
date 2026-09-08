@tool
class_name LobbyBackground
extends Control
## Le decor du lobby : une arene couverte, entierement dessinee.
##
## Couches, de l'arriere vers l'avant :
##   mur vert + lambris -> banniere emblematique -> projecteurs et leur cone de
##   lumiere -> plancher bois en perspective -> caisses -> poussieres dans la
##   lumiere -> vignette sombre sur les bords.
## Aucune image : tout est vectoriel, donc net sur n'importe quel ecran.

const DUSTS := 34

var _t := 0.0
var _dust: Array[Dictionary] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_spawn()
	set_process(not Engine.is_editor_hint())


func _spawn() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 20260908
	_dust.clear()
	for i in DUSTS:
		_dust.append({
			"x": rng.randf_range(0.30, 0.86), "y": rng.randf(),
			"speed": rng.randf_range(0.010, 0.035),
			"size": rng.randf_range(1.6, 4.2),
			"phase": rng.randf() * TAU,
		})


func _process(delta: float) -> void:
	_t += delta
	for d in _dust:
		d["y"] = fposmod(float(d["y"]) - float(d["speed"]) * delta, 1.0)
	queue_redraw()


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var horizon := size.y * 0.52
	_wall(horizon)
	_banner(horizon)
	_spotlights(horizon)
	_floor(horizon)
	_crates(horizon)
	_dust_motes()
	_vignette()


# ------------------------------------------------------------------ mur

func _wall(horizon: float) -> void:
	var steps := 22
	for i in steps:
		var t := float(i) / float(steps - 1)
		self.draw_rect(Rect2(0.0, horizon * float(i) / float(steps) - 1.0,
				size.x, horizon / float(steps) + 2.0),
				UiSkin.HALL_DARK.lerp(UiSkin.HALL_TOP, pow(t, 0.7)))

	# lambris vertical
	var planks := 16
	var pw := size.x / float(planks)
	for i in planks:
		if i % 2 == 0:
			self.draw_rect(Rect2(float(i) * pw, 0.0, pw, horizon), Color(1, 1, 1, 0.035))
	# plinthe
	self.draw_rect(Rect2(0.0, horizon - size.y * 0.055, size.x, size.y * 0.055), UiSkin.HALL_DARK)
	self.draw_rect(Rect2(0.0, horizon - size.y * 0.058, size.x, 5.0), UiSkin.OUTLINE)


## Grande banniere accrochee au mur, derriere le brawler.
func _banner(horizon: float) -> void:
	var w := size.x * 0.26
	var h := horizon * 0.80
	var x := size.x * 0.58 - w * 0.5
	var y := horizon * 0.05

	# tringle
	Painter.rr(self, Rect2(x - 14.0, y - 12.0, w + 28.0, 14.0), UiSkin.FLOOR_DARK, 6, 4, UiSkin.OUTLINE)

	# toile avec pointe en bas
	var cloth := PackedVector2Array([
		Vector2(x, y), Vector2(x + w, y), Vector2(x + w, y + h * 0.86),
		Vector2(x + w * 0.5, y + h), Vector2(x, y + h * 0.86)])
	var closed := cloth.duplicate()
	closed.append(cloth[0])
	self.draw_colored_polygon(cloth, UiSkin.HALL_DARK)
	self.draw_polyline(closed, UiSkin.OUTLINE, 6.0, true)

	# lisere dore
	var inset := 14.0
	var trim := PackedVector2Array([
		Vector2(x + inset, y + inset), Vector2(x + w - inset, y + inset),
		Vector2(x + w - inset, y + h * 0.86 - inset * 0.4),
		Vector2(x + w * 0.5, y + h - inset * 1.6),
		Vector2(x + inset, y + h * 0.86 - inset * 0.4), Vector2(x + inset, y + inset)])
	self.draw_polyline(trim, Color(UiSkin.GOLD, 0.55), 4.0, true)

	# emblème du jeu : un losange dans un cercle
	var c := Vector2(x + w * 0.5, y + h * 0.44)
	var r := h * 0.19
	self.draw_circle(c, r, Color(UiSkin.GOLD, 0.16))
	self.draw_arc(c, r, 0.0, TAU, 40, Color(UiSkin.GOLD, 0.40), 5.0)
	Icons.draw(self, "gem", Rect2(c - Vector2(r, r) * 0.62, Vector2(r, r) * 1.24),
			Color(UiSkin.GOLD, 0.42), false)


# ------------------------------------------------------------------ lumiere

func _spotlights(horizon: float) -> void:
	for i in 2:
		var x := size.x * (0.36 + float(i) * 0.44)
		var head := Rect2(x - size.x * 0.028, size.y * 0.015, size.x * 0.056, size.y * 0.045)
		# cone de lumiere
		var spread := size.x * 0.20
		self.draw_colored_polygon(PackedVector2Array([
			Vector2(head.position.x + head.size.x * 0.2, head.end.y),
			Vector2(head.end.x - head.size.x * 0.2, head.end.y),
			Vector2(x + spread, size.y * 0.92), Vector2(x - spread, size.y * 0.92)]),
			Color(UiSkin.SPOT, 0.10))
		Painter.rr(self, head, UiSkin.PANEL_DARK, 8, 5, UiSkin.OUTLINE)
		self.draw_circle(Vector2(x, head.end.y - 3.0), head.size.y * 0.30, UiSkin.SPOT)
		Painter.glow(self, Vector2(x, head.end.y), size.y * 0.09, Color(UiSkin.SPOT, 0.55), 16)

	# flaque de lumiere sur le sol, sous le perso
	Painter.ellipse(self, Vector2(size.x * 0.58, size.y * 0.76),
			Vector2(size.x * 0.28, size.y * 0.11), Color(UiSkin.SPOT, 0.14))


# ------------------------------------------------------------------ sol

func _floor(horizon: float) -> void:
	self.draw_rect(Rect2(0.0, horizon, size.x, size.y - horizon), UiSkin.FLOOR)
	# lattes en perspective : elles s'ecartent vers le spectateur
	var planks := 14
	for i in planks:
		if i % 2 == 1:
			continue
		var t0 := float(i) / float(planks)
		var t1 := float(i + 1) / float(planks)
		self.draw_colored_polygon(PackedVector2Array([
			Vector2(lerpf(size.x * 0.18, size.x * 0.82, t0), horizon),
			Vector2(lerpf(size.x * 0.18, size.x * 0.82, t1), horizon),
			Vector2(lerpf(-size.x * 0.35, size.x * 1.35, t1), size.y),
			Vector2(lerpf(-size.x * 0.35, size.x * 1.35, t0), size.y)]), UiSkin.FLOOR_DARK)
	# lignes de fuite plus claires
	for i in 5:
		var t := float(i) / 4.0
		self.draw_line(Vector2(lerpf(size.x * 0.18, size.x * 0.82, t), horizon),
				Vector2(lerpf(-size.x * 0.35, size.x * 1.35, t), size.y),
				Color(1, 1, 1, 0.05), 3.0)
	# tapis rond sous le perso
	Painter.ellipse(self, Vector2(size.x * 0.58, size.y * 0.76),
			Vector2(size.x * 0.185, size.y * 0.060), UiSkin.FLOOR_LIGHT)
	Painter.ellipse(self, Vector2(size.x * 0.58, size.y * 0.76),
			Vector2(size.x * 0.150, size.y * 0.048), UiSkin.FLOOR)


func _crates(horizon: float) -> void:
	for spec in [[0.10, 0.9], [0.17, 0.62], [0.90, 1.0], [0.96, 0.7]]:
		var cx: float = size.x * float(spec[0])
		var s: float = size.y * 0.11 * float(spec[1])
		var r := Rect2(cx - s * 0.5, horizon - s * 0.15, s, s)
		Painter.rr(self, r, UiSkin.FLOOR_DARK.darkened(0.15), 8, 5, UiSkin.OUTLINE)
		self.draw_line(r.position + Vector2(6, r.size.y * 0.32),
				r.position + Vector2(r.size.x - 6.0, r.size.y * 0.32), Color(0, 0, 0, 0.25), 4.0)


func _dust_motes() -> void:
	for d in _dust:
		var pos := Vector2(float(d["x"]) * size.x + sin(_t * 0.5 + float(d["phase"])) * 14.0,
				float(d["y"]) * size.y)
		self.draw_circle(pos, float(d["size"]), Color(UiSkin.DUST, 0.35))


## Coins assombris : le regard est ramene au centre, comme dans Brawl Stars.
func _vignette() -> void:
	var steps := 20
	var dv := size.y * 0.34
	var dh := size.x * 0.24
	var thv := dv / float(steps)
	var thh := dh / float(steps)
	for i in steps:
		var t := float(i) / float(steps)
		var a := 0.30 * pow(1.0 - t, 2.2)
		var col := Color(0, 0, 0, a)
		self.draw_rect(Rect2(0.0, dv * t, size.x, thv + 1.0), col)
		self.draw_rect(Rect2(0.0, size.y - dv * t - thv, size.x, thv + 1.0), col)
		self.draw_rect(Rect2(dh * t, 0.0, thh + 1.0, size.y), col)
		self.draw_rect(Rect2(size.x - dh * t - thh, 0.0, thh + 1.0, size.y), col)
