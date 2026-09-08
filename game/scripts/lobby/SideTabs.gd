@tool
class_name SideTabs
extends Control
## Colonne de boutons collee a un bord de l'ecran (gauche ou droite),
## comme les onglets BOUTIQUE / BRAWLERS / INFOS / AMIS de Brawl Stars.

signal tab_pressed(id: String)

@export var tabs: Array[Dictionary] = []
@export var tab_size := Vector2(132, 64)
@export var gap := 8.0
@export var compact := false          # petit format (colonne de droite)

var _buttons: Array[ChunkyButton] = []


func setup(list: Array) -> void:
	tabs.clear()
	for t in list:
		tabs.append(t)
	_build()


func _ready() -> void:
	if _buttons.is_empty():
		_build()


func _build() -> void:
	for b in _buttons:
		b.queue_free()
	_buttons.clear()
	for i in tabs.size():
		var t: Dictionary = tabs[i]
		var b := ChunkyButton.new()
		b.base_color = t.get("color", UiSkin.PANEL_LIGHT)
		b.title = str(t.get("label", ""))
		b.icon_kind = str(t.get("icon", ""))
		b.vertical = true
		b.title_size = 13 if compact else 14
		b.corner_radius = 16
		b.lip = 7.0
		b.badge = int(t.get("badge", 0))
		b.size = tab_size
		b.position = Vector2(0.0, float(i) * (tab_size.y + gap))
		var id := str(t.get("id", ""))
		b.pressed.connect(func(): tab_pressed.emit(id))
		add_child(b)
		_buttons.append(b)
	custom_minimum_size = Vector2(tab_size.x,
			float(tabs.size()) * tab_size.y + float(maxi(tabs.size() - 1, 0)) * gap)


## Entree en cascade depuis le bord de l'ecran.
func play_intro(from_left: bool) -> void:
	for i in _buttons.size():
		var b := _buttons[i]
		b.modulate.a = 0.0
		b.pivot_offset = Vector2(0.0 if from_left else tab_size.x, tab_size.y * 0.5)
		b.scale = Vector2(0.4, 0.85)
		var tw := create_tween()
		tw.tween_interval(0.05 * float(i))
		tw.tween_property(b, "modulate:a", 1.0, 0.2)
		tw.parallel().tween_property(b, "scale", Vector2.ONE, 0.4) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
