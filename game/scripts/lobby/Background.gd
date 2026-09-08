@tool
class_name LobbyBackground
extends Control
## Fond du lobby : degrade vertical, halos, et confettis qui flottent.

const CONFETTI := 46

var _t := 0.0
var _bits: Array[Dictionary] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_spawn()
	set_process(not Engine.is_editor_hint())


func _spawn() -> void:
	_bits.clear()
	var palette := [UiSkin.GOLD, UiSkin.PURPLE, UiSkin.CYAN, UiSkin.GREEN, UiSkin.RED]
	for i in CONFETTI:
		_bits.append({
			"x": randf(), "y": randf(),
			"speed": randf_range(0.012, 0.045),
			"size": randf_range(4.0, 11.0),
			"spin": randf_range(-2.5, 2.5),
			"phase": randf() * TAU,
			"color": palette[i % palette.size()],
		})


func _process(delta: float) -> void:
	_t += delta
	for b in _bits:
		b["y"] = fposmod(float(b["y"]) - float(b["speed"]) * delta * 6.0, 1.2) 
	queue_redraw()


func _draw() -> void:
	# degrade vertical en bandes (aucune texture a importer)
	var steps := 40
	for i in steps:
		var t := float(i) / float(steps - 1)
		var col := UiSkin.BG_TOP.lerp(UiSkin.BG_BOTTOM, pow(t, 0.85))
		self.draw_rect(Rect2(0.0, size.y * float(i) / float(steps) - 1.0,
				size.x, size.y / float(steps) + 2.0), col)

	# halos derriere le perso
	Painter.glow(self, Vector2(size.x * 0.58, size.y * 0.46), size.y * 0.62, Color(UiSkin.BG_GLOW, 0.55))
	Painter.glow(self, Vector2(size.x * 0.12, size.y * 0.08), size.y * 0.35, Color(UiSkin.PURPLE, 0.35))

	# confettis
	for b in _bits:
		var pos := Vector2(float(b["x"]) * size.x + sin(_t * 0.7 + float(b["phase"])) * 18.0,
				float(b["y"]) * size.y)
		var s: float = b["size"]
		self.draw_set_transform(pos, _t * float(b["spin"]), Vector2.ONE)
		var c: Color = b["color"]
		c.a = 0.35
		self.draw_rect(Rect2(-s * 0.5, -s * 0.25, s, s * 0.5), c)
		self.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
