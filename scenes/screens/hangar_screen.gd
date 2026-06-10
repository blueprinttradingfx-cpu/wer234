extends Control

@onready var back_button: Button = %BackButton
@onready var close_button: Button = %CloseButton
@onready var mecha_name_label: Label = %MechaNameLabel
@onready var mecha_texture: TextureRect = %MechaTexture
@onready var atk_label: Label = %AtkLabel
@onready var hp_label: Label = %HpLabel
@onready var equipment_grid: HFlowContainer = %EquipmentGrid

const CARD_ITEM_SCENE = preload("res://scenes/common/shop_item_card.tscn")
# Add a variable to track if this menu was opened from inside a running game
var is_overlay: bool = false

# Mock database of items currently owned by the user profile
var inventory_items: Dictionary = {
	"wpn_beam_rifle": {"title": "Beam Rifle", "type": "Weapon", "stat_bonus": "+40 ATK", "equipped": true},
	"wpn_plasma_blade": {"title": "Plasma Blade", "type": "Weapon", "stat_bonus": "+60 ATK", "equipped": false},
	"shd_graphene": {"title": "Graphene Shield", "type": "Armor", "stat_bonus": "+300 HP", "equipped": true},
	"core_overclock": {"title": "Overclock Core", "type": "Utility", "stat_bonus": "+15% Speed", "equipped": false}
}

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	close_button.pressed.connect(_on_back_pressed)
	
	_refresh_hangar_ui()

func _refresh_hangar_ui() -> void:
	_calculate_and_render_stats()
	_populate_equipment_list()

func _calculate_and_render_stats() -> void:
	var base_atk = 100
	var base_hp = 1000
	
	for id in inventory_items:
		var item = inventory_items[id]
		if item["equipped"]:
			if "ATK" in item["stat_bonus"]:
				base_atk += int(item["stat_bonus"])
			if "HP" in item["stat_bonus"]:
				base_hp += int(item["stat_bonus"])
				
	atk_label.text = "COMBAT POWER: %d ATK" % base_atk
	hp_label.text = "SURVIVABILITY: %d HP" % base_hp

func _populate_equipment_list() -> void:
	# Clear out old cards cleanly before re-rendering
	for child in equipment_grid.get_children():
		child.queue_free()
		
	for id in inventory_items:
		var item = inventory_items[id]
		var card = CARD_ITEM_SCENE.instantiate()
		equipment_grid.add_child(card)
		
		card.get_node("%TitleLabel").text = item["title"]
		card.get_node("%ValueLabel").text = item["stat_bonus"]
		
		var action_btn: Button = card.get_node("%BuyButton")
		if item["equipped"]:
			action_btn.text = "EQUIPPED"
			action_btn.disabled = true
		else:
			action_btn.text = "EQUIP"
			action_btn.disabled = false
			action_btn.pressed.connect(_on_equip_item_triggered.bind(id))

func _on_equip_item_triggered(item_id: String) -> void:
	var target_type = inventory_items[item_id]["type"]
	
	# Auto un-equip other parts in the same slot
	for id in inventory_items:
		if inventory_items[id]["type"] == target_type:
			inventory_items[id]["equipped"] = false
			
	inventory_items[item_id]["equipped"] = true
	print("⚔️ Mounted hangar component component: ", item_id)
	_refresh_hangar_ui()

func set_overlay_mode(value: bool) -> void:
	is_overlay = value
	# If running as an overlay, change the footer button text to read "RESUME" or "BACK"
	if is_overlay and has_node("%CloseButton"):
		%CloseButton.text = "RESUME RUN"

func _on_back_pressed() -> void:
	if is_overlay:
		# Unpause your battle engine safely
		var battle_manager = get_node_or_null("/root/BattleManager")
		if battle_manager:
			battle_manager.resume_battle()
		else:
			get_tree().paused = false
			
		# Remove this menu layer completely, revealing the underlying main scene perfectly intact!
		queue_free()
	else:
		# Fallback fallback if opened cleanly from a static Main Menu asset frame
		get_tree().change_scene_to_file("res://scenes/screens/main_gundam/main_gundam_scene.tscn")