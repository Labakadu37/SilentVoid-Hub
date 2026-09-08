extends Control
## Chef d'orchestre du lobby : cable les briques entre elles, joue l'animation
## d'entree, ouvre les popups.

@onready var top_bar: TopBar = $TopBar
@onready var event_panel: EventPanel = $EventPanel
@onready var stage: BrawlerStage = $Stage
@onready var play_dock: PlayDock = $PlayDock
@onready var bottom_nav: BottomNav = $BottomNav
@onready var overlays: Control = $Overlays

var _matchmaking: MatchmakingOverlay = null


func _ready() -> void:
	top_bar.profile_pressed.connect(func(): _toast("Profil : bientot disponible"))
	top_bar.settings_pressed.connect(func(): _toast("Reglages : bientot disponible"))
	top_bar.shop_shortcut.connect(_on_shop_shortcut)
	play_dock.play_pressed.connect(_on_play)
	play_dock.team_pressed.connect(func(): _toast("Invitation d'amis : bientot disponible"))
	bottom_nav.tab_pressed.connect(_on_tab)
	play_intro()


func play_intro() -> void:
	top_bar.play_intro()
	event_panel.play_intro()
	bottom_nav.play_intro()
	stage.modulate.a = 0.0
	play_dock.modulate.a = 0.0
	play_dock.scale = Vector2(0.8, 0.8)
	play_dock.pivot_offset = play_dock.size * 0.5
	var tw := create_tween()
	tw.tween_interval(0.12)
	tw.tween_property(stage, "modulate:a", 1.0, 0.35)
	tw.parallel().tween_property(play_dock, "modulate:a", 1.0, 0.3)
	tw.parallel().tween_property(play_dock, "scale", Vector2.ONE, 0.45) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


# ------------------------------------------------------------------ actions

func _on_play() -> void:
	if not bool(GameState.current_brawler().get("unlocked", true)):
		_toast("Ce perso est verrouille : choisis-en un autre")
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


func _on_shop_shortcut(currency_id: String) -> void:
	# Placeholder : la boutique arrivera plus tard. En attendant on offre un peu
	# de monnaie pour voir l'animation des compteurs.
	match currency_id:
		"gems": GameState.add_currency("gems", 25)
		"coins": GameState.add_currency("coins", 500)
		_: GameState.add_currency(currency_id, 1)
	_toast("Boutique : bientot disponible")


func _on_tab(id: String) -> void:
	match id:
		"brawlers": _toast("Ecran des persos : bientot disponible")
		"shop": _toast("Boutique : bientot disponible")
		"news": _toast("News : bientot disponible")
		"club": _toast("Club %s : bientot disponible" % GameState.club_name)
		"chat": _toast("Chat : bientot disponible")


# ------------------------------------------------------------------ toast

func _toast(message: String) -> void:
	var lbl := Label.new()
	lbl.text = message
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 18)
	lbl.add_theme_color_override("font_color", UiSkin.TEXT)
	lbl.add_theme_color_override("font_outline_color", UiSkin.OUTLINE)
	lbl.add_theme_constant_override("outline_size", 6)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlays.add_child(lbl)
	lbl.size = Vector2(size.x, 34)
	lbl.position = Vector2(0, size.y * 0.62)
	lbl.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(lbl, "modulate:a", 1.0, 0.15)
	tw.parallel().tween_property(lbl, "position:y", size.y * 0.58, 0.4)
	tw.tween_interval(1.1)
	tw.tween_property(lbl, "modulate:a", 0.0, 0.3)
	tw.tween_callback(lbl.queue_free)
