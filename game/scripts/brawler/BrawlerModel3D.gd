@tool
class_name BrawlerModel3D
extends Node3D
## Le brawler en 3D, assemble a partir de formes primitives (spheres, capsules,
## boites) — aucun fichier de modele a fournir.
##
## Le rendu "Brawl Stars" tient a une seule astuce : chaque piece porte une
## seconde passe de materiau en coque inversee (cull_front + grow) peinte en
## noir. Ca dessine un contour epais autour de toutes les silhouettes, exactement
## comme les brawlers de Supercell.

const OUTLINE_COLOR := Color("0c0a16")
const OUTLINE_WIDTH := 0.046

var parts := {}          # nom -> MeshInstance3D
var _data: Dictionary = {}
var _t := 0.0
var _swap := 1.0


func _ready() -> void:
	set_process(true)


## Materiau cartoon : couleur mate + contour en coque inversee.
static func toon(color: Color, outline: float = OUTLINE_WIDTH) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.92
	m.metallic = 0.0
	m.specular = 0.15
	if outline > 0.0:
		var o := StandardMaterial3D.new()
		o.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		o.albedo_color = OUTLINE_COLOR
		o.cull_mode = BaseMaterial3D.CULL_FRONT
		o.grow = true
		o.grow_amount = outline
		m.next_pass = o
	return m


func _add(name_: String, mesh: Mesh, color: Color, pos: Vector3,
		rot := Vector3.ZERO, scale_ := Vector3.ONE, outline := OUTLINE_WIDTH) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = name_
	mi.mesh = mesh
	mi.material_override = toon(color, outline)
	mi.position = pos
	mi.rotation = rot
	mi.scale = scale_
	add_child(mi)
	parts[name_] = mi
	return mi


static func _sphere(r: float) -> SphereMesh:
	var m := SphereMesh.new()
	m.radius = r
	m.height = r * 2.0
	m.radial_segments = 24
	m.rings = 12
	return m


static func _capsule(r: float, h: float) -> CapsuleMesh:
	var m := CapsuleMesh.new()
	m.radius = r
	m.height = maxf(h, r * 2.0 + 0.01)
	m.radial_segments = 18
	m.rings = 6
	return m


static func _box(x: float, y: float, z: float) -> BoxMesh:
	var m := BoxMesh.new()
	m.size = Vector3(x, y, z)
	return m


static func _cyl(r: float, h: float) -> CylinderMesh:
	var m := CylinderMesh.new()
	m.top_radius = r
	m.bottom_radius = r
	m.height = h
	m.radial_segments = 16
	return m


# ------------------------------------------------------------------ montage

