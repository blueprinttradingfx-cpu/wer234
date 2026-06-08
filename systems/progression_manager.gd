extends Node

signal stage_completed(stage_id: int)
signal mecha_unlocked(mecha_id: String)
signal active_mecha_changed(mecha_id: String)

const CURRENT_VERSION := 1

var current_player_stage: int = 1
var unlocked_mecha_ids: Array = ["mecha_unit_alpha_base"]
var active_mecha_id: String = "mecha_unit_alpha_base"

var stage_db: Dictionary = {}
var robot_db: Dictionary = {}

func _ready() -> void:
	load_databases()
	_sync_with_save_system()

func load_databases() -> void:
	stage_db = _parse_json_file("res://data/stage_progression_matrix.json")
	robot_db = _parse_json_file("res://data/robot_unlock_catalog.json")
	print("Progression Databases initialized successfully.")

func _sync_with_save_system() -> void:
	var save_sys = get_node_or_null("/root/SaveSystem")
	if save_sys:
		current_player_stage = save_sys.get_current_stage()
		active_mecha_id = save_sys.get_active_mecha()
		unlocked_mecha_ids = save_sys.get_unlocked_mechas()

func _parse_json_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_warning("Missing design database file at: " + path + ". Using defaults.")
		return {}
	
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(content)
	
	if parse_result != OK:
		push_error("Failed to parse JSON file at: " + path + ". Error: " + json.get_error_message())
		return {}
	
	if not json.data is Dictionary:
		push_error("JSON file at: " + path + " is not a valid dictionary. Using defaults.")
		return {}
	
	# Validate structure based on file type
	if path.contains("stage_progression_matrix"):
		return _validate_stage_data(json.data, path)
	elif path.contains("robot_unlock_catalog"):
		return _validate_robot_data(json.data, path)
	
	return json.data

func _validate_stage_data(data: Dictionary, path: String) -> Dictionary:
	# Basic validation for stage progression matrix
	if not data.has("global_settings"):
		push_warning("Missing global_settings in " + path + ". Using defaults.")
		data["global_settings"] = {
			"total_stage_time_budget_seconds": 300.0,
			"loss_heart_threshold": 50
		}
	
	if not data.has("cycles"):
		push_warning("Missing cycles in " + path + ". Using defaults.")
		data["cycles"] = []
	
	# Validate global_settings
	var settings = data["global_settings"]
	if not settings.has("total_stage_time_budget_seconds"):
		settings["total_stage_time_budget_seconds"] = 300.0
	if not settings.has("loss_heart_threshold"):
		settings["loss_heart_threshold"] = 50
	
	# Validate cycles structure
	for cycle in data["cycles"]:
		if not cycle.has("enemy_base_hp_multiplier"):
			cycle["enemy_base_hp_multiplier"] = 1.0
		if not cycle.has("stages"):
			cycle["stages"] = []
		
		# Validate each stage
		for stage in cycle["stages"]:
			if not stage.has("velocity_modifier"):
				stage["velocity_modifier"] = 1.0
			if not stage.has("enemies_per_wave"):
				stage["enemies_per_wave"] = 10
			if not stage.has("data_skip_multiplier"):
				stage["data_skip_multiplier"] = 1
	
	print("[ProgressionManager] Stage data validated successfully.")
	return data

func _validate_robot_data(data: Dictionary, path: String) -> Dictionary:
	# Basic validation for robot unlock catalog
	if not data.has("mechas"):
		push_warning("Missing mechas array in " + path + ". Using defaults.")
		data["mechas"] = []
	
	print("[ProgressionManager] Robot data validated successfully.")
	return data

func get_config_for_stage(stage_id: int) -> Dictionary:
	var result = {
		"stage_id": stage_id,
		"stage_name": "Unknown Grid Sector",
		"archetype": "The Entry Stream",
		"enemy_hp": 10.0, # Baseline
		"boss_hp": 290.0,
		"enemies_per_wave": 10,
		"velocity_modifier": 1.0,
		"data_skip_multiplier": 1
	}
	
	if stage_db.is_empty() or not stage_db.has("cycles"):
		return result
		
	for cycle in stage_db["cycles"]:
		if stage_id >= cycle["stage_range"][0] and stage_id <= cycle["stage_range"][1]:
			var hp_multiplier: float = cycle["enemy_base_hp_multiplier"]
			
			# Search for individual stage overrides inside the active cycle
			for stage in cycle["stages"]:
				if stage["stage_id"] == stage_id:
					result["stage_name"] = stage["stage_name"]
					result["archetype"] = stage["archetype"]
					result["enemy_hp"] = 10.0 * hp_multiplier # Applies the cycle stat wall
					result["boss_hp"] = stage["boss_hp"]
					result["enemies_per_wave"] = stage["enemies_per_wave"]
					result["velocity_modifier"] = stage["velocity_modifier"]
					result["data_skip_multiplier"] = stage["data_skip_multiplier"]
					break
			return result
	return result

func advance_stage() -> void:
	stage_completed.emit(current_player_stage)
	current_player_stage += 1
	
	var save_sys = get_node_or_null("/root/SaveSystem")
	if save_sys:
		save_sys.update_stage_progression(current_player_stage)

func evaluate_mecha_unlocks(stage_attempted: int) -> Array:
	var newly_unlocked: Array = []
	if robot_db.is_empty() or not robot_db.has("mechas"):
		return newly_unlocked
		
	for mecha in robot_db["mechas"]:
		var mid: String = mecha.get("mecha_id", "")
		if mid in unlocked_mecha_ids or mid.is_empty():
			continue
			
		var req = mecha.get("unlock_requirement", {})
		if req.get("type", "") == "stage_failed_or_reached" and stage_attempted >= req.get("value", 0):
			unlocked_mecha_ids.append(mid)
			newly_unlocked.append(mecha)
			mecha_unlocked.emit(mid)
			
			var save_sys = get_node_or_null("/root/SaveSystem")
			if save_sys:
				save_sys.unlock_mecha(mid)
				
	return newly_unlocked

func get_active_mecha_stats() -> Dictionary:
	if robot_db.has("mechas"):
		for mecha in robot_db["mechas"]:
			if mecha.get("mecha_id", "") == active_mecha_id:
				return mecha
	return {}

func get_available_mechas() -> Array:
	if robot_db.is_empty() or not robot_db.has("mechas"):
		return []
	return robot_db["mechas"]

func get_active_mecha_id() -> String:
	return active_mecha_id

func is_mecha_unlocked(mecha_id: String) -> bool:
	return mecha_id in unlocked_mecha_ids

func set_active_mecha(mecha_id: String) -> void:
	if mecha_id in unlocked_mecha_ids:
		active_mecha_id = mecha_id
		active_mecha_changed.emit(mecha_id)
		var save_sys = get_node_or_null("/root/SaveSystem")
		if save_sys:
			save_sys.set_active_mecha(mecha_id)
