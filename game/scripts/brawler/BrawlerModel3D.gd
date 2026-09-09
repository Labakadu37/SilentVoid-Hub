@tool
class_name BrawlerModel3D
extends Node3D
## Le brawler en 3D, assemble a partir de formes primitives.
##
## Deux principes, appris en corrigeant la premiere version :
##
## 1. C'EST UN HUMAIN. Nuque, oreilles, nez, cheveux coiffes, membres en deux
##    segments avec coude et genou. Sans ca on obtient une mascotte informe.
## 2. LES MAINS TIENNENT L'ARME. On place d'abord l'arme et ses points de prise,
##    puis les bras vont chercher ces points. Jamais l'inverse.
##
## Le rendu cartoon vient d'une seconde passe de materiau en coque inversee
## (cull_front + grow) peinte en noir : ca cerne chaque forme d'un trait epais.

const OUTLINE := Color("0c0a16")
const OUTLINE_WIDTH := 0.040

# Repere du squelette (le sol est a y = 0, le sommet du crane vers y = 2.68)
const ANKLE_Y := 0.24
const KNEE_Y := 0.66
const HIP_Y := 1.16
const WAIST_Y := 1.30
const CHEST_Y := 1.70
const SHOULDER := Vector3(0.34, 1.78, 0.0)
const NECK_Y := 1.92
const HEAD := Vector3(0.0, 2.28, 0.0)
const HEAD_R := 0.40

var parts := {}
var body: Node3D              # buste + bras + arme : tout pivote ensemble
var _data: Dictionary = {}
var _t := 0.0
var _swap := 1.0
var _blink := 2.0


func _ready() -> void:
	set_process(true)


## Materiau cartoon : couleur mate + contour en coque inversee.
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


# ------------------------------------------------------------------ primitives

static func _sphere(r: float) -> SphereMesh:
	var m := SphereMesh.new()
	m.radius = r
	m.height = r * 2.0
	m.radial_segments = 22
	m.rings = 11
	return m


static func _capsule(r: float, h: float) -> CapsuleMesh:
	var m := CapsuleMesh.new()
	m.radius = r
	m.height = maxf(h, r * 2.0 + 0.001)
	m.radial_segments = 16
	m.rings = 5
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
	m.radial_segments = 14
	return m


func _piece(parent: Node3D, name_: String, mesh: Mesh, color: Color, pos: Vector3,
		rot := Vector3.ZERO, scale_ := Vector3.ONE, outline := OUTLINE_WIDTH) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = name_
	mi.mesh = mesh
	mi.material_override = toon(color, outline)
	mi.position = pos
	mi.rotation = rot
	mi.scale = scale_
	parent.add_child(mi)
	parts[name_] = mi
	return mi


## Membre tendu entre deux articulations : c'est ce qui permet de plier un bras
## et d'aller chercher la poignee d'une arme.
func _bone(parent: Node3D, name_: String, a: Vector3, b: Vector3, r: float,
		color: Color) -> MeshInstance3D:
	var dir := b - a
	var length := dir.length()
	var mi := MeshInstance3D.new()
	mi.name = name_
	mi.mesh = _capsule(r, length)
	mi.material_override = toon(color)
	mi.position = (a + b) * 0.5
	var yy := dir.normalized()
	var ref := Vector3(0.0, 0.0, 1.0) if absf(yy.z) < 0.9 else Vector3(1.0, 0.0, 0.0)
	var xx := yy.cross(ref).normalized()
	var zz := xx.cross(yy).normalized()
	mi.basis = Basis(xx, yy, zz)
	parent.add_child(mi)
	parts[name_] = mi
	return mi


