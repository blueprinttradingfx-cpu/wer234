extends Node

signal data_updated()
signal save_loaded()

var _save_data: Dictionary = {}

const SAVE_FILE_PATH := "user://mecha_save.json"
const CURRENT_VERSION := 1

func _ready() -> void:
	load_game()

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		_create_new_save()
		return
	
	var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file:
		var content := file.get_as_text()
		file.close()
		var parsed: Variant = JSON.parse_string(content)
		if parsed is Dictionary:
			_save_data = _migrate(parsed)
		else:
			push_warning("Corrupt save file, using default")
			_create_new_save()
	else:
		_create_new_save()
	
	save_loaded.emit()

func _create_new_save() -> void:
	_save_data = {
		"version": CURRENT_VERSION,
		"meta": {
			"created_at": Time.get_unix_time_from_system(),
			"last_login": Time.get_unix_time_from_system()
		},
		"progression": {
			"current_stage": 1,
			"current_wave": 1,
			"restart_wave": 1,  # New: wave to start at after defeat
			"completed_upgrade_milestones": [],  # New: waves where upgrade was already given
			"highest_stage": 1,
			"total_battles": 0,
			"victories": 0
		},
		"economy": {
			"tech_credits": 0,
			"premium_currency": 0
		},
		"mechas": {
			"active_mecha_id": "mecha_unit_alpha_base",
			"unlocked_mecha_ids": ["mecha_unit_alpha_base"]
		},
		"upgrades": {
			"ballistic_core": {},
			"energy_matrix": {},
			"tactician_protocol": {}
		},
		"active_software_effects": []
	}
	save_game()

func set_restart_wave(wave: int) -> void:
	if not _save_data.has("progression"):
		_save_data["progression"] = {}
	_save_data["progression"]["restart_wave"] = max(1, wave)  # Can't be less than 1
	print("[SaveSystem] Set restart wave to: ", _save_data["progression"]["restart_wave"])
	save_game()

func get_restart_wave() -> int:
	if _save_data.has("progression"):
		return _save_data["progression"].get("restart_wave", 1)
	return 1

func add_completed_upgrade_milestone(wave: int) -> void:
	if not _save_data.has("progression"):
		_save_data["progression"] = {}
	if not _save_data["progression"].has("completed_upgrade_milestones"):
		_save_data["progression"]["completed_upgrade_milestones"] = []
	if not wave in _save_data["progression"]["completed_upgrade_milestones"]:
		_save_data["progression"]["completed_upgrade_milestones"].append(wave)
		print("[SaveSystem] Added completed upgrade milestone for wave: ", wave)
		save_game()

func get_completed_upgrade_milestones() -> Array:
	if _save_data.has("progression"):
		return _save_data["progression"].get("completed_upgrade_milestones", [])
	return []

func reset_completed_upgrade_milestones() -> void:
	if not _save_data.has("progression"):
		_save_data["progression"] = {}
	_save_data["progression"]["completed_upgrade_milestones"] = []
	print("[SaveSystem] Reset completed upgrade milestones!")
	save_game()

func reset_progress() -> void:
	_create_new_save()
	save_loaded.emit()

func _migrate(data: Dictionary) -> Dictionary:
	# Add custom serialization checks here if structural changes happen down the line
	return data

func save_game() -> void:
	var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_save_data, "\t"))
		file.close()
		data_updated.emit()

func update_stage_progression(stage: int) -> void:
	_save_data["progression"]["current_stage"] = stage
	if stage > _save_data["progression"]["highest_stage"]:
		_save_data["progression"]["highest_stage"] = stage
	save_game()

func get_current_stage() -> int:
	if _save_data.has("progression"):
		return _save_data["progression"].get("current_stage", 1)
	return 1

func get_highest_stage() -> int:
	if _save_data.has("progression"):
		return _save_data["progression"].get("highest_stage", 1)
	return 1

func set_current_wave(wave: int) -> void:
	if not _save_data.has("progression"):
		_save_data["progression"] = {}
	_save_data["progression"]["current_wave"] = wave
	save_game()

func get_current_wave() -> int:
	if _save_data.has("progression"):
		return _save_data["progression"].get("current_wave", 1)
	return 1

func set_active_software_effects(effects: Array) -> void:
	# Save only what's necessary to restore the effects
	var saved_effects = []
	for effect in effects:
		saved_effects.append({
			"type": effect.get("type"),
			"value": effect.get("value"),
			"remaining_waves": effect.get("remaining_waves"),
			"multiplier": effect.get("multiplier", 1.0)
		})
	print("[SaveSystem] Saving ", saved_effects.size(), " software effects: ", saved_effects)
	_save_data["active_software_effects"] = saved_effects
	save_game()

func get_active_software_effects() -> Array:
	var saved_effects = []
	if _save_data.has("active_software_effects"):
		saved_effects = _save_data["active_software_effects"].duplicate()
	print("[SaveSystem] Loading ", saved_effects.size(), " software effects: ", saved_effects)
	return saved_effects

func reset_active_software_effects() -> void:
	print("[SaveSystem] Resetting active software effects!")
	_save_data["active_software_effects"] = []
	save_game()

func unlock_mecha(mecha_id: String) -> void:
	if not mecha_id in _save_data["mechas"]["unlocked_mecha_ids"]:
		_save_data["mechas"]["unlocked_mecha_ids"].append(mecha_id)
		save_game()

func set_active_mecha(mecha_id: String) -> void:
	if mecha_id in _save_data["mechas"]["unlocked_mecha_ids"]:
		_save_data["mechas"]["active_mecha_id"] = mecha_id
		save_game()

func get_active_mecha() -> String:
	return _save_data["mechas"]["active_mecha_id"]

func get_unlocked_mechas() -> Array:
	return _save_data["mechas"]["unlocked_mecha_ids"]

func set_upgrade_level(module: String, upgrade: String, level: int) -> void:
	if not _save_data.has("upgrades"):
		_save_data["upgrades"] = {}
	if not _save_data["upgrades"].has(module):
		_save_data["upgrades"][module] = {}
	_save_data["upgrades"][module][upgrade] = level
	save_game()

func get_upgrade_level(module: String, upgrade: String) -> int:
	if _save_data.has("upgrades") and _save_data["upgrades"].has(module):
		return _save_data["upgrades"][module].get(upgrade, 0)
	return 0

func get_tech_credits() -> int:
	if _save_data.has("economy"):
		return _save_data["economy"].get("tech_credits", 0)
	return 0

func set_tech_credits(amount: int) -> void:
	if not _save_data.has("economy"):
		_save_data["economy"] = {
			"tech_credits": 0,
			"premium_currency": 0
		}
	_save_data["economy"]["tech_credits"] = amount
	save_game()

func add_tech_credits(amount: int) -> void:
	var current = get_tech_credits()
	set_tech_credits(current + amount)

func deduct_tech_credits(amount: int) -> void:
	var current = get_tech_credits()
	var new_amount = max(0, current - amount)
	set_tech_credits(new_amount)

func set_value(key: String, value: Variant) -> void:
	if not _save_data.has("settings"):
		_save_data["settings"] = {}
	_save_data["settings"][key] = value
	save_game()

func get_value(key: String, default_value: Variant = null) -> Variant:
	if _save_data.has("settings") and _save_data["settings"].has(key):
		return _save_data["settings"][key]
	return default_value
