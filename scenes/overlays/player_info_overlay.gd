extends Control

signal resume_requested()

@onready var close_button: Button = %CloseButton
@onready var name_label: Label = %PlayerNameLabel
@onready var stats_label: Label = %StatsLabel
@onready var powerups_label: Label = %PowerupsLabel

func _ready() -> void:
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	
	_populate_player_info()

func _on_close_pressed() -> void:
	resume_requested.emit()
	queue_free()

func _populate_player_info() -> void:
	name_label.text = "Pilot Alpha"
	
	var mecha_stats_text = "--- Mecha Stats ---\n"
	
	var progression_manager = get_node_or_null("/root/ProgressionManager")
	var mecha_stats = {}
	if progression_manager:
		mecha_stats = progression_manager.get_active_mecha_stats()
	
	if not mecha_stats.is_empty():
		var base_stats = mecha_stats.get("base_stats", {})
		mecha_stats_text += "Base Attack Damage: " + str(base_stats.get("attack_damage", 0)) + "\n"
		mecha_stats_text += "Base Attack Speed: " + str(base_stats.get("attack_speed", 0)) + "\n\n"
		
		var skill = mecha_stats.get("skill", {})
		mecha_stats_text += "--- Active Skill ---\n"
		mecha_stats_text += "Name: " + skill.get("name", "None") + "\n"
		mecha_stats_text += "Total Damage: " + str(skill.get("total_damage", 0)) + "\n"
		mecha_stats_text += "Cooldown: " + str(skill.get("cooldown", 0)) + "s\n"
	else:
		mecha_stats_text += "No active mecha data found."
		
	stats_label.text = mecha_stats_text
	
	# Fetch active powerups and permanent upgrades
	var powerups_text = ""
	
	# --- Permanent Upgrades ---
	powerups_text += "--- Permanent Upgrades ---\n"
	var save_system = get_node_or_null("/root/SaveSystem")
	if save_system:
		# Ballistic Core
		var chassis_calibrator = save_system.get_upgrade_level("ballistic_core", "chassis_calibrator_level")
		var multi_shot_loader = save_system.get_upgrade_level("ballistic_core", "multi_shot_loader_level")
		var piercing_barrel = save_system.get_upgrade_level("ballistic_core", "piercing_barrel_level")
		
		# Energy Matrix
		var processor_overclock = save_system.get_upgrade_level("energy_matrix", "processor_overclock_level")
		var payload_expansion = save_system.get_upgrade_level("energy_matrix", "payload_expansion_level")
		
		# Tactician Protocol
		var emp_grid = save_system.get_upgrade_level("tactician_protocol", "emp_grid_level")
		
		var has_any_upgrades = false
		
		if chassis_calibrator > 0:
			powerups_text += "• Chassis Calibrator (Lvl %d/10)\n" % chassis_calibrator
			has_any_upgrades = true
		if multi_shot_loader > 0:
			powerups_text += "• Multi-Shot Loader (Lvl %d/5)\n" % multi_shot_loader
			has_any_upgrades = true
		if piercing_barrel > 0:
			powerups_text += "• Piercing Rail Barrel (Lvl %d/2)\n" % piercing_barrel
			has_any_upgrades = true
		if processor_overclock > 0:
			powerups_text += "• Processor Overclock (Lvl %d/10)\n" % processor_overclock
			has_any_upgrades = true
		if payload_expansion > 0:
			powerups_text += "• Payload Expansion (Lvl %d/10)\n" % payload_expansion
			has_any_upgrades = true
		if emp_grid > 0:
			powerups_text += "• EMP Disruption Grid (Lvl %d/5)\n" % emp_grid
			has_any_upgrades = true
		
		if not has_any_upgrades:
			powerups_text += "No permanent upgrades purchased yet.\n"
	else:
		powerups_text += "Save system not found.\n"
	
	powerups_text += "\n"
	
	# --- Active Software Powerups ---
	powerups_text += "--- Active Software Powerups ---\n"
	var effect_system = _find_upgrade_effect_system()
	if effect_system and "active_effects" in effect_system:
		var effects = effect_system.active_effects
		if effects.size() > 0:
			for effect in effects:
				var definition = effect.get("definition", {})
				var effect_name = definition.get("name", effect.get("type", "Unknown"))
				var effect_desc = definition.get("description", "")
				var remaining_waves = effect.get("remaining_waves", 0)
				
				powerups_text += "• %s\n" % effect_name
				if effect_desc:
					powerups_text += "  %s\n" % effect_desc
				if remaining_waves > 0:
					powerups_text += "  Remaining: %d waves\n\n" % remaining_waves
				else:
					powerups_text += "  Permanent for this run\n\n"
		else:
			powerups_text += "No active powerups.\n"
	else:
		powerups_text += "Upgrade system not found.\n"
	
	powerups_label.text = powerups_text

func _find_upgrade_effect_system() -> Node:
	# Traverse up to find the main game scene
	var current = get_parent()
	while current and is_instance_valid(current):
		if "upgrade_effect_system" in current:
			return current.upgrade_effect_system
		current = current.get_parent()
	return null