## Meme chose avec une boite : pour un canon, un manche, une crosse.
func _bar(parent: Node3D, name_: String, a: Vector3, b: Vector3, w: float, d: float,
		color: Color) -> MeshInstance3D:
	var dir := b - a
	var length := dir.length()
	var mi := MeshInstance3D.new()
	mi.name = name_
	mi.mesh = _box(w, length, d)
	mi.material_override = toon(color)
	mi.position = (a + b) * 0.5
	var yy := dir.normalized()
	var ref := Vector3(0.0, 0.0, 1.0) if absf(yy.z) < 0.9 else Vector3(1.0, 0.0, 0.0)
	var xx := yy.cross(ref).normalized()
	var zz := xx.cross(yy).normalized()
	mi.basis = Basis(xx, yy, zz)
	parent.add_child(mi)
	parts[name_] = mi
	return mi


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

	# Un brawler peut fournir un vrai modele 3D ("model": "res://.../x.obj").
	# Dans ce cas on l'affiche tel quel, avec le meme contour cartoon, et on
	# saute entierement la construction en primitives.
	var model_path := str(data.get("model", ""))
	if not model_path.is_empty() and ResourceLoader.exists(model_path):
		_from_file(model_path, data)
		return

	body = Node3D.new()
	body.name = "Body"
	body.position = Vector3(0.0, WAIST_Y, 0.0)
	add_child(body)

	var locked := not bool(data.get("unlocked", true))
	var suit := _col(data, "suit", Color("2fa8ff"), locked)
	var accent := _col(data, "accent", Color("ffc531"), locked)
	var skin := _col(data, "skin", Color("f5c69a"), locked)
	var hair := _col(data, "hair", Color("d9622b"), locked)
	var pants := _col(data, "pants", suit.darkened(0.55), locked)

	_legs(pants, skin)
	_torso(suit, accent, pants)
	_head(skin, hair, accent)

	# l'arme d'abord, elle donne les points de prise ; les bras suivent
	var grips := _weapon(str(data.get("weapon", "gun")), accent, suit, locked)
	_arms(suit, skin, grips)


## Affiche un modele importe (.obj, .glb, .gltf, .fbx...), mis a l'echelle pour
## occuper la meme hauteur que les brawlers construits en code, et pose au sol.
##
## Un .obj donne un Mesh, un .glb donne une scene entiere : les deux sont geres.
## Le contour cartoon est ajoute par-dessus les materiaux du fichier, sur toutes
## les surfaces trouvees, y compris dans les sous-noeuds.
func _from_file(path: String, _data: Dictionary) -> void:
	var res := load(path)
	body = Node3D.new()
	body.name = "Body"
	add_child(body)

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
		push_warning("Aucun maillage dans %s" % path)
		return

	var outline_mat := StandardMaterial3D.new()
	outline_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	outline_mat.albedo_color = OUTLINE
	outline_mat.cull_mode = BaseMaterial3D.CULL_FRONT
	outline_mat.grow = true
	outline_mat.grow_amount = OUTLINE_WIDTH

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
			dup.next_pass = outline_mat
			mi.set_surface_override_material(i, dup)
		var b := mi.transform * m.get_aabb()
		bounds = b if first else bounds.merge(b)
		first = false

	# on cale la hauteur sur celle des brawlers dessines en code
	var k: float = 2.68 / maxf(bounds.size.y, 0.001)
	holder.scale = Vector3(k, k, k)
	holder.position = Vector3(-bounds.get_center().x * k, -bounds.position.y * k,
			-bounds.get_center().z * k)


static func _collect_meshes(node: Node, out: Array[MeshInstance3D]) -> void:
	if node is MeshInstance3D:
		out.append(node)
	for c in node.get_children():
		_collect_meshes(c, out)


func _legs(pants: Color, skin: Color) -> void:
	for i in 2:
		var s := -1.0 if i == 0 else 1.0
		var hip := Vector3(s * 0.17, HIP_Y, 0.0)
		var knee := Vector3(s * 0.19, KNEE_Y, 0.04)
		var ankle := Vector3(s * 0.20, ANKLE_Y, 0.0)
		_bone(self, "thigh%d" % i, hip, knee, 0.145, pants)
		_bone(self, "shin%d" % i, knee, ankle, 0.115, skin.darkened(0.05))
		_piece(self, "knee%d" % i, _sphere(0.13), pants, knee)
		_piece(self, "boot%d" % i, _box(0.30, 0.26, 0.44), OUTLINE.lightened(0.22),
				Vector3(s * 0.20, 0.13, 0.06))
		_piece(self, "boot_top%d" % i, _cyl(0.17, 0.10), OUTLINE.lightened(0.34),
				Vector3(s * 0.20, 0.28, 0.02))


