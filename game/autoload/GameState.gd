@tool
extends Node
## Etat global du joueur : monnaies, persos, modes de jeu.
## Autoload -> accessible partout via `GameState`.

signal currency_changed(id: String, value: int)
signal brawler_selected(index: int)
signal mode_selected(index: int)
signal match_requested(mode: Dictionary)   # le joueur a appuye sur JOUER
signal match_started(mode: Dictionary)     # le matchmaking est termine

const SAVE_PATH := "user://silentvoid_profile.json"

var player_name := "SilentVoid"
var player_level := 37
var player_xp := 0.62          # progression 0..1 vers le niveau suivant
var club_name := "SILENT VOID"

var currencies := {
	"trophies": 12480,
	"gems": 148,
	"coins": 3260,
	"power": 9225,
	"tickets": 12,
}

# Passe de combat
var pass_level := 27
var pass_xp := 795
var pass_xp_needed := 950

## Paliers de rang, comme les ligues de trophees.
const RANKS := [
	{"name": "BRONZE", "at": 0}, {"name": "ARGENT", "at": 2000},
	{"name": "OR", "at": 5000}, {"name": "PLATINE", "at": 9000},
	{"name": "DIAMANT", "at": 14000}, {"name": "MAITRE", "at": 20000},
]

var brawlers: Array[Dictionary] = []
var modes: Array[Dictionary] = []
var selected_brawler := 0
var selected_mode := 0


func _ready() -> void:
	_build_brawlers()
	_build_modes()
	load_profile()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	# Les evenements tournent en temps reel comme dans Brawl Stars.
	for m in modes:
		m["timer"] = maxf(0.0, float(m["timer"]) - delta)
		if m["timer"] <= 0.0:
			m["timer"] = randf_range(1800.0, 14400.0)


# ---------------------------------------------------------------- donnees

