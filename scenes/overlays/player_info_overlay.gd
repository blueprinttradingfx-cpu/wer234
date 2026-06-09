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
	
	# Fetch active powerups (if we can find the upgrade effect system)
	var powerups_text = "--- Active Software Powerups ---\n"
	var effect_system = _find_upgrade_effect_system()
	if effect_system and "active_effects" in effect_system:
		var effects = effect_system.active_effects
		if effects.size() > 0:
			for effect in effects:
				powerups_text += "- " + effect.get("type", "Unknown") + " (Val: " + str(effect.get("value", 0)) + " | Waves left: " + str(effect.get("remaining_waves", 0)) + ")\n"
		else:
			powerups_text += "No active powerups."
	else:
		powerups_text += "Upgrade system not found."
		
	powerups_label.text = powerups_text

func _find_upgrade_effect_system() -> Node:
	var main_scene = get_tree().current_scene
	if main_scene and "upgrade_effect_system" in main_scene:
		return main_scene.upgrade_effect_system
	return null