func _torso(suit: Color, accent: Color, pants: Color) -> void:
	# tout ce qui suit est enfant de `body` : positions relatives a la taille
	var w := -WAIST_Y
	_piece(body, "hips", _box(0.50, 0.30, 0.34), pants, Vector3(0.0, HIP_Y + 0.06 + w, 0.0))
	_piece(body, "chest", _capsule(0.33, 0.86), suit, Vector3(0.0, CHEST_Y - 0.16 + w, 0.0),
			Vector3.ZERO, Vector3(1.12, 1.0, 0.86))
	# col de veste
	_piece(body, "collar", _cyl(0.24, 0.12), suit.lightened(0.18),
			Vector3(0.0, NECK_Y - 0.06 + w, 0.0))
	# ceinture
	_piece(body, "belt", _box(0.56, 0.13, 0.38), accent, Vector3(0.0, WAIST_Y + 0.02 + w, 0.0))
	_piece(body, "buckle", _box(0.15, 0.16, 0.10), accent.darkened(0.35),
			Vector3(0.0, WAIST_Y + 0.02 + w, 0.20))
	# fermeture eclair / emblème
	_piece(body, "zip", _box(0.06, 0.52, 0.04), suit.darkened(0.3),
			Vector3(0.0, CHEST_Y - 0.14 + w, 0.30))
	_piece(body, "crest", _box(0.19, 0.19, 0.06), accent,
			Vector3(-0.17, CHEST_Y + 0.10 + w, 0.29), Vector3(0.0, 0.0, PI * 0.25))
	# nuque
	_bone(body, "neck", Vector3(0.0, NECK_Y - 0.10 + w, 0.0),
			Vector3(0.0, NECK_Y + 0.10 + w, 0.0), 0.13, Color("f5c69a"))


func _head(skin: Color, hair: Color, accent: Color) -> void:
	var w := -WAIST_Y
	var h := HEAD + Vector3(0.0, w, 0.0)
	_piece(body, "head", _sphere(HEAD_R), skin, h, Vector3.ZERO, Vector3(1.0, 1.06, 0.98))
	for i in 2:
		var s := -1.0 if i == 0 else 1.0
		_piece(body, "ear%d" % i, _sphere(0.095), skin, h + Vector3(s * 0.38, -0.02, -0.02),
				Vector3.ZERO, Vector3(0.7, 1.2, 1.0))
		_piece(body, "eye%d" % i, _sphere(0.135), Color.WHITE, h + Vector3(s * 0.155, 0.02, 0.30),
				Vector3.ZERO, Vector3(0.92, 1.0, 0.7), 0.014)
		_piece(body, "pupil%d" % i, _sphere(0.068), OUTLINE, h + Vector3(s * 0.16, 0.01, 0.40),
				Vector3.ZERO, Vector3.ONE, 0.0)
		_piece(body, "spark%d" % i, _sphere(0.028), Color.WHITE,
				h + Vector3(s * 0.13, 0.07, 0.45), Vector3.ZERO, Vector3.ONE, 0.0)
		_piece(body, "brow%d" % i, _box(0.16, 0.042, 0.05), hair.darkened(0.25),
				h + Vector3(s * 0.17, 0.19, 0.33), Vector3(0.0, 0.0, s * -0.32), Vector3.ONE, 0.0)
	# nez
	_piece(body, "nose", _sphere(0.062), skin.darkened(0.06), h + Vector3(0.0, -0.06, 0.38),
			Vector3.ZERO, Vector3(1.0, 1.2, 1.3), 0.014)
	# sourire : ellipse sombre dont on masque la moitie haute
	_piece(body, "mouth", _sphere(0.115), OUTLINE, h + Vector3(0.0, -0.21, 0.32),
			Vector3.ZERO, Vector3(1.3, 0.75, 0.42), 0.0)
	_piece(body, "mouth_mask", _sphere(0.125), skin, h + Vector3(0.0, -0.14, 0.34),
			Vector3.ZERO, Vector3(1.4, 0.75, 0.42), 0.0)

	_hair(str(_data.get("hat", "ponytail")), h, hair, accent)


