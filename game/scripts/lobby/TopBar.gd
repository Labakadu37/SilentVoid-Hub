@tool
class_name TopBar
extends Control
## Bandeau du haut : profil, trophees, gemmes, pieces, reglages.

signal profile_pressed
signal settings_pressed
signal shop_shortcut(currency_id: String)

var _row: HBoxContainer
var _items: Array[Control] = []


func _ready() -> void:
	_row = HBoxContainer.new()
	_row.name = "Row"
	_row.anchor_right = 1.0
	_row.anchor_bottom = 1.0
	_row.add_theme_constant_override("separation", 10)
	add_child(_row)

	var profile := ProfileCard.new()
	profile.pressed.connect(func(): profile_pressed.emit())
	_row.add_child(profile)
	_items.append(profile)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_row.add_child(spacer)

	_add_pill("trophies", "trophy", false)
	_add_pill("gems", "gem", true)
	_add_pill("coins", "coin", true)

	var gear := ChunkyButton.new()
	gear.base_color = UiSkin.PANEL_LIGHT
	gear.icon_kind = "gear"
	gear.icon_color = UiSkin.TEXT_DIM
	gear.corner_radius = 18
	gear.lip = 6.0
	gear.custom_minimum_size = Vector2(60, 56)
	gear.pressed.connect(func(): settings_pressed.emit())
	_row.add_child(gear)
	_items.append(gear)


func _add_pill(id: String, icon: String, plus: bool) -> void:
	var pill := CurrencyPill.new()
	pill.currency_id = id
	pill.icon_kind = icon
	pill.show_plus = plus
	pill.custom_minimum_size = Vector2((168.0 if plus else 150.0), 56.0)
	pill.plus_pressed.connect(func(cid: String): shop_shortcut.emit(cid))
	_row.add_child(pill)
	_items.append(pill)


## Entree : le bandeau descend du haut.
func play_intro() -> void:
	for i in _items.size():
		var it := _items[i]
		it.modulate.a = 0.0
		it.scale = Vector2(0.9, 0.6)
		var tw := create_tween()
		tw.tween_interval(0.04 * float(i))
		tw.tween_property(it, "modulate:a", 1.0, 0.2)
		tw.parallel().tween_property(it, "scale", Vector2.ONE, 0.4) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
