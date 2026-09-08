@tool
class_name TopLeftBar
extends Control
## Coin haut-gauche, comme dans Brawl Stars : pastille de niveau, carte joueur,
## puis carte trophees avec la barre de rang.

signal profile_pressed
signal trophies_pressed

const H := 58.0

var _profile: Button
var _trophies: Button


func _ready() -> void:
	custom_minimum_size = Vector2(486, H)
	_profile = _hit(Rect2(64, 0, 182, H))
	_profile.pressed.connect(func(): profile_pressed.emit())
	_trophies = _hit(Rect2(254, 0, 226, H))
	_trophies.pressed.connect(func(): trophies_pressed.emit())


## Zone cliquable invisible : le rendu est fait dans _draw, on ne veut que le clic.
func _hit(r: Rect2) -> Button:
	var b := Button.new()
	b.flat = true
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	for s in ["normal", "hover", "pressed", "focus", "disabled"]:
		b.add_theme_stylebox_override(s, UiSkin.empty())
	b.position = r.position
	b.size = r.size
	add_child(b)
	return b


func _draw() -> void:
	var f := Painter.font(self)

	# pastille de niveau
	var lv := Rect2(Vector2(0, 2), Vector2(54, 54))
	Painter.card(self, lv, UiSkin.PURPLE, 14, 5, 5.0)
	Painter.text(self, f, lv, str(GameState.player_level), 26, UiSkin.TEXT, HORIZONTAL_ALIGNMENT_CENTER, 5)

	# carte joueur
	var pc := Rect2(Vector2(64, 2), Vector2(182, 54))
	Painter.card(self, pc, UiSkin.PANEL_DARK, 14, 5, 5.0)
	var av := Rect2(pc.position + Vector2(7, 7), Vector2(40, 40))
	Painter.rr(self, av, UiSkin.PURPLE.darkened(0.15), 10, 4, UiSkin.OUTLINE)
	Icons.draw(self, "brawler", av.grow(-7.0), UiSkin.TEXT)
	Painter.text(self, f, Rect2(pc.position + Vector2(54, 4), Vector2(120, 26)),
			GameState.player_name, 18, UiSkin.TEXT, HORIZONTAL_ALIGNMENT_LEFT, 4)
	Painter.text(self, f, Rect2(pc.position + Vector2(54, 28), Vector2(120, 20)),
			GameState.club_name, 12, UiSkin.TEXT_DIM, HORIZONTAL_ALIGNMENT_LEFT, 0)

	# carte trophees + barre de rang
	var tc := Rect2(Vector2(254, 2), Vector2(226, 54))
	Painter.card(self, tc, UiSkin.PANEL_DARK, 14, 5, 5.0)
	var ti := Rect2(tc.position + Vector2(7, 7), Vector2(40, 40))
	Painter.rr(self, ti, UiSkin.GOLD_DARK, 10, 4, UiSkin.OUTLINE)
	Icons.draw(self, "trophy", ti.grow(-7.0), UiSkin.GOLD)
	Painter.text(self, f, Rect2(tc.position + Vector2(54, 3), Vector2(164, 26)),
			GameState.format_number(int(GameState.currencies.get("trophies", 0))), 20,
			UiSkin.TEXT, HORIZONTAL_ALIGNMENT_LEFT, 4)
	Painter.bar(self, Rect2(tc.position + Vector2(54, 31), Vector2(160, 15)),
			GameState.rank_progress(), UiSkin.GOLD)
	Painter.text(self, f, Rect2(tc.position + Vector2(54, 30), Vector2(160, 17)),
			GameState.rank_label(), 11, UiSkin.TEXT, HORIZONTAL_ALIGNMENT_CENTER, 0)