func _hair(kind: String, h: Vector3, hair: Color, accent: Color) -> void:
	match kind:
		"cap":
			_piece(body, "hair", _sphere(HEAD_R + 0.04), hair, h + Vector3(0.0, 0.02, -0.16),
					Vector3.ZERO, Vector3(1.04, 1.02, 0.82))
			_piece(body, "visor", _box(0.58, 0.08, 0.36), hair.darkened(0.28),
					h + Vector3(0.0, 0.13, 0.34), Vector3(-0.22, 0.0, 0.0))
		"helmet":
			_piece(body, "hair", _sphere(HEAD_R + 0.06), hair.lightened(0.12),
					h + Vector3(0.0, 0.04, -0.12), Vector3.ZERO, Vector3(1.04, 1.04, 0.88))
			_piece(body, "crest_top", _box(0.09, 0.26, 0.52), accent, h + Vector3(0.0, 0.44, -0.06))
		"hood":
			_piece(body, "hair", _sphere(HEAD_R + 0.09), hair, h + Vector3(0.0, 0.0, -0.20),
					Vector3.ZERO, Vector3(1.06, 1.12, 0.90))
			_piece(body, "hood_tip", _capsule(0.11, 0.46), hair, h + Vector3(0.0, 0.32, -0.44),
					Vector3(0.8, 0.0, 0.0))
			_piece(body, "hood_gem", _sphere(0.09), accent, h + Vector3(0.0, 0.32, 0.14))
		"crown":
			_piece(body, "hair", _sphere(HEAD_R + 0.03), hair, h + Vector3(0.0, 0.02, -0.14),
					Vector3.ZERO, Vector3(1.04, 1.0, 0.84))
			for i in 5:
				var a := (float(i) - 2.0) * 0.40
				_piece(body, "spike%d" % i, _box(0.10, 0.26, 0.10), accent,
						h + Vector3(sin(a) * 0.34, 0.44, cos(a) * 0.30 - 0.14))
		_:  # coiffure par defaut : frange + couettes + queue de cheval
			_piece(body, "hair", _sphere(HEAD_R + 0.05), hair, h + Vector3(0.0, 0.04, -0.10),
					Vector3.ZERO, Vector3(1.05, 1.0, 0.94))
			_piece(body, "fringe", _sphere(0.30), hair, h + Vector3(0.0, 0.22, 0.20),
					Vector3.ZERO, Vector3(1.25, 0.55, 0.85))
			for i in 2:
				var s := -1.0 if i == 0 else 1.0
				_piece(body, "tuft%d" % i, _capsule(0.11, 0.42), hair,
						h + Vector3(s * 0.36, -0.10, 0.02), Vector3(0.0, 0.0, s * 0.25))
			_piece(body, "ponytail", _capsule(0.15, 0.68), hair, h + Vector3(0.0, -0.10, -0.46),
					Vector3(0.95, 0.0, 0.0))
			_piece(body, "tie", _cyl(0.10, 0.09), accent, h + Vector3(0.0, 0.10, -0.34),
					Vector3(PI * 0.5, 0.0, 0.0))


## Construit l'arme et RENVOIE ses points de prise {main, off}.
## Les bras iront ensuite chercher ces points : c'est ce qui fait que le brawler
## tient reellement son arme au lieu de la faire flotter a cote de lui.
func _weapon(kind: String, accent: Color, suit: Color, locked: bool) -> Dictionary:
	var w := -WAIST_Y
	var steel := Color("8d99ae") if not locked else Color("3a3f60")
	var wood := Color("8b5a2b") if not locked else Color("3a3f60")
	match kind:
		"gun":
			# fusil a pompe tenu en travers du corps, canon vers l'avant-gauche
			# tenu en travers du corps, presque parallele a l'ecran : c'est la
			# seule orientation ou la silhouette de l'arme se lit entierement
			var butt := Vector3(0.66, 1.18 + w, 0.26)
			var muzzle := Vector3(-0.60, 1.50 + w, 0.34)
			_bar(body, "gun_body", butt, muzzle.lerp(butt, 0.28), 0.17, 0.20, wood)
			_bar(body, "gun_barrel", butt.lerp(muzzle, 0.55), muzzle, 0.11, 0.11, steel)
			_bar(body, "gun_pump", butt.lerp(muzzle, 0.50), butt.lerp(muzzle, 0.72), 0.15, 0.16,
					steel.darkened(0.3))
			_piece(body, "gun_sight", _box(0.05, 0.07, 0.09), accent, muzzle.lerp(butt, 0.06))
			# les mains passent devant l'arme, sinon elles disparaissent derriere
			var fwd := Vector3(0.0, -0.02, 0.09)
			return {"main": butt.lerp(muzzle, 0.22) + fwd, "off": butt.lerp(muzzle, 0.62) + fwd}
		"hammer":
			var grip_lo := Vector3(0.44, 1.02 + w, 0.18)
			var top := Vector3(0.20, 2.36 + w, -0.10)
			_bar(body, "haft", grip_lo, top, 0.10, 0.10, wood)
			_piece(body, "head_hammer", _box(0.46, 0.34, 0.34), steel, top)
			_piece(body, "band", _box(0.12, 0.36, 0.36), accent, top)
			return {"main": grip_lo.lerp(top, 0.10), "off": grip_lo.lerp(top, 0.34)}
		"bow":
			var centre := Vector3(-0.50, 1.62 + w, 0.34)
			var t := TorusMesh.new()
			t.inner_radius = 0.40
			t.outer_radius = 0.48
			t.rings = 26
			t.ring_segments = 9
			_piece(body, "bow", t, wood, centre, Vector3(0.0, 0.0, PI * 0.5))
			_piece(body, "bow_string", _box(0.025, 0.88, 0.025), Color("efe6d2"),
					centre + Vector3(0.0, 0.0, 0.12), Vector3.ZERO, Vector3.ONE, 0.0)
			return {"main": centre + Vector3(0.0, -0.02, 0.0), "off": Vector3(0.06, 1.56 + w, 0.30)}
		"staff":
			var bot := Vector3(0.44, 0.10 + w, 0.10)
			var tip := Vector3(0.44, 2.42 + w, 0.10)
			_bar(body, "staff", bot, tip, 0.10, 0.10, suit.darkened(0.5))
			var orb := _piece(body, "orb", _sphere(0.28), accent, tip + Vector3(0.0, 0.22, 0.0))
			var om := toon(accent)
			om.emission_enabled = true
			om.emission = accent
			om.emission_energy_multiplier = 1.0
			orb.material_override = om
			return {"main": Vector3(0.44, 1.24 + w, 0.10), "off": Vector3(0.44, 1.62 + w, 0.10)}
		_:  # poings nus : les mains reposent le long du corps
			return {"main": Vector3(0.48, 1.06 + w, 0.10), "off": Vector3(-0.48, 1.06 + w, 0.10)}


