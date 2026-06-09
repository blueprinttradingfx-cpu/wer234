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
			"energy_matrix": {}
		}
	}
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
		_save_data["economy"] = {}
	_save_data["economy"]["premium_currency"] = 0
	_save_data["economy"]["tech_credits"] = 0
	
	_save_data["economy"]["tech_credits"] = amount
	save_game()

func add_tech_credits(amount: int) -> void:
	var current = get_tech_credits()
	set_tech_credits(current + amount)

func deduct_tech_credits(amount: int) -> void:
	var current = get_tech_credits()
	var new_amount = max(0, current - amount)
	set_tech_credits(new_amount)