func _build_brawlers() -> void:
	brawlers = [
		# ---- Le brawler signature du jeu -------------------------------------
		{
			"name": "VOID", "rarity": "LEGENDAIRE", "rarity_color": Color("ffc531"),
			"role": "ASSASSIN", "power": 11, "trophies": 940, "unlocked": true, "price": 0,
			"skin": Color("e8d5ff"), "suit": Color("6d28d9"), "accent": Color("2fd9e0"),
			"hair": Color("241a4e"), "weapon": "staff", "hat": "hood", "cape": true, "glow_eyes": true,
			"hp": 3600, "damage": 360, "shots": 3, "reload": 1.5, "range": 6.5, "speed": 820,
			"attack": "ECLAT DE NEANT",
			"attack_desc": "Projette trois eclats en cone. Plus on est pres, plus ils touchent.",
			"super": "FAILLE",
			"super_desc": "Traverse les murs jusqu'au point vise et inflige des degats a l'arrivee.",
			"gadget": "SILENCE",
			"gadget_desc": "Devient inciblable pendant 1 seconde et recupere 1200 PV.",
			"star_power": "OMBRE PORTEE",
			"star_power_desc": "Invisible 1,5 seconde apres chaque Super.",
			"tagline": "Frappe, disparait, recommence.",
		},
		{
			"name": "SHELDY", "rarity": "MYTHIQUE", "rarity_color": Color("f5476a"),
			"role": "COMBATTANT", "power": 9, "trophies": 812, "unlocked": true, "price": 0,
			"skin": Color("f5c69a"), "suit": Color("f5476a"), "accent": Color("ffc531"),
			"hair": Color("3b2a1a"), "weapon": "gun", "hat": "cap", "cape": false,
			"hp": 4200, "damage": 300, "shots": 5, "reload": 1.4, "range": 5.0, "speed": 770,
			"attack": "GERBE DE PLOMB", "super": "DOUBLE CANON",
			"gadget": "RECUL", "star_power": "CHARGEUR RAPIDE",
			"tagline": "Fusil a dispersion, redoutable au corps a corps.",
		},
		{
			"name": "BRUTUS", "rarity": "EPIQUE", "rarity_color": Color("9b5cf0"),
			"role": "TANK", "power": 8, "trophies": 655, "unlocked": true, "price": 0,
			"skin": Color("c98a5b"), "suit": Color("ff8a2b"), "accent": Color("2a3050"),
			"hair": Color("161a33"), "weapon": "hammer", "hat": "helmet", "cape": false,
			"hp": 7600, "damage": 1120, "shots": 1, "reload": 1.8, "range": 2.4, "speed": 720,
			"attack": "COUP DE MASSE", "super": "ONDE DE CHOC",
			"gadget": "SECOND SOUFFLE", "star_power": "PEAU DE FER",
			"tagline": "Encaisse tout et renvoie encore plus fort.",
		},
		{
			"name": "NOVA", "rarity": "SUPER RARE", "rarity_color": Color("2fa8ff"),
			"role": "SNIPER", "power": 7, "trophies": 501, "unlocked": true, "price": 0,
			"skin": Color("ffd9c0"), "suit": Color("2fd9e0"), "accent": Color("ffffff"),
			"hair": Color("f5476a"), "weapon": "bow", "hat": "hair", "cape": false,
			"hp": 2800, "damage": 1500, "shots": 1, "reload": 1.9, "range": 10.0, "speed": 770,
			"attack": "TIR TENDU", "super": "PLUIE DE FLECHES",
			"gadget": "PAS DE COTE", "star_power": "OEIL DE LYNX",
			"tagline": "Longue portee. Fragile mais mortelle.",
		},
		{
			"name": "PIXO", "rarity": "RARE", "rarity_color": Color("35d07f"),
			"role": "RAPIDE", "power": 6, "trophies": 320, "unlocked": true, "price": 0,
			"skin": Color("ffe0b2"), "suit": Color("35d07f"), "accent": Color("ffc531"),
			"hair": Color("2a3050"), "weapon": "fist", "hat": "cap", "cape": false,
			"hp": 3400, "damage": 220, "shots": 4, "reload": 1.0, "range": 3.2, "speed": 900,
			"attack": "RAFALE DE POINGS", "super": "CHARGE",
			"gadget": "SPRINT", "star_power": "SECOND POING",
			"tagline": "Colle a l'adversaire et ne lache plus.",
		},
		{
			"name": "ZENTY", "rarity": "CHROMATIQUE", "rarity_color": Color("2fd9e0"),
			"role": "SUPPORT", "power": 1, "trophies": 0, "unlocked": false, "price": 950,
			"skin": Color("d7f9ff"), "suit": Color("2fa8ff"), "accent": Color("ffc531"),
			"hair": Color("161a33"), "weapon": "staff", "hat": "crown", "cape": true,
			"hp": 3000, "damage": 240, "shots": 3, "reload": 1.6, "range": 6.0, "speed": 790,
			"attack": "ONDE DE SOIN", "super": "BOUCLIER D'EQUIPE",
			"gadget": "RAPPEL", "star_power": "AURA",
			"tagline": "Nouveau. Disponible dans l'offre de la boutique.",
		},
	]


func _build_modes() -> void:
	modes = [
		{
			"id": "gems", "name": "RAZZIA DE GEMMES", "map": "Mine Hantee",
			"color": Color("a855f7"), "icon": "gem", "team": "3v3", "slots": 6,
			"timer": 3.0 * 3600.0 + 742.0, "reward": "Coffre", "special": false,
		},
		{
			"id": "ball", "name": "BRAWLBALL", "map": "Stade Central",
			"color": Color("3ba7ff"), "icon": "ball", "team": "3v3", "slots": 6,
			"timer": 1.0 * 3600.0 + 1256.0, "reward": "Coffre", "special": false,
		},
		{
			"id": "solo", "name": "SURVIVANT", "map": "Zone Toxique",
			"color": Color("ff4d6d"), "icon": "skull", "team": "SOLO", "slots": 10,
			"timer": 5.0 * 3600.0 + 88.0, "reward": "Coffre", "special": false,
		},
		{
			"id": "heist", "name": "BRAQUAGE", "map": "Coffre-Fort",
			"color": Color("ff8c1a"), "icon": "coin", "team": "3v3", "slots": 6,
			"timer": 2.0 * 3600.0 + 410.0, "reward": "x2 Trophees", "special": true,
		},
	]