func _arms(suit: Color, skin: Color, grips: Dictionary) -> void:
	var w := -WAIST_Y
	var fists := str(_data.get("weapon", "gun")) == "fist"
	var accent := _col(_data, "accent", Color("ffc531"), not bool(_data.get("unlocked", true)))
	for i in 2:
		var s := -1.0 if i == 0 else 1.0                # i = 0 -> gauche
		var shoulder := Vector3(s * SHOULDER.x, SHOULDER.y + w, 0.0)
		var hand: Vector3 = grips["off"] if i == 0 else grips["main"]
		# le coude se place a l'exterieur et legerement en arriere : c'est ce
		# leger decalage qui rend le bras credible au lieu d'etre un baton droit
		var elbow: Vector3 = (shoulder + hand) * 0.5 + Vector3(s * 0.20, -0.08, -0.10)
		_piece(body, "shoulder%d" % i, _sphere(0.185), suit.lightened(0.12), shoulder)
		_bone(body, "upperarm%d" % i, shoulder, elbow, 0.105, suit)
		_bone(body, "forearm%d" % i, elbow, hand, 0.092, suit.lightened(0.06))
		_piece(body, "elbow%d" % i, _sphere(0.10), suit, elbow)
		var hand_r := 0.20 if fists else 0.105
		_piece(body, "hand%d" % i, _sphere(hand_r), accent if fists else skin, hand,
				Vector3.ZERO, Vector3(1.0, 1.15, 1.0))


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

	# le corps entier : rebond + appui d'un pied sur l'autre
	position.y = sin(_t * 2.0) * 0.055
	rotation.y = sin(_t * 0.9) * 0.10 + (1.0 - clampf(_swap, 0.0, 1.0)) * -1.5
	rotation.z = sin(_t * 1.0) * 0.018
	var sc := lerpf(0.72, 1.0, e)
	scale = Vector3(sc, sc, sc)

	# buste : respiration et leger contre-balancement (l'arme suit, elle est
	# enfant du meme pivot, donc les mains ne quittent jamais la poignee)
	if body:
		body.rotation.y = sin(_t * 0.9 + 0.6) * 0.06
		body.rotation.x = sin(_t * 2.0) * 0.022
		var br := 1.0 + sin(_t * 2.0 + PI) * 0.022
		body.scale = Vector3(br, 1.0 / br, br)

	var head: MeshInstance3D = parts.get("head")
	if head:
		head.rotation.z = sin(_t * 0.75) * 0.05
		head.rotation.y = sin(_t * 0.55) * 0.09

	# clignement des yeux : le signal de vie le plus lisible
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
