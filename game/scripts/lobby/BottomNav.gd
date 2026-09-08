@tool
class_name BottomNav
extends Control
## Barre de navigation du bas : Boutique / Persos / News / Club / Chat.

signal tab_pressed(id: String)

const TABS := [
	{"id": "shop", "label": "BOUTIQUE", "icon": "shop", "color": Color("ff8c1a"), "badge": 2},
	{"id": "brawlers", "label": "PERSOS", "icon": "brawler", "color": Color("a855f7"), "badge": 0},
	{"id": "news", "label": "NEWS", "icon": "news", "color": Color("3ba7ff"), "badge": 1},
	{"id": "club", "label": "CLUB", "icon": "club", "color": Color("3ddc84"), "badge": 0},
	{"id": "chat", "label": "CHAT", "icon": "chat", "color": Color("ff4d6d"), "badge": 5},
]

var _buttons: Array[ChunkyButton] = []


func _ready() -> void:
	var row := HBoxContainer.new()
	row.name = "Row"
	row.anchor_right = 1.0
	row.anchor_bottom = 1.0
	row.add_theme_constant_override("separation", 10)
	add_child(row)

	for tab in TABS:
		var b := ChunkyButton.new()
		b.base_color = tab["color"]
		b.title = tab["label"]
		b.icon_kind = tab["icon"]
		b.vertical = true
		b.title_size = 15
		b.corner_radius = 18
		b.lip = 8.0
		b.badge = int(tab["badge"])
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.size_flags_vertical = Control.SIZE_EXPAND_FILL
		var id := str(tab["id"])
		b.pressed.connect(func(): tab_pressed.emit(id))
		row.add_child(b)
		_buttons.append(b)


## Entree en cascade depuis le bas.
func play_intro() -> void:
	for i in _buttons.size():
		var b := _buttons[i]
		b.modulate.a = 0.0
		b.scale = Vector2(0.8, 0.6)
		var tw := create_tween()
		tw.tween_interval(0.05 * float(i))
		tw.tween_property(b, "modulate:a", 1.0, 0.2)
		tw.parallel().tween_property(b, "scale", Vector2.ONE, 0.4) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
