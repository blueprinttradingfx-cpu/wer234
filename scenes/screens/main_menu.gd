extends Control
class_name MainMenu

# --- @onready - plain nodes (%) ---
@onready var start_button: Button = %StartButton
@onready var stage_label: Label = %StageLabel
@onready var hangar_button: Button = %HangarButton
@onready var upgrades_button: Button = %UpgradesButton
@onready var shop_button: Button = %ShopButton

# --- VARIABLES ---
var game_state = null

func _ready() -> void:
	_connect_signals()
	_refresh_stage_info()

func _refresh_stage_info() -> void:
	var progression_manager = get_node_or_null("/root/ProgressionManager")
	if not progression_manager:
		return

	var stage_id: int = progression_manager.current_player_stage
	var stage_config: Dictionary = progression_manager.get_config_for_stage(stage_id)
	if stage_label:
		stage_label.text = "Stage %d — %s" % [stage_id, stage_config.get("stage_name", "Unknown Sector")]

func _connect_signals() -> void:
	game_state = get_node_or_null("/root/GameState")
	
	if start_button:
		start_button.pressed.connect(_on_start_pressed)
	if hangar_button:
		hangar_button.pressed.connect(_on_hangar_pressed)
	if upgrades_button:
		upgrades_button.pressed.connect(_on_upgrades_pressed)
	if shop_button:
		shop_button.pressed.connect(_on_shop_pressed)

func _on_start_pressed() -> void:
	if game_state:
		# Points directly to your operational Gundam combat loop scene
		game_state.transition_to_screen(game_state.Screen.BATTLE)

func _on_hangar_pressed() -> void:
	if game_state:
		game_state.transition_to_screen(game_state.Screen.HANGAR)

func _on_upgrades_pressed() -> void:
	if game_state:
		game_state.transition_to_screen(game_state.Screen.UPGRADES)

func _on_shop_pressed() -> void:
	if game_state:
		game_state.transition_to_screen(game_state.Screen.SHOP)