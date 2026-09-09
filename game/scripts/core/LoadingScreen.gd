@tool
class_name LoadingScreen
extends Control
## Ecran de chargement au demarrage.
##
## La barre n'est pas decorative : 60 % suivent le chargement reel des scenes,
## 40 % la tentative de connexion au serveur. Quand les deux sont finis (et
## qu'un temps minimum s'est ecoule pour eviter le flash), on passe au lobby.

signal finished

const MIN_TIME := 1.6
const NET_TIMEOUT := 3.0

const LOGO_PATH := "res://assets/ui/logo.png"

static var _logo: Texture2D = null
static var _logo_checked := false

const TIPS := [
	"Le Vide ronge l'arene : ce n'est pas le decor, c'est le chrono.",
	"Tuer ne rapporte aucun point. Ca fait juste perdre du terrain a l'autre.",
	"Une Ancre tenue a trois freine le Vide deux fois plus vite.",
	"La Balise gele le Vide 8 s. Gardez-la pour la fin de manche.",
	"VOID devient invisible 1,5 s apres son Super. De quoi replacer une Ancre.",
	"Porter beaucoup d'Eclats, c'est devenir la cible de toute l'equipe d'en face.",
]

var _t := 0.0
var _tip := 0
var _tip_timer := 0.0
var _res_progress := 0.0
var _net_progress := 0.0
var _net_deadline := 0.0
var _done := false
var _scene_path := ""


func begin(scene_path: String) -> void:
	_scene_path = scene_path
	_tip = randi() % TIPS.size()
	_net_deadline = NET_TIMEOUT
	ResourceLoader.load_threaded_request(scene_path)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_process(not Engine.is_editor_hint())


func get_loaded_scene() -> PackedScene:
	if _scene_path.is_empty():
		return null
	return ResourceLoader.load_threaded_get(_scene_path) as PackedScene


func _process(delta: float) -> void:
	_t += delta
	_tip_timer += delta
	if _tip_timer > 3.2:
		_tip_timer = 0.0
		_tip = (_tip + 1) % TIPS.size()

	# progression reelle du chargement
	if not _scene_path.is_empty():
		var p := []
		var st := ResourceLoader.load_threaded_get_status(_scene_path, p)
		if st == ResourceLoader.THREAD_LOAD_LOADED:
			_res_progress = 1.0
		elif not p.is_empty():
			_res_progress = float(p[0])

	# progression de la connexion
	_net_deadline -= delta
	if Net.state == Net.State.ONLINE or Net.state == Net.State.OFFLINE:
		_net_progress = 1.0
	else:
		_net_progress = clampf(1.0 - _net_deadline / NET_TIMEOUT, 0.0, 0.95)
	if _net_deadline <= 0.0:
		_net_progress = 1.0

	if not _done and _t >= MIN_TIME and _res_progress >= 1.0 and _net_progress >= 1.0:
		_done = true
		var tw := create_tween()
		tw.tween_property(self, "modulate:a", 0.0, 0.35)
		tw.tween_callback(func(): finished.emit())
	queue_redraw()


func progress() -> float:
	return clampf(_res_progress * 0.6 + _net_progress * 0.4, 0.0, 1.0)


func _draw() -> void:
	var f := Painter.font(self)
	var c := Vector2(size.x * 0.5, size.y * 0.42)

	# fond : le Vide qui tourne
	self.draw_rect(Rect2(Vector2.ZERO, size), Color("0d0a1c"))
	for i in 5:
		var rad := size.y * (0.62 - float(i) * 0.09)
		self.draw_arc(c, rad, _t * (0.25 + float(i) * 0.12), _t * (0.25 + float(i) * 0.12) + PI * 1.4,
				48, Color(UiSkin.PURPLE, 0.13 + float(i) * 0.03), 14.0 - float(i) * 1.6)
	Painter.glow(self, c, size.y * 0.46, Color(UiSkin.CYAN, 0.30))

	# logo du jeu (image fournie), sinon on retombe sur le titre dessine
	var logo := _get_logo()
	if logo != null:
		var lw := minf(size.x * 0.52, 620.0)
		var lh := lw * float(logo.get_height()) / float(logo.get_width())
		var lr := Rect2(Vector2((size.x - lw) * 0.5, c.y - lh * 0.46), Vector2(lw, lh))
		self.draw_texture_rect(logo, lr, false)
	else:
		var r := size.y * 0.10
		self.draw_circle(c, r * 1.18, Color(0, 0, 0, 0.45))
		self.draw_arc(c, r, 0.0, TAU, 48, UiSkin.CYAN, 6.0)
		Icons.draw(self, "shard", Rect2(c - Vector2(r, r) * 0.72, Vector2(r, r) * 1.44), UiSkin.CYAN)
		Painter.text(self, f, Rect2(Vector2(0, c.y + size.y * 0.135), Vector2(size.x, 34)),
				GameState.TITLE_TOP, 26, UiSkin.CYAN, HORIZONTAL_ALIGNMENT_CENTER, 6)
		Painter.text(self, f, Rect2(Vector2(0, c.y + size.y * 0.185), Vector2(size.x, 70)),
				GameState.TITLE_MAIN, 60, UiSkin.TEXT, HORIZONTAL_ALIGNMENT_CENTER, 9,
				UiSkin.OUTLINE, 4.0)

	# barre de progression
	var bw := minf(size.x * 0.46, 520.0)
	var bar := Rect2(Vector2((size.x - bw) * 0.5, size.y * 0.80), Vector2(bw, 26))
	Painter.rr(self, bar, Color(0, 0, 0, 0.55), 13, 4, UiSkin.rim(UiSkin.CYAN))
	var p := progress()
	if p > 0.01:
		var inner := Rect2(bar.position + Vector2(4, 4), Vector2(maxf((bar.size.x - 8.0) * p, 18.0), 18))
		Painter.vgrad(self, inner, UiSkin.CYAN, 9, 0.40, 0.20)
	Painter.text(self, f, bar, "%d %%" % int(p * 100.0), 14, UiSkin.TEXT, HORIZONTAL_ALIGNMENT_CENTER, 3)

	# astuce
	Painter.text(self, f, Rect2(Vector2(size.x * 0.1, size.y * 0.88), Vector2(size.x * 0.8, 24)),
			TIPS[_tip], 14, UiSkin.TEXT_DIM, HORIZONTAL_ALIGNMENT_CENTER, 0)
	Painter.text(self, f, Rect2(Vector2(0, size.y - 26.0), Vector2(size.x - 14.0, 20)),
			"v%s" % str(ProjectSettings.get_setting("application/config/version", "0.1.0")),
			12, Color(1, 1, 1, 0.35), HORIZONTAL_ALIGNMENT_RIGHT, 0)


## Charge le logo une seule fois. Absent, l'ecran retombe sur le titre dessine.
static func _get_logo() -> Texture2D:
	if not _logo_checked:
		_logo_checked = true
		if ResourceLoader.exists(LOGO_PATH):
			var res := load(LOGO_PATH)
			if res is Texture2D:
				_logo = res
	return _logo
