@tool
class_name BrawlerModel3D
extends Node3D
## Le brawler en 3D.
##
## Technique : MODELAGE BOOLEEN, pas empilement de primitives.
## Les morceaux d'un meme materiau sont reunis dans un CSGCombiner3D qui les
## FUSIONNE en un seul volume continu. Resultat : une veste est une veste, pas
## un tronc plus deux boules d'epaule posees dessus, et le contour cartoon suit
## la silhouette entiere au lieu de cerner chaque bout separement.
##
## Les groupes correspondent aux zones de couleur (peau, tenue, pantalon,
## bottes, cheveux). La frontiere entre deux groupes devient naturellement un
## trait noir — exactement la ou un dessinateur en mettrait un.
##
## Un brawler peut aussi fournir un vrai fichier 3D via la cle "model".

const OUTLINE := Color("0c0a16")
const OUTLINE_WIDTH := 0.040
const TARGET_HEIGHT := 2.68

# Repere du squelette (sol a y = 0)
const ANKLE_Y := 0.26
const KNEE_Y := 0.70
const HIP_Y := 1.16
const WAIST_Y := 1.30
const CHEST_Y := 1.66
const SHOULDER_Y := 1.76
const SHOULDER_X := 0.36
const NECK_Y := 1.92
const HEAD_C := Vector3(0.0, 2.26, 0.0)
const HEAD_R := 0.40

var parts := {}
var groups := {}
var body: Node3D
var _data: Dictionary = {}
var _t := 0.0
var _swap := 1.0
var _blink := 2.0


func _ready() -> void:
	set_process(true)


static func toon(color: Color, outline: float = OUTLINE_WIDTH) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.9
	m.metallic = 0.0
	m.specular = 0.2
	if outline > 0.0:
		var o := StandardMaterial3D.new()
		o.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		o.albedo_color = OUTLINE
		o.cull_mode = BaseMaterial3D.CULL_FRONT
		o.grow = true
		o.grow_amount = outline
		m.next_pass = o
	return m


# ------------------------------------------------------------ briques CSG

## Un volume de couleur. Tout ce qu'on y met fusionne en une seule surface.
func _group(name_: String, color: Color, outline := OUTLINE_WIDTH) -> CSGCombiner3D:
	var c := CSGCombiner3D.new()
	c.name = name_
	c.use_collision = false
	c.material_override = toon(color, outline)
	body.add_child(c)
	groups[name_] = c
	return c


func _ball(parent: Node3D, pos: Vector3, r: float, scale_ := Vector3.ONE,
		rot := Vector3.ZERO) -> CSGSphere3D:
	var s := CSGSphere3D.new()
	s.radius = r
	s.radial_segments = 22
	s.rings = 11
	s.smooth_faces = true
	s.position = pos
	s.scale = scale_
	s.rotation = rot
	parent.add_child(s)
	return s


func _cube(parent: Node3D, pos: Vector3, size: Vector3, rot := Vector3.ZERO) -> CSGBox3D:
	var b := CSGBox3D.new()
	b.size = size
	b.position = pos
	b.rotation = rot
	parent.add_child(b)
	return b


## Membre : un cylindre entre deux articulations, ferme par une boule a chaque
## bout. L'union en fait une seule forme lisse, sans raccord visible.
func _limb(parent: Node3D, a: Vector3, b: Vector3, r: float, cap_a := true, cap_b := true) -> void:
	var dir := b - a
	var length := dir.length()
	var cyl := CSGCylinder3D.new()
	cyl.radius = r
	cyl.height = length
	cyl.sides = 16
	cyl.smooth_faces = true
	cyl.position = (a + b) * 0.5
	var yy := dir.normalized()
	var ref := Vector3(0.0, 0.0, 1.0) if absf(yy.z) < 0.9 else Vector3(1.0, 0.0, 0.0)
	var xx := yy.cross(ref).normalized()
	cyl.basis = Basis(xx, yy, xx.cross(yy).normalized())
	parent.add_child(cyl)
	if cap_a:
		_ball(parent, a, r)
	if cap_b:
		_ball(parent, b, r)


