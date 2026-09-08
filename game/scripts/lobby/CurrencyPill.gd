@tool
class_name CurrencyPill
extends Control
## Compteur de monnaie du bandeau haut (icone + nombre + bouton "+").

signal plus_pressed(id: String)

@export var currency_id := "gems":
	set(value):
		currency_id = value
		queue_redraw()
@export var icon_kind := "gem"
@export var show_plus := true

var _display := 0.0     # valeur affichee, anime vers la vraie valeur
var _plus: ChunkyButton = null


func _ready() -> void:
	custom_minimum_size = Vector2(150, 56)
	mouse_filter = Control.MOUSE_FILTER_PASS
	_display = float(GameState.currencies.get(currency_id, 0))
	if not Engine.is_editor_hint():
		GameState.currency_changed.connect(_on_currency_changed)
	if show_plus:
		_plus = ChunkyButton.new()
		_plus.base_color = UiSkin.GREEN
		_plus.icon_kind = "plus"
		_plus.corner_radius = 14
		_plus.lip = 5.0
		_plus.custom_minimum_size = Vector2(40, 40)
		_plus.pressed.connect(func(): plus_pressed.emit(currency_id))
		add_child(_plus)
	resized.connect(_layout)
	_layout()
	set_process(not Engine.is_editor_hint())


func _layout() -> void:
	if _plus:
		_plus.size = Vector2(40, 40)
		_plus.position = Vector2(size.x - 46.0, (size.y - 40.0) * 0.5)
	queue_redraw()


func _on_currency_changed(id: String, value: int) -> void:
	if id != currency_id:
		return
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "_display", float(value), 0.5)
	tw.parallel().tween_property(self, "scale", Vector2(1.12, 1.12), 0.12)
	tw.chain().tween_property(self, "scale", Vector2.ONE, 0.18)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var pad := 46.0 if show_plus else 12.0
	Painter.rr(self, Rect2(Vector2.ZERO, size), UiSkin.PANEL_DARK, 18, 3, UiSkin.OUTLINE)
	var ir := Rect2(Vector2(8.0, (size.y - 34.0) * 0.5), Vector2(34, 34))
	Icons.draw(self, icon_kind, ir, UiSkin.currency_color(currency_id))
	var f := Painter.font(self)
	var tr := Rect2(Vector2(48.0, 0.0), Vector2(size.x - 48.0 - pad, size.y))
	Painter.text(self, f, tr, GameState.format_number(int(round(_display))), 21,
			UiSkin.TEXT, HORIZONTAL_ALIGNMENT_LEFT, 4)
