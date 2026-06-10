extends Control

@onready var gold_label: Label = %GoldLabel
@onready var diamond_label: Label = %DiamondLabel
@onready var back_button: Button = %BackButton
@onready var close_button: Button = %CloseButton
@onready var upgrade_items_list: VBoxContainer = %UpgradeItemsList

const ROW_ITEM_SCENE = preload("res://scenes/common/upgrade_row_item.tscn")
const POWERUP_ATLAS = preload("res://assets/ui/powerups.png")
# Add a variable to track if this menu was opened from inside a running game
var is_overlay: bool = false

# Database definitions mirroring main_gundam_scene keys
var upgrades_database: Dictionary = {
	"chassis_calibrator": {
		"category": "ballistic_core",
		"key": "chassis_calibrator_level",
		"title": "Chassis Calibrator",
		"desc": "Increases Mecha base attack speed configuration (+5% per level)",
		"max_level": 10,
		"base_cost": 250,
		"cost_multiplier": 1.5,
		"atlas_region": Rect2(50, 70, 292, 292)
	},
	"piercing_barrel": {
		"category": "ballistic_core",
		"key": "piercing_barrel_level",
		"title": "Piercing Barrel",
		"desc": "Enables primary ammunition projectiles to cut through targets",
		"max_level": 1,
		"base_cost": 1000,
		"cost_multiplier": 1.0,
		"atlas_region": Rect2(376, 70, 292, 292)
	},
	"multi_shot_loader": {
		"category": "ballistic_core",
		"key": "multi_shot_loader_level",
		"title": "Multi-Shot Loader",
		"desc": "Splits frontal munitions fires into multi-projectile spreads",
		"max_level": 2,
		"base_cost": 750,
		"cost_multiplier": 2.0,
		"atlas_region": Rect2(1035, 70, 292, 292)
	}
}

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	close_button.pressed.connect(_on_back_pressed)
	
	_update_currency_display()
	_populate_upgrade_list()

func _update_currency_display() -> void:
	var ss = get_node_or_null("/root/SaveSystem")
	if ss and ss.has_method("get_tech_credits"):
		gold_label.text = "💰 " + str(ss.get_tech_credits()) 

func _populate_upgrade_list() -> void:
	# Clean out existing items
	for child in upgrade_items_list.get_children():
		child.queue_free()
		
	var ss = get_node_or_null("/root/SaveSystem")
	
	for internal_id in upgrades_database:
		var data = upgrades_database[internal_id]
		var current_lvl = 0
		
		if ss and ss.has_method("get_upgrade_level"):
			current_lvl = ss.get_upgrade_level(data["category"], data["key"])
			
		var row_instance = ROW_ITEM_SCENE.instantiate()
		upgrade_items_list.add_child(row_instance)
		
		# Set up UI text elements
		row_instance.get_node("%TitleLabel").text = data["title"]
		row_instance.get_node("%DescLabel").text = data["desc"]
		row_instance.get_node("%LevelLabel").text = "LVL: %d / %d" % [current_lvl, data["max_level"]]
		
		# Set up the AtlasTexture icon
		var texture_rect: TextureRect = row_instance.get_node("%Icon")
		var atlas_tex = AtlasTexture.new()
		atlas_tex.atlas = POWERUP_ATLAS
		atlas_tex.region = data["atlas_region"]
		texture_rect.texture = atlas_tex
		
		# Calculate dynamic upgrade price
		var btn: Button = row_instance.get_node("%UpgradeButton")
		if current_lvl >= data["max_level"]:
			btn.text = "MAXED"
			btn.disabled = true
		else:
			var cost = int(data["base_cost"] * (data["cost_multiplier"] ** current_lvl))
			btn.text = "%d CC" % cost
			btn.disabled = false
			btn.pressed.connect(_on_upgrade_triggered.bind(internal_id, cost))

func _on_upgrade_triggered(internal_id: String, cost: int) -> void:
	var ss = get_node_or_null("/root/SaveSystem")
	if not ss:
		return
		
	var current_credits = 0
	if ss.has_method("get_tech_credits"):
		current_credits = ss.get_tech_credits()
		
	if current_credits < cost:
		print("❌ Insufficient tech credits!")
		return
		
	var data = upgrades_database[internal_id]
	var current_lvl = 0
	if ss.has_method("get_upgrade_level"):
		current_lvl = ss.get_upgrade_level(data["category"], data["key"])
	
	if current_lvl < data["max_level"]:
		# Deduct credits safely based on your SaveSystem API
		if ss.has_method("change_tech_credits"):
			ss.change_tech_credits(-cost)
		elif ss.has_method("set_tech_credits"):
			ss.set_tech_credits(current_credits - cost)
			
		# Increment and save the new level
		if ss.has_method("set_upgrade_level"):
			ss.set_upgrade_level(data["category"], data["key"], current_lvl + 1)
		
		# Refresh the UI to reflect changes
		_update_currency_display()
		_populate_upgrade_list()
	else:
		print("⚠️ This upgrade is already at maximum level!")

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