## Petit detail pose PAR-DESSUS les volumes (oeil, sourcil, boucle de ceinture).
## Ceux-la restent separes : ils doivent justement se detacher.
func _detail(name_: String, mesh: Mesh, color: Color, pos: Vector3,
		rot := Vector3.ZERO, scale_ := Vector3.ONE, outline := 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = name_
	mi.mesh = mesh
	mi.material_override = toon(color, outline)
	mi.position = pos
	mi.rotation = rot
	mi.scale = scale_
	body.add_child(mi)
	parts[name_] = mi
	return mi


static func _sphere_mesh(r: float) -> SphereMesh:
	var m := SphereMesh.new()
	m.radius = r
	m.height = r * 2.0
	m.radial_segments = 18
	m.rings = 9
	return m


static func _box_mesh(x: float, y: float, z: float) -> BoxMesh:
	var m := BoxMesh.new()
	m.size = Vector3(x, y, z)
	return m


# ------------------------------------------------------------------ montage

static func _col(data: Dictionary, key: String, fallback: Color, locked: bool) -> Color:
	var v = data.get(key, fallback)
	var c: Color = v if v is Color else fallback
	return c.lerp(Color("2b2f4a"), 0.78) if locked else c


func build(data: Dictionary) -> void:
	_data = data
	for c in get_children():
		c.queue_free()
	parts.clear()
	groups.clear()

	body = Node3D.new()
	body.name = "Body"
	add_child(body)

	var model_path := str(data.get("model", ""))
	if not model_path.is_empty() and ResourceLoader.exists(model_path):
		_from_file(model_path)
		return

	var locked := not bool(data.get("unlocked", true))
	var suit := _col(data, "suit", Color("2fa8ff"), locked)
	var accent := _col(data, "accent", Color("ffc531"), locked)
	var skin := _col(data, "skin", Color("f5c69a"), locked)
	var hair := _col(data, "hair", Color("d9622b"), locked)
	var pants := _col(data, "pants", suit.darkened(0.55), locked)

	var grips := _weapon(str(data.get("weapon", "gun")), accent, suit, locked)
	_build_skin(skin, grips)
	_build_outfit(suit, grips)
	_build_lower(pants)
	_build_hair(str(data.get("hat", "ponytail")), hair, accent)
	_build_face(skin, hair)
	_build_trim(accent)


## Peau : tete, oreilles, nuque, avant-bras et mains, tout en un seul volume.
func _build_skin(skin: Color, grips: Dictionary) -> void:
	var g := _group("skin", skin)
	_ball(g, HEAD_C, HEAD_R, Vector3(1.0, 1.06, 0.98))
	for i in 2:
		var s := -1.0 if i == 0 else 1.0
		_ball(g, HEAD_C + Vector3(s * 0.37, -0.02, -0.02), 0.10, Vector3(0.65, 1.2, 1.0))
	_limb(g, Vector3(0.0, NECK_Y - 0.14, 0.0), Vector3(0.0, NECK_Y + 0.12, 0.0), 0.135)
	# avant-bras nus : la manche s'arrete au coude, ce qui cree un trait net
	for i in 2:
		var s := -1.0 if i == 0 else 1.0
		var shoulder := Vector3(s * SHOULDER_X, SHOULDER_Y, 0.0)
		var hand: Vector3 = grips["off"] if i == 0 else grips["main"]
		var elbow: Vector3 = (shoulder + hand) * 0.5 + Vector3(s * 0.20, -0.08, -0.10)
		_limb(g, elbow, hand, 0.092)
		var fists := str(_data.get("weapon", "gun")) == "fist"
		_ball(g, hand, 0.19 if fists else 0.105, Vector3(1.0, 1.15, 1.0))


## Tenue : buste, epaules et manches fusionnes. C'est ce groupe qui donne la
## silhouette du personnage.
func _build_outfit(suit: Color, grips: Dictionary) -> void:
	var g := _group("outfit", suit)
	# buste : deux boules etirees, l'une pour la cage, l'autre pour la taille
	_ball(g, Vector3(0.0, CHEST_Y, 0.0), 0.36, Vector3(1.06, 0.92, 0.80))
	_ball(g, Vector3(0.0, WAIST_Y, 0.0), 0.30, Vector3(1.0, 0.9, 0.78))
	_ball(g, Vector3(0.0, NECK_Y - 0.10, 0.0), 0.24, Vector3(1.0, 0.7, 0.85))
	for i in 2:
		var s := -1.0 if i == 0 else 1.0
		var shoulder := Vector3(s * SHOULDER_X, SHOULDER_Y, 0.0)
		var hand: Vector3 = grips["off"] if i == 0 else grips["main"]
		var elbow: Vector3 = (shoulder + hand) * 0.5 + Vector3(s * 0.20, -0.08, -0.10)
		_ball(g, shoulder, 0.185)
		_limb(g, shoulder, elbow, 0.115)


func _build_lower(pants: Color) -> void:
	var g := _group("pants", pants)
	_ball(g, Vector3(0.0, HIP_Y, 0.0), 0.30, Vector3(1.0, 0.72, 0.86))
	for i in 2:
		var s := -1.0 if i == 0 else 1.0
		_limb(g, Vector3(s * 0.16, HIP_Y - 0.04, 0.0), Vector3(s * 0.19, KNEE_Y, 0.03), 0.145)

	var b := _group("boots", OUTLINE.lightened(0.24))
	for i in 2:
		var s := -1.0 if i == 0 else 1.0
		_limb(b, Vector3(s * 0.19, KNEE_Y - 0.02, 0.03), Vector3(s * 0.20, ANKLE_Y, 0.0), 0.115)
		_ball(b, Vector3(s * 0.20, ANKLE_Y - 0.02, 0.0), 0.17, Vector3(0.95, 0.85, 1.0))
		_cube(b, Vector3(s * 0.20, 0.10, 0.07), Vector3(0.30, 0.20, 0.44))


func _build_hair(kind: String, hair: Color, accent: Color) -> void:
	var g := _group("hair", hair)
	match kind:
		"cap":
			_ball(g, HEAD_C + Vector3(0.0, 0.03, -0.10), HEAD_R + 0.04, Vector3(1.04, 1.0, 0.88))
			_cube(g, HEAD_C + Vector3(0.0, 0.12, 0.36), Vector3(0.58, 0.09, 0.36), Vector3(-0.22, 0.0, 0.0))
		"helmet":
			_ball(g, HEAD_C + Vector3(0.0, 0.05, -0.06), HEAD_R + 0.06, Vector3(1.04, 1.04, 0.94))
			_cube(g, HEAD_C + Vector3(0.0, 0.44, -0.06), Vector3(0.09, 0.28, 0.54))
		"hood":
			_ball(g, HEAD_C + Vector3(0.0, 0.0, -0.16), HEAD_R + 0.10, Vector3(1.06, 1.12, 0.94))
			_limb(g, HEAD_C + Vector3(0.0, 0.20, -0.30), HEAD_C + Vector3(0.0, 0.40, -0.62), 0.12)
		"crown":
			_ball(g, HEAD_C + Vector3(0.0, 0.03, -0.12), HEAD_R + 0.03, Vector3(1.04, 1.0, 0.88))
		_:  # frange + couettes + queue de cheval, le tout fusionne
			_ball(g, HEAD_C + Vector3(0.0, 0.05, -0.06), HEAD_R + 0.05, Vector3(1.05, 1.0, 0.96))
			_ball(g, HEAD_C + Vector3(0.0, 0.20, 0.18), 0.30, Vector3(1.25, 0.6, 0.9))
			for i in 2:
				var s := -1.0 if i == 0 else 1.0
				_limb(g, HEAD_C + Vector3(s * 0.34, 0.10, 0.0),
						HEAD_C + Vector3(s * 0.40, -0.28, 0.02), 0.115)
			_limb(g, HEAD_C + Vector3(0.0, 0.10, -0.34),
					HEAD_C + Vector3(0.0, -0.20, -0.62), 0.155)
	if kind == "crown":
		var c := _group("crown", accent)
		for i in 5:
			var a := (float(i) - 2.0) * 0.40
			_cube(c, HEAD_C + Vector3(sin(a) * 0.34, 0.42, cos(a) * 0.30 - 0.12),
					Vector3(0.10, 0.26, 0.10))


## Le visage reste en pieces separees : elles doivent se detacher du volume.
func _build_face(skin: Color, hair: Color) -> void:
	var h := HEAD_C
	for i in 2:
		var s := -1.0 if i == 0 else 1.0
		_detail("eye%d" % i, _sphere_mesh(0.135), Color.WHITE, h + Vector3(s * 0.155, 0.02, 0.30),
				Vector3.ZERO, Vector3(0.92, 1.0, 0.7), 0.013)
		_detail("pupil%d" % i, _sphere_mesh(0.068), OUTLINE, h + Vector3(s * 0.16, 0.01, 0.40))
		_detail("spark%d" % i, _sphere_mesh(0.028), Color.WHITE, h + Vector3(s * 0.13, 0.07, 0.45))
		_detail("brow%d" % i, _box_mesh(0.16, 0.042, 0.05), hair.darkened(0.25),
				h + Vector3(s * 0.17, 0.19, 0.33), Vector3(0.0, 0.0, s * -0.32))
	_detail("nose", _sphere_mesh(0.062), skin.darkened(0.08), h + Vector3(0.0, -0.06, 0.38),
			Vector3.ZERO, Vector3(1.0, 1.2, 1.3), 0.013)
	_detail("mouth", _sphere_mesh(0.115), OUTLINE, h + Vector3(0.0, -0.21, 0.32),
			Vector3.ZERO, Vector3(1.3, 0.75, 0.42))
	_detail("mouth_mask", _sphere_mesh(0.125), skin, h + Vector3(0.0, -0.14, 0.34),
			Vector3.ZERO, Vector3(1.4, 0.75, 0.42))


func _build_trim(accent: Color) -> void:
	var g := _group("trim", accent)
	_cube(g, Vector3(0.0, WAIST_Y - 0.06, 0.0), Vector3(0.60, 0.13, 0.42))
	_cube(g, Vector3(0.0, WAIST_Y - 0.06, 0.22), Vector3(0.16, 0.17, 0.10))
	_cube(g, Vector3(-0.17, CHEST_Y + 0.06, 0.30), Vector3(0.19, 0.19, 0.06),
			Vector3(0.0, 0.0, PI * 0.25))


# ------------------------------------------------------------------ armes

func _weapon(kind: String, accent: Color, suit: Color, locked: bool) -> Dictionary:
	var steel := Color("5c6472") if not locked else Color("3a3f60")
	var wood := Color("8b5a2b") if not locked else Color("3a3f60")
	match kind:
		"gun":
			var butt := Vector3(0.66, 1.18, 0.26)
			var muzzle := Vector3(-0.60, 1.50, 0.34)
			var gw := _group("weapon", wood)
			_limb(gw, butt, butt.lerp(muzzle, 0.46), 0.105)
			_limb(gw, butt.lerp(muzzle, 0.52), butt.lerp(muzzle, 0.70), 0.092)
			var gm := _group("weapon_metal", steel)
			_limb(gm, butt.lerp(muzzle, 0.42), muzzle, 0.058)
			var fwd := Vector3(0.0, -0.02, 0.09)
			return {"main": butt.lerp(muzzle, 0.22) + fwd, "off": butt.lerp(muzzle, 0.62) + fwd}
		"hammer":
			var lo := Vector3(0.44, 1.02, 0.18)
			var top := Vector3(0.20, 2.36, -0.10)
			var hw := _group("weapon", wood)
			_limb(hw, lo, top, 0.09)
			var hm := _group("weapon_metal", steel)
			_cube(hm, top, Vector3(0.46, 0.34, 0.34))
			return {"main": lo.lerp(top, 0.10), "off": lo.lerp(top, 0.34)}
		"bow":
			var centre := Vector3(-0.50, 1.62, 0.34)
			var bw := _group("weapon", wood)
			var t := CSGTorus3D.new()
			t.inner_radius = 0.40
			t.outer_radius = 0.48
			t.sides = 10
			t.ring_sides = 26
			t.smooth_faces = true
			t.position = centre
			t.rotation = Vector3(0.0, 0.0, PI * 0.5)
			bw.add_child(t)
			_detail("bow_string", _box_mesh(0.025, 0.88, 0.025), Color("efe6d2"),
					centre + Vector3(0.0, 0.0, 0.12))
			return {"main": centre, "off": Vector3(0.06, 1.56, 0.30)}
		"staff":
			var bot := Vector3(0.44, 0.10, 0.10)
			var tip := Vector3(0.44, 2.42, 0.10)
			var sw := _group("weapon", suit.darkened(0.5))
			_limb(sw, bot, tip, 0.085)
			var orb := _detail("orb", _sphere_mesh(0.28), accent, tip + Vector3(0.0, 0.22, 0.0),
					Vector3.ZERO, Vector3.ONE, OUTLINE_WIDTH)
			var om := toon(accent)
			om.emission_enabled = true
			om.emission = accent
			om.emission_energy_multiplier = 1.0
			orb.material_override = om
			return {"main": Vector3(0.44, 1.24, 0.10), "off": Vector3(0.44, 1.62, 0.10)}
		_:
			return {"main": Vector3(0.48, 1.06, 0.10), "off": Vector3(-0.48, 1.06, 0.10)}


# ------------------------------------------------------------------ fichier

func _from_file(path: String) -> void:
	var res := load(path)
	var holder := Node3D.new()
	holder.name = "model"
	body.add_child(holder)
	parts["model"] = holder
	if res is Mesh:
		var mi := MeshInstance3D.new()
		mi.mesh = res
		holder.add_child(mi)
	elif res is PackedScene:
		holder.add_child((res as PackedScene).instantiate())
	else:
		push_warning("Modele illisible : %s" % path)
		return

	var meshes: Array[MeshInstance3D] = []
	_collect_meshes(holder, meshes)
	if meshes.is_empty():
		return
	var om := StandardMaterial3D.new()
	om.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	om.albedo_color = OUTLINE
	om.cull_mode = BaseMaterial3D.CULL_FRONT
	om.grow = true
	om.grow_amount = OUTLINE_WIDTH
	var bounds := AABB()
	var first := true
	for mi in meshes:
		var m := mi.mesh
		if m == null:
			continue
		for i in m.get_surface_count():
			var src := mi.get_active_material(i)
			var dup: BaseMaterial3D = (src as BaseMaterial3D).duplicate() if src is BaseMaterial3D \
					else StandardMaterial3D.new()
			dup.next_pass = om
			mi.set_surface_override_material(i, dup)
		var b := mi.transform * m.get_aabb()
		bounds = b if first else bounds.merge(b)
		first = false
	var k: float = TARGET_HEIGHT / maxf(bounds.size.y, 0.001)
	holder.scale = Vector3(k, k, k)
	holder.position = Vector3(-bounds.get_center().x * k, -bounds.position.y * k,
			-bounds.get_center().z * k)


static func _collect_meshes(node: Node, out: Array[MeshInstance3D]) -> void:
	if node is MeshInstance3D:
		out.append(node)
	for c in node.get_children():
		_collect_meshes(c, out)


# ------------------------------------------------------------------ animation

func play_swap() -> void:
	_t = 0.0
	_swap = 0.0
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "_swap", 1.0, 0.45)


