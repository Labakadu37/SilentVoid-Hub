@tool
class_name ProfileCard
extends Button
## Carte joueur en haut a gauche : avatar, pseudo, niveau et barre d'XP.

func _ready() -> void:
	custom_minimum_size = Vector2(258, 60)
	focus_mode = Control.FOCUS_NONE
	text = ""
	for s in ["normal", "hover", "pressed", "focus", "disabled"]:
		add_theme_stylebox_override(s, UiSkin.empty())
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _draw() -> void:
	var f := Painter.font(self)
	Painter.rr(self, Rect2(Vector2.ZERO, size), UiSkin.PANEL_DARK, 18, 3, UiSkin.OUTLINE)

	# avatar
	var av := Rect2(Vector2(6, 6), Vector2(size.y - 12.0, size.y - 12.0))
	Painter.rr(self, av, UiSkin.PURPLE.darkened(0.2), 14, 3, UiSkin.OUTLINE)
	Icons.draw(self, "brawler", av.grow(-8.0), UiSkin.TEXT)

	# badge niveau
	var lv := Rect2(av.position + Vector2(av.size.x - 16.0, av.size.y - 18.0), Vector2(28, 22))
	Painter.rr(self, lv, UiSkin.GOLD, 8, 3, UiSkin.OUTLINE)
	Painter.text(self, f, lv, str(GameState.player_level), 14, UiSkin.OUTLINE, HORIZONTAL_ALIGNMENT_CENTER, 0)

	var x := av.position.x + av.size.x + 12.0
	var w := size.x - x - 12.0
	Painter.text(self, f, Rect2(Vector2(x, 8.0), Vector2(w, 24.0)), GameState.player_name, 19,
			UiSkin.TEXT, HORIZONTAL_ALIGNMENT_LEFT, 4)
	Painter.bar(self, Rect2(Vector2(x, 36.0), Vector2(w, 14.0)), GameState.player_xp, UiSkin.CYAN)
	Painter.text(self, f, Rect2(Vector2(x, 34.0), Vector2(w, 18.0)),
			"%d%%" % int(GameState.player_xp * 100.0), 11, UiSkin.TEXT, HORIZONTAL_ALIGNMENT_CENTER, 0)
