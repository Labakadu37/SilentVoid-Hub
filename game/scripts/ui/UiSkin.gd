@tool
class_name UiSkin
extends RefCounted
## Palette + fabriques de StyleBox. Un seul endroit pour changer toute la DA.

# --- Fond ---------------------------------------------------------------
const BG_TOP := Color("41288f")
const BG_BOTTOM := Color("120a2b")
const BG_GLOW := Color("7b4ae0")

# --- Panneaux -----------------------------------------------------------
const PANEL := Color("241a4e")
const PANEL_DARK := Color("1a1238")
const PANEL_LIGHT := Color("342a6e")
const OUTLINE := Color("0d0720")

# --- Accents ------------------------------------------------------------
const GOLD := Color("ffd23f")
const GOLD_DARK := Color("d98600")
const GREEN := Color("3ddc84")
const RED := Color("ff4d6d")
const BLUE := Color("3ba7ff")
const PURPLE := Color("a855f7")
const ORANGE := Color("ff8c1a")
const CYAN := Color("22d3ee")

# --- Texte --------------------------------------------------------------
const TEXT := Color("ffffff")
const TEXT_DIM := Color("b9aee0")

static var _boxes := {}


## StyleBoxFlat arrondi, mis en cache (appele depuis _draw a chaque frame).
static func box(color: Color, radius: int = 18, border: int = 0, border_color: Color = OUTLINE) -> StyleBoxFlat:
	var key := "%s|%d|%d|%s" % [color.to_html(), radius, border, border_color.to_html()]
	if _boxes.has(key):
		return _boxes[key]
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.set_corner_radius_all(radius)
	if border > 0:
		sb.set_border_width_all(border)
		sb.border_color = border_color
	sb.anti_aliasing = true
	_boxes[key] = sb
	return sb


## Variante avec des rayons differents en haut et en bas (pour les reflets).
static func box_top(color: Color, radius: int) -> StyleBoxFlat:
	var key := "top|%s|%d" % [color.to_html(), radius]
	if _boxes.has(key):
		return _boxes[key]
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.corner_radius_top_left = radius
	sb.corner_radius_top_right = radius
	sb.corner_radius_bottom_left = int(radius * 0.35)
	sb.corner_radius_bottom_right = int(radius * 0.35)
	sb.anti_aliasing = true
	_boxes[key] = sb
	return sb


static func empty() -> StyleBoxEmpty:
	return StyleBoxEmpty.new()


## Couleur associee a une monnaie.
static func currency_color(id: String) -> Color:
	match id:
		"trophies": return GOLD
		"gems": return GREEN
		"coins": return Color("ffb300")
		"tickets": return CYAN
	return TEXT