func build(data: Dictionary) -> void:
	_data = data
	for c in get_children():
		c.queue_free()
	parts.clear()

	var locked := not bool(data.get("unlocked", true))
	var suit: Color = _col(data, "suit", Color("6d28d9"), locked)
	var accent: Color = _col(data, "accent", Color("2fd9e0"), locked)
	var skin: Color = _col(data, "skin", Color("f5c69a"), locked)
	var hair: Color = _col(data, "hair", Color("241a4e"), locked)
	var dark := suit.darkened(0.35)

	# --- jambes et bottes
	for i in 2:
		var x := -0.21 + float(i) * 0.42
		_add("leg%d" % i, _capsule(0.135, 0.70), dark, Vector3(x, 0.48, 0.0))
		_add("boot%d" % i, _box(0.36, 0.22, 0.50), OUTLINE_COLOR.lightened(0.18),
				Vector3(x, 0.11, 0.05))

	# --- torse
	_add("torso", _capsule(0.38, 1.00), suit, Vector3(0.0, 1.16, 0.0))
	_add("belt", _cyl(0.40, 0.14), accent, Vector3(0.0, 0.84, 0.0))
	_add("buckle", _box(0.20, 0.20, 0.12), accent.darkened(0.3), Vector3(0.0, 0.84, 0.34))
	# emblème sur le torse
	_add("crest", _box(0.26, 0.26, 0.08), accent, Vector3(0.0, 1.34, 0.34),
			Vector3(0.0, 0.0, PI * 0.25))

	# --- epaules, bras, mains
	for i in 2:
		var s := -1.0 if i == 0 else 1.0
		_add("shoulder%d" % i, _sphere(0.23), suit.lightened(0.14),
				Vector3(s * 0.47, 1.42, 0.0))
		_add("arm%d" % i, _capsule(0.125, 0.58), suit, Vector3(s * 0.53, 1.06, 0.02))
		_add("hand%d" % i, _sphere(0.17), skin, Vector3(s * 0.55, 0.75, 0.04))

	# --- tete
	_add("head", _sphere(0.54), skin, Vector3(0.0, 2.08, 0.0))
	for i in 2:
		var s := -1.0 if i == 0 else 1.0
		_add("eye%d" % i, _sphere(0.175), Color.WHITE, Vector3(s * 0.20, 2.12, 0.44), Vector3.ZERO,
				Vector3.ONE, 0.018)
		_add("pupil%d" % i, _sphere(0.088), OUTLINE_COLOR, Vector3(s * 0.21, 2.11, 0.57),
				Vector3.ZERO, Vector3.ONE, 0.0)
		_add("brow%d" % i, _box(0.19, 0.045, 0.05), hair.darkened(0.2),
				Vector3(s * 0.235, 2.36, 0.46), Vector3(0.0, 0.0, s * -0.30), Vector3.ONE, 0.0)
	# le sourire : une ellipse sombre dont on masque la moitie haute avec une
	# ellipse couleur peau posee juste devant. Un croissant, pas un rond etonne.
	_add("mouth", _sphere(0.16), OUTLINE_COLOR, Vector3(0.0, 1.82, 0.46),
			Vector3.ZERO, Vector3(1.35, 0.78, 0.42), 0.0)
	_add("mouth_mask", _sphere(0.17), skin, Vector3(0.0, 1.93, 0.48),
			Vector3.ZERO, Vector3(1.45, 0.80, 0.42), 0.0)

	_build_hat(str(data.get("hat", "hair")), hair, accent)
	_build_weapon(str(data.get("weapon", "gun")), accent, suit, locked)
	if bool(data.get("cape", false)):
		_add("cape", _box(0.92, 1.5, 0.10), suit.darkened(0.4), Vector3(0.0, 1.10, -0.44),
				Vector3(0.10, 0.0, 0.0))


static func _col(data: Dictionary, key: String, fallback: Color, locked: bool) -> Color:
	var v = data.get(key, fallback)
	var c: Color = v if v is Color else fallback
	return c.lerp(Color("2b2f4a"), 0.78) if locked else c


## Les coiffes sont des spheres APLATIES EN PROFONDEUR et reculees : sinon elles
## englobent la tete et le visage disparait completement.
func _build_hat(kind: String, hair: Color, accent: Color) -> void:
	var back := Vector3(0.0, 2.16, -0.20)
	var flat := Vector3(1.06, 1.06, 0.76)
	match kind:
		"cap":
			_add("hair", _sphere(0.57), hair, back, Vector3.ZERO, flat)
			_add("visor", _box(0.74, 0.10, 0.44), hair.darkened(0.25),
					Vector3(0.0, 2.26, 0.42), Vector3(-0.20, 0.0, 0.0))
		"helmet":
			_add("hair", _sphere(0.60), hair.lightened(0.12), back, Vector3.ZERO,
					Vector3(1.04, 1.04, 0.80))
			_add("crest_top", _box(0.10, 0.34, 0.62), accent, Vector3(0.0, 2.66, -0.10))
		"hood":
			_add("hair", _sphere(0.62), hair, Vector3(0.0, 2.14, -0.26), Vector3.ZERO,
					Vector3(1.04, 1.10, 0.84))
			_add("hood_tip", _capsule(0.14, 0.60), hair, Vector3(0.0, 2.60, -0.56),
					Vector3(0.75, 0.0, 0.0))
			_add("hood_gem", _sphere(0.12), accent, Vector3(0.0, 2.58, 0.10))
		"crown":
			_add("hair", _sphere(0.56), hair, back, Vector3.ZERO, flat)
			for i in 5:
				var a := (float(i) - 2.0) * 0.42
				_add("spike%d" % i, _box(0.12, 0.32, 0.12), accent,
						Vector3(sin(a) * 0.44, 2.68, cos(a) * 0.40 - 0.20))
		_:  # cheveux + queue de cheval
			_add("hair", _sphere(0.59), hair, back, Vector3.ZERO, flat)
			_add("ponytail", _capsule(0.17, 0.85), hair, Vector3(0.0, 2.10, -0.70),
					Vector3(1.0, 0.0, 0.0))