# ---------------------------------------------------------------- acces

func current_brawler() -> Dictionary:
	return brawlers[clampi(selected_brawler, 0, brawlers.size() - 1)]


func current_mode() -> Dictionary:
	return modes[clampi(selected_mode, 0, modes.size() - 1)]


func select_brawler(index: int) -> void:
	var i := wrapi(index, 0, brawlers.size())
	if i == selected_brawler:
		return
	selected_brawler = i
	brawler_selected.emit(i)
	save_profile()


func select_mode(index: int) -> void:
	var i := clampi(index, 0, modes.size() - 1)
	if i == selected_mode:
		return
	selected_mode = i
	mode_selected.emit(i)
	save_profile()


func add_currency(id: String, amount: int) -> void:
	currencies[id] = int(currencies.get(id, 0)) + amount
	currency_changed.emit(id, currencies[id])
	save_profile()


func spend(id: String, amount: int) -> bool:
	if int(currencies.get(id, 0)) < amount:
		return false
	add_currency(id, -amount)
	return true


func request_match() -> void:
	match_requested.emit(current_mode())


func start_match() -> void:
	match_started.emit(current_mode())


## Progression 0..1 a l'interieur du palier de rang courant.
func rank_progress() -> float:
	var t := int(currencies.get("trophies", 0))
	for i in range(RANKS.size() - 1, -1, -1):
		if t >= int(RANKS[i]["at"]):
			if i == RANKS.size() - 1:
				return 1.0
			var lo := float(RANKS[i]["at"])
			var hi := float(RANKS[i + 1]["at"])
			return clampf((float(t) - lo) / maxf(hi - lo, 1.0), 0.0, 1.0)
	return 0.0


func rank_label() -> String:
	var t := int(currencies.get("trophies", 0))
	var name := str(RANKS[0]["name"])
	for r in RANKS:
		if t >= int(r["at"]):
			name = str(r["name"])
	return name


func pass_progress() -> float:
	return clampf(float(pass_xp) / maxf(float(pass_xp_needed), 1.0), 0.0, 1.0)


# ---------------------------------------------------------------- utils

static func format_timer(seconds: float) -> String:
	var s := int(seconds)
	if s >= 3600:
		return "%dh %02dm" % [s / 3600, (s % 3600) / 60]
	return "%02dm %02ds" % [s / 60, s % 60]


static func format_number(value: int) -> String:
	var s := str(absi(value))
	var out := ""
	var count := 0
	for i in range(s.length() - 1, -1, -1):
		out = s[i] + out
		count += 1
		if count % 3 == 0 and i > 0:
			out = " " + out
	return ("-" if value < 0 else "") + out


# ---------------------------------------------------------------- sauvegarde

func save_profile() -> void:
	if Engine.is_editor_hint():
		return
	var data := {
		"player_name": player_name,
		"player_level": player_level,
		"currencies": currencies,
		"selected_brawler": selected_brawler,
		"selected_mode": selected_mode,
	}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data, "\t"))
		f.close()


func load_profile() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	player_name = str(parsed.get("player_name", player_name))
	player_level = int(parsed.get("player_level", player_level))
	selected_brawler = clampi(int(parsed.get("selected_brawler", 0)), 0, brawlers.size() - 1)
	selected_mode = clampi(int(parsed.get("selected_mode", 0)), 0, modes.size() - 1)
	var saved = parsed.get("currencies", {})
	if typeof(saved) == TYPE_DICTIONARY:
		for k in saved.keys():
			currencies[str(k)] = int(saved[k])
