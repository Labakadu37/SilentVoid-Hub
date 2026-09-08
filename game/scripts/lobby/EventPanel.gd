@tool
class_name EventPanel
extends Control
## Colonne de gauche : la liste des evenements en cours.

var _cards: Array[EventCard] = []


func _ready() -> void:
	_build()
	if not Engine.is_editor_hint():
		GameState.mode_selected.connect(_on_mode_selected)


func _build() -> void:
	for c in get_children():
		c.queue_free()
	_cards.clear()

	var title := Label.new()
	title.text = "EVENEMENTS"
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", UiSkin.TEXT)
	title.add_theme_color_override("font_outline_color", UiSkin.OUTLINE)
	title.add_theme_constant_override("outline_size", 5)
	title.position = Vector2(6, 0)
	title.size = Vector2(size.x, 24)
	add_child(title)

	var list := VBoxContainer.new()
	list.name = "List"
	list.add_theme_constant_override("separation", 10)
	list.anchor_right = 1.0
	list.anchor_bottom = 1.0
	list.offset_top = 28.0
	add_child(list)

	for i in GameState.modes.size():
		var card := EventCard.new()
		list.add_child(card)
		card.setup(i, GameState.modes[i])
		card.selected = (i == GameState.selected_mode)
		card.card_selected.connect(func(index: int): GameState.select_mode(index))
		_cards.append(card)


func _on_mode_selected(index: int) -> void:
	for c in _cards:
		c.selected = (c.mode_index == index)


## Animation d'entree : les cartes apparaissent en cascade.
## (on anime scale/modulate, pas position : le VBoxContainer gere les positions)
func play_intro() -> void:
	for i in _cards.size():
		var card := _cards[i]
		var final_scale := Vector2.ONE * (1.05 if card.selected else 1.0)
		card.modulate.a = 0.0
		card.scale = Vector2(0.72, 0.9)
		var tw := create_tween()
		tw.tween_interval(0.06 * float(i))
		tw.tween_property(card, "modulate:a", 1.0, 0.22)
		tw.parallel().tween_property(card, "scale", final_scale, 0.38) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
