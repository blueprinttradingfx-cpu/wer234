extends Control
class_name SoftwareUpgradeOverlay

const UPGRADE_CARD_GENERATOR := preload("res://systems/upgrade_card_generator.gd")

# --- SIGNALS ---
signal upgrade_selected(upgrade_type: String, value: float)
signal re_roll_requested()

# --- VARIABLES ---
var available_upgrades: Array = []
var selected_upgrade: String = ""
var ad_sdk_loaded: bool = false
var save_system: Node = null
var progression_manager: Node = null
var upgrade_card_generator: UpgradeCardGenerator = null

func _ready() -> void:
	save_system = get_node_or_null("/root/SaveSystem")
	progression_manager = get_node_or_null("/root/ProgressionManager")
	upgrade_card_generator = UPGRADE_CARD_GENERATOR.new()
	_build_cards()
	_connect_signals()

func _connect_signals() -> void:
	var re_roll_button = get_node_or_null("Container/ReRollButton")
	if re_roll_button:
		re_roll_button.pressed.connect(_on_re_roll_pressed)

func _build_cards() -> void:
	var current_stage: int = _get_current_stage()
	available_upgrades = upgrade_card_generator.generate_random_cards(3, current_stage)

	var cards_container = get_node_or_null("Container/CardsContainer")
	if not cards_container:
		return

	var card_nodes = cards_container.get_children()
	for i in range(min(4, card_nodes.size())):
		var card = card_nodes[i]
		_build_card(card, i, available_upgrades[i] if i < available_upgrades.size() else _get_ad_upgrade())

func _build_card(card: PanelContainer, index: int, upgrade_data: Dictionary) -> void:
	# Clear existing content
	for child in card.get_children():
		child.queue_free()
	
	var vbox = VBoxContainer.new()
	card.add_child(vbox)
	
	var title_label = Label.new()
	title_label.text = upgrade_data.get("title", "Upgrade")
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title_label)
	
	var desc_label = Label.new()
	desc_label.text = upgrade_data.get("description", "")
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc_label)
	
	var select_button = Button.new()
	select_button.text = upgrade_data.get("button_text", "SELECT")
	
	if upgrade_data.get("is_ad", false):
		select_button.text = "🎬 WATCH AD"
		select_button.pressed.connect(_on_ad_card_pressed)
	else:
		select_button.pressed.connect(_on_card_selected.bind(upgrade_data.get("type", ""), upgrade_data.get("value", 0.0)))
	
	vbox.add_child(select_button)

func _get_current_stage() -> int:
	if progression_manager and progression_manager.has_method("get_current_stage"):
		return progression_manager.get_current_stage()

	if save_system and save_system.has_method("get_current_stage"):
		return save_system.get_current_stage()

	return 1

func _get_ad_upgrade() -> Dictionary:
	return {
		"type": "overclock",
		"title": "⚡ OVERCLOCK",
		"description": "Double DPS for 5 waves",
		"value": 2.0,
		"button_text": "🎬 WATCH AD",
		"is_ad": true
	}

func _on_card_selected(upgrade_type: String, value: float) -> void:
	selected_upgrade = upgrade_type
	upgrade_selected.emit(upgrade_type, value)
	# NOTE: Main battle scene handles cleanup via _close_upgrade_overlay()

func _on_ad_card_pressed() -> void:
	if ad_sdk_loaded:
		_show_rewarded_ad_for_overclock()
	else:
		# Fallback: grant upgrade without ad for development
		print("Ad SDK not loaded - granting overclock upgrade (dev mode)")
		_grant_overclock_upgrade()

func _on_re_roll_pressed() -> void:
	if ad_sdk_loaded:
		_show_rewarded_ad_for_reroll()
	else:
		# Fallback: allow free re-roll for development
		print("Ad SDK not loaded - allowing free re-roll (dev mode)")
		re_roll_requested.emit()
		_build_cards()

# --- AD SDK INTEGRATION METHODS ---
# These methods should be connected to your ad SDK (e.g., Godot AdMob)
# TODO: Integrate actual ad SDK and connect these methods

func _show_rewarded_ad_for_overclock() -> void:
	# Call your ad SDK's rewarded ad method here
	# Example: AdMob.show_rewarded_ad("overclock_ad_unit_id")
	print("Showing rewarded ad for overclock upgrade...")
	# On ad completion, call _grant_overclock_upgrade()
	# On ad failure, show error message
	_grant_overclock_upgrade() # Placeholder - remove when real SDK is integrated

func _show_rewarded_ad_for_reroll() -> void:
	# Call your ad SDK's rewarded ad method here
	# Example: AdMob.show_rewarded_ad("reroll_ad_unit_id")
	print("Showing rewarded ad for re-roll...")
	# On ad completion, emit re_roll_requested and call _build_cards()
	# On ad failure, show error message
	re_roll_requested.emit()
	_build_cards() # Placeholder - remove when real SDK is integrated

func _grant_overclock_upgrade() -> void:
	upgrade_selected.emit("overclock", 2.0)
	# NOTE: Main battle scene handles cleanup via _close_upgrade_overlay()

# Call this method when your ad SDK is successfully loaded
func set_ad_sdk_loaded(loaded: bool) -> void:
	ad_sdk_loaded = loaded