## Les armes sont calees sur la main droite (x positif). Elles restent volontairement
## compactes : une arme trop grosse mange la silhouette et casse la lecture.
func _build_weapon(kind: String, accent: Color, suit: Color, locked: bool) -> void:
	var steel := Color("8d99ae") if not locked else Color("3a3f60")
	var wood := Color("8b5a2b") if not locked else Color("3a3f60")
	match kind:
		"gun":
			_add("gun_stock", _box(0.17, 0.24, 0.26), accent.darkened(0.15),
					Vector3(0.60, 0.84, -0.06))
			_add("gun_body", _box(0.24, 0.26, 0.95), steel,
					Vector3(0.62, 0.98, 0.48), Vector3(-0.16, 0.0, 0.0))
			_add("gun_barrel", _cyl(0.11, 0.46), steel.darkened(0.34),
					Vector3(0.62, 1.10, 1.06), Vector3(PI * 0.5 - 0.16, 0.0, 0.0))
			_add("gun_sight", _box(0.07, 0.10, 0.16), accent,
					Vector3(0.62, 1.14, 0.36), Vector3(-0.16, 0.0, 0.0))
		"hammer":
			# posee sur l'epaule, ecartee du visage
			_add("haft", _cyl(0.075, 1.30), wood,
					Vector3(0.72, 1.20, -0.04), Vector3(0.0, 0.0, -0.32))
			_add("head_hammer", _box(0.50, 0.36, 0.36), steel,
					Vector3(0.96, 1.78, -0.04), Vector3(0.0, 0.0, -0.32))
			_add("band", _box(0.13, 0.38, 0.38), accent,
					Vector3(0.96, 1.78, -0.04), Vector3(0.0, 0.0, -0.32))
		"bow":
			var t := TorusMesh.new()
			t.inner_radius = 0.44
			t.outer_radius = 0.54
			t.rings = 28
			t.ring_segments = 10
			# l'anneau se dresse verticalement, vu de trois quarts
			_add("bow", t, wood, Vector3(0.66, 1.08, 0.16), Vector3(0.0, 0.0, PI * 0.5))
			_add("bow_string", _box(0.03, 0.98, 0.03), Color("efe6d2"),
					Vector3(0.66, 1.08, 0.34), Vector3.ZERO, Vector3.ONE, 0.0)
		"staff":
			_add("staff", _cyl(0.075, 2.30), suit.darkened(0.45), Vector3(0.62, 1.32, 0.02))
			var orb := _add("orb", _sphere(0.32), accent, Vector3(0.62, 2.58, 0.02))
			var om := toon(accent)
			om.emission_enabled = true
			om.emission = accent
			om.emission_energy_multiplier = 0.9
			orb.material_override = om
			var glow := _add("orb_glow", _sphere(0.40), accent.lightened(0.4),
					Vector3(0.62, 2.58, 0.02), Vector3.ZERO, Vector3.ONE, 0.0)
			var gm := StandardMaterial3D.new()
			gm.albedo_color = Color(accent.lightened(0.4), 0.26)
			gm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			gm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			glow.material_override = gm
		_:  # poings : on grossit les mains
			for i in 2:
				var h: MeshInstance3D = parts.get("hand%d" % i)
				if h:
					h.scale = Vector3(1.5, 1.5, 1.5)
					h.material_override = toon(accent)


# ------------------------------------------------------------------ animation

func play_swap() -> void:
	_t = 0.0
	_swap = 0.0
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "_swap", 1.0, 0.45)


func _process(delta: float) -> void:
	_t += delta
	var bob := sin(_t * 2.1) * 0.055
	var sway := sin(_t * 1.3) * 0.09
	position.y = bob
	rotation.y = sway + (1.0 - clampf(_swap, 0.0, 1.0)) * -1.6
	var s := lerpf(0.72, 1.0, clampf(_swap, 0.0, 1.2))
	scale = Vector3(s, s, s)

	# respiration du torse et balancement des bras
	var torso: MeshInstance3D = parts.get("torso")
	if torso:
		var b := 1.0 + sin(_t * 2.1 + PI) * 0.02
		torso.scale = Vector3(b, 1.0 / b, b)
	for i in 2:
		var arm: MeshInstance3D = parts.get("arm%d" % i)
		if arm:
			arm.rotation.x = sin(_t * 2.1 + (0.0 if i == 0 else PI)) * 0.10
	var head: MeshInstance3D = parts.get("head")
	if head:
		head.rotation.z = sin(_t * 0.9) * 0.03