func _process(delta: float) -> void:
	_t += delta
	var e := clampf(_swap, 0.0, 1.2)
	position.y = sin(_t * 2.0) * 0.05
	rotation.y = sin(_t * 0.9) * 0.10 + (1.0 - clampf(_swap, 0.0, 1.0)) * -1.5
	rotation.z = sin(_t * 1.0) * 0.018
	var sc := lerpf(0.72, 1.0, e)
	scale = Vector3(sc, sc, sc)

	if body:
		body.rotation.y = sin(_t * 0.9 + 0.6) * 0.05
		body.rotation.x = sin(_t * 2.0) * 0.018

	_blink -= delta
	if _blink <= 0.0:
		_blink = randf_range(2.2, 5.0)
	var shut: float = clampf((0.10 - _blink) / 0.10, 0.0, 1.0) if _blink < 0.10 else 0.0
	for i in 2:
		var eye: MeshInstance3D = parts.get("eye%d" % i)
		var pup: MeshInstance3D = parts.get("pupil%d" % i)
		var spk: MeshInstance3D = parts.get("spark%d" % i)
		if eye:
			eye.scale.y = lerpf(1.0, 0.08, shut)
		if pup:
			pup.visible = shut < 0.5
		if spk:
			spk.visible = shut < 0.5
