extends Control
class_name ScreenTemplate

# --- SIGNALS ---
signal back_requested()

# --- @onready - unique nodes (%) ---
@onready var back_button: Button = %BackButton

# --- @onready - instanced scenes ($) ---
@onready var top_appbar: Control = $RootLayout/SafeArea/TopAppBar
@onready var bottom_nav: Control = $RootLayout/SafeArea/BottomNav
@onready var main_content: Control = $RootLayout/SafeArea/MainContent

# --- VARIABLES ---
var screen_name: String = "Template"
var game_state = null

func _ready() -> void:
	game_state = get_node_or_null("/root/GameState")
	_connect_signals()
	_refresh_ui()

func _connect_signals() -> void:
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	if bottom_nav:
		if bottom_nav.has_method("set_active"):
			bottom_nav.set_active(screen_name)
	else:
		push_warning("[%s] BottomNav not found" % screen_name)

func _refresh_ui() -> void:
	pass

func _on_back_pressed() -> void:
	if game_state:
		game_state.transition_to_screen(game_state.Screen.MENU)
