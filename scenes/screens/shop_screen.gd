extends Control
class_name ShopScreen

# --- SIGNALS ---
signal back_requested()

# --- @onready - instanced scenes ($) ---
@onready var top_appbar: Control = $RootLayout/SafeArea/TopAppBar
@onready var bottom_nav: Control = $RootLayout/SafeArea/BottomNav
@onready var main_content: Control = $RootLayout/SafeArea/MainContent

# --- VARIABLES ---
var screen_name: String = "Shop"

func _ready() -> void:
	_connect_signals()
	_refresh_ui()

func _connect_signals() -> void:
	if bottom_nav:
		if bottom_nav.has_method("set_active"):
			bottom_nav.set_active(screen_name)
	else:
		push_warning("[%s] BottomNav not found" % screen_name)

func _refresh_ui() -> void:
	pass
