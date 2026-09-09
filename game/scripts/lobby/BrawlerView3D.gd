@tool
class_name BrawlerView3D
extends SubViewportContainer
## Affiche le brawler 3D dans le lobby 2D.
##
## Un SubViewport a fond transparent contient la scene 3D (modele, camera,
## lumieres). Le decor dessine du lobby reste donc visible derriere le
## personnage, comme dans Brawl Stars ou seul le brawler est en volume.

@export var data: Dictionary = {}:
	set(value):
		data = value
		_rebuild()
@export var locked := false:
	set(value):
		locked = value
		_rebuild()

var _vp: SubViewport
var _model: BrawlerModel3D
var _cam: Camera3D


func _ready() -> void:
	stretch = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_setup()
	_rebuild()


func _setup() -> void:
	if _vp != null:
		return
	_vp = SubViewport.new()
	_vp.transparent_bg = true
	_vp.msaa_3d = Viewport.MSAA_4X
	_vp.own_world_3d = true
	_vp.handle_input_locally = false
	_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_vp)

	var env := Environment.new()
	env.background_mode = Environment.BG_CLEAR_COLOR
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("cbd3e4")
	env.ambient_light_energy = 0.45
	var we := WorldEnvironment.new()
	we.environment = env
	_vp.add_child(we)

	_cam = Camera3D.new()
	_cam.fov = 26.0
	_cam.position = Vector3(0.0, 1.32, 6.2)
	_cam.look_at_from_position(Vector3(0.0, 1.32, 6.2), Vector3(0.0, 1.28, 0.0), Vector3.UP)
	_vp.add_child(_cam)

	# lumiere principale, chaude, venant d'en haut a gauche
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-38.0, 34.0, 0.0)
	key.light_energy = 1.75
	key.light_color = Color("fff2d8")
	key.shadow_enabled = true
	key.directional_shadow_max_distance = 20.0
	_vp.add_child(key)

	# lumiere d'appoint, froide, de l'autre cote : elle detache la silhouette
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-12.0, -128.0, 0.0)
	fill.light_energy = 0.55
	fill.light_color = Color("bcd6ff")
	_vp.add_child(fill)

	# contre-jour : detache le brawler du decor, comme un projecteur derriere lui
	var rim := DirectionalLight3D.new()
	rim.rotation_degrees = Vector3(-8.0, 178.0, 0.0)
	rim.light_energy = 1.1
	rim.light_color = Color("ffe6b0")
	_vp.add_child(rim)

	_model = BrawlerModel3D.new()
	_vp.add_child(_model)


func _rebuild() -> void:
	if _model == null:
		return
	var d := data.duplicate()
	d["unlocked"] = not locked
	_model.build(d)


func play_swap() -> void:
	if _model:
		_model.play_swap()
