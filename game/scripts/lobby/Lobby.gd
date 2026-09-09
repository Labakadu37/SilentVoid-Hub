extends Control
## Chef d'orchestre du lobby : cable les briques entre elles, joue l'animation
## d'entree, ouvre les popups.

@onready var stage: BrawlerStage = $Stage
@onready var top_left: TopLeftBar = $TopLeft
@onready var top_right: TopRightBar = $TopRight
@onready var left_tabs: SideTabs = $LeftTabs
@onready var right_tabs: SideTabs = $RightTabs
@onready var bottom: BottomBar = $BottomBar
@onready var overlays: Control = $Overlays

var _matchmaking: MatchmakingOverlay = null
var _picker: ModePicker = null
var _net_panel: NetPanel = null


func _ready() -> void:
	left_tabs.tab_size = Vector2(128, 94)
	left_tabs.setup([
		{"id": "shop", "label": "BOUTIQUE", "icon": "shop", "color": UiSkin.ORANGE, "badge": 2},
		{"id": "brawlers", "label": "BRAWLERS", "icon": "brawler", "color": UiSkin.PURPLE, "badge": 0},
		{"id": "club", "label": "CLUB", "icon": "club", "color": UiSkin.GREEN, "badge": 0},
	])
	right_tabs.compact = true
	right_tabs.tab_size = Vector2(96, 88)
	right_tabs.setup([
		{"id": "news", "label": "INFOS", "icon": "news", "color": UiSkin.BLUE, "badge": 1},
		{"id": "friends", "label": "AMIS", "icon": "friends", "color": UiSkin.GREEN, "badge": 0},
		{"id": "chat", "label": "CHAT", "icon": "chat", "color": UiSkin.RED, "badge": 5},
	])

	top_left.profile_pressed.connect(func(): _toast("Profil : bientot disponible"))
	top_left.trophies_pressed.connect(func(): _toast("Route des trophees : bientot disponible"))
	top_right.shop_shortcut.connect(_on_shop_shortcut)
	top_right.menu_pressed.connect(_open_net_panel)
	left_tabs.tab_pressed.connect(_on_tab)
	right_tabs.tab_pressed.connect(_on_tab)
	bottom.play_pressed.connect(_on_play)
	bottom.quests_pressed.connect(func(): _toast("Quetes : bientot disponible"))
	bottom.pass_pressed.connect(func(): _toast("Passe de combat : bientot disponible"))
	bottom.event_pressed.connect(_open_mode_picker)
	stage.team_slot_pressed.connect(_on_team_slot)
	stage.brawler_pressed.connect(func(): _toast(str(GameState.current_brawler().get("tagline", ""))))
	play_intro()


func play_intro() -> void:
	left_tabs.play_intro(true)
	right_tabs.play_intro(false)
	bottom.play_intro()
	for n in [top_left, top_right]:
		n.modulate.a = 0.0
		n.position.y -= 24.0
		var tw0 := create_tween()
		tw0.tween_property(n, "modulate:a", 1.0, 0.25)
		tw0.parallel().tween_property(n, "position:y", n.position.y + 24.0, 0.35) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	stage.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_interval(0.10)
	tw.tween_property(stage, "modulate:a", 1.0, 0.35)


# ------------------------------------------------------------------ actions

func _on_play() -> void:
	if not bool(GameState.current_brawler().get("unlocked", true)):
		_toast("Ce brawler est verrouille : choisis-en un autre")
		return
	GameState.request_match()
	_matchmaking = MatchmakingOverlay.new()
	overlays.add_child(_matchmaking)
	_matchmaking.start(GameState.current_mode())
	_matchmaking.cancelled.connect(_close_matchmaking)
	_matchmaking.ready_to_play.connect(_on_match_ready)


func _on_match_ready() -> void:
	_close_matchmaking()
	GameState.start_match()


func _close_matchmaking() -> void:
	if _matchmaking and is_instance_valid(_matchmaking):
		_matchmaking.queue_free()
		_matchmaking = null


func _open_mode_picker() -> void:
	if _picker and is_instance_valid(_picker):
		return
	_picker = ModePicker.new()
	overlays.add_child(_picker)
	_picker.closed.connect(func():
		if is_instance_valid(_picker):
			_picker.queue_free()
		_picker = null)


func _open_net_panel() -> void:
	if _net_panel and is_instance_valid(_net_panel):
		return
	_net_panel = NetPanel.new()
	overlays.add_child(_net_panel)
	_net_panel.closed.connect(func():
		if is_instance_valid(_net_panel):
			_net_panel.queue_free()
		_net_panel = null)


func _on_team_slot(_slot: int) -> void:
	_open_net_panel()


func _on_shop_shortcut(currency_id: String) -> void:
	# Placeholder : la boutique arrivera plus tard. En attendant on offre un peu
	# de monnaie pour voir l'animation des compteurs.
	match currency_id:
		"gems": GameState.add_currency("gems", 25)
		"coins": GameState.add_currency("coins", 500)
		"power": GameState.add_currency("power", 250)
		_: GameState.add_currency(currency_id, 1)
	_toast("Boutique : bientot disponible")


func _on_tab(id: String) -> void:
	match id:
		"brawlers": _toast("Ecran des brawlers : bientot disponible")
		"shop": _toast("Boutique : bientot disponible")
		"news": _toast("Infos : bientot disponible")
		"club": _toast("Club %s : bientot disponible" % GameState.club_name)
		"chat": _toast("Chat : bientot disponible")
		"friends": _toast("Amis : bientot disponible")


# ------------------------------------------------------------------ toast

func _toast(message: String) -> void:
	var lbl := Label.new()
	lbl.text = message
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_override("font", Painter.font(self))
	lbl.add_theme_font_size_override("font_size", 18)
	lbl.add_theme_color_override("font_color", UiSkin.TEXT)
	lbl.add_theme_color_override("font_outline_color", UiSkin.OUTLINE)
	lbl.add_theme_constant_override("outline_size", 6)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlays.add_child(lbl)
	lbl.size = Vector2(size.x, 34)
	lbl.position = Vector2(0, size.y * 0.30)
	lbl.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(lbl, "modulate:a", 1.0, 0.15)
	tw.parallel().tween_property(lbl, "position:y", size.y * 0.26, 0.4)
	tw.tween_interval(1.1)
	tw.tween_property(lbl, "modulate:a", 0.0, 0.3)
	tw.tween_callback(lbl.queue_free)
