@tool
class_name UiSkin
extends RefCounted
## Palette + fabriques de StyleBox. Un seul endroit pour changer toute la DA.
##
## Direction artistique : une arene couverte, bois chaud et panneaux verts,
## eclairee par des projecteurs. Zero bleu de fond, coins assombris (vignette),
## panneaux tres contrastes avec de gros contours noirs.

# --- Decor --------------------------------------------------------------
const HALL_TOP := Color("357a44")
const HALL := Color("276036")
const HALL_DARK := Color("173a20")
const FLOOR := Color("a76c33")
const FLOOR_DARK := Color("87542a")
const FLOOR_LIGHT := Color("c48d48")
const SPOT := Color("fff2c0")
const DUST := Color("ffe9a8")

# --- Panneaux -----------------------------------------------------------
const PANEL := Color("2a3050")
const PANEL_DARK := Color("161a33")
const PANEL_LIGHT := Color("3c456e")
const OUTLINE := Color("0a0c18")

# --- Accents ------------------------------------------------------------
const GOLD := Color("ffc531")
const GOLD_DARK := Color("e08a00")
const ORANGE := Color("ff8a2b")
const RED := Color("f5476a")
const GREEN := Color("35d07f")
const BLUE := Color("2fa8ff")
const PURPLE := Color("9b5cf0")
const CYAN := Color("2fd9e0")
const CREAM := Color("fff3d6")

# --- Texte --------------------------------------------------------------
const TEXT := Color("ffffff")
const TEXT_DIM := Color("bcc3dd")

## Couleurs de la foule / des confettis.
const CROWD := [
	Color("ff8a2b"), Color("f5476a"), Color("ffc531"), Color("35d07f"),
	Color("2fa8ff"), Color("fff3d6"), Color("9b5cf0"),
]

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
		"power": return PURPLE
		"tickets": return CYAN
	return TEXT
