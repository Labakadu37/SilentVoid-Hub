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
	"tickets": 12,
}

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
		{
			"name": "VOID", "rarity": "LEGENDAIRE", "rarity_color": Color("ffb300"),
			"power": 11, "trophies": 940, "unlocked": true, "price": 0,
			"skin": Color("e8d5ff"), "suit": Color("6d28d9"), "accent": Color("22d3ee"),
			"hair": Color("2b1e63"), "weapon": "staff", "hat": "hood",
			"tagline": "Frappe a distance, invisible une seconde apres son tir.",
		},
		{
			"name": "SHELDY", "rarity": "MYTHIQUE", "rarity_color": Color("ff4d6d"),
			"power": 9, "trophies": 812, "unlocked": true, "price": 0,
			"skin": Color("f5c69a"), "suit": Color("e94560"), "accent": Color("ffd23f"),
			"hair": Color("3b2a1a"), "weapon": "gun", "hat": "cap",
			"tagline": "Fusil a dispersion, redoutable au corps a corps.",
		},
		{
			"name": "BRUTUS", "rarity": "EPIQUE", "rarity_color": Color("a855f7"),
			"power": 8, "trophies": 655, "unlocked": true, "price": 0,
			"skin": Color("c98a5b"), "suit": Color("ff8c1a"), "accent": Color("241a4e"),
			"hair": Color("1a1238"), "weapon": "hammer", "hat": "helmet",
			"tagline": "Tank. Encaisse tout et renvoie encore plus fort.",
		},
		{
			"name": "NOVA", "rarity": "SUPER RARE", "rarity_color": Color("3ba7ff"),
			"power": 7, "trophies": 501, "unlocked": true, "price": 0,
			"skin": Color("ffd9c0"), "suit": Color("22d3ee"), "accent": Color("ffffff"),
			"hair": Color("ff4d6d"), "weapon": "bow", "hat": "hair",
			"tagline": "Tir tendu longue portee. Fragile mais mortelle.",
		},
		{
			"name": "PIXO", "rarity": "RARE", "rarity_color": Color("3ddc84"),
			"power": 6, "trophies": 320, "unlocked": true, "price": 0,
			"skin": Color("ffe0b2"), "suit": Color("3ddc84"), "accent": Color("ffd23f"),
			"hair": Color("2f2a3f"), "weapon": "fist", "hat": "cap",
			"tagline": "Rapide, colle a l'adversaire et ne lache plus.",
		},
		{
			"name": "ZENTY", "rarity": "CHROMATIQUE", "rarity_color": Color("22d3ee"),
			"power": 1, "trophies": 0, "unlocked": false, "price": 950,
			"skin": Color("d7f9ff"), "suit": Color("0ea5e9"), "accent": Color("ffd23f"),
			"hair": Color("0b2545"), "weapon": "staff", "hat": "crown",
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
