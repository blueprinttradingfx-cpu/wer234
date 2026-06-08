extends Node

# Test Stage Configurations (EPIC-12 Stage Configurations, EPIC-03 Stage Content)

func _ready() -> void:
	print("=== Testing Stage Configurations ===")
	_test_json_file_exists()
	_test_json_structure()
	_test_stage_configs()
	_test_archetypes()
	print("\n=== Stage Configurations Tests Complete ===")

func _test_json_file_exists() -> void:
	print("\n--- Testing JSON File Existence ---")
	var json_path = "res://data/stage_progression_matrix.json"
	if ResourceLoader.exists(json_path):
		print("✓ stage_progression_matrix.json exists")
	else:
		print("❌ stage_progression_matrix.json not found")

func _test_json_structure() -> void:
	print("\n--- Testing JSON Structure ---")
	var json_path = "res://data/stage_progression_matrix.json"
	if not ResourceLoader.exists(json_path):
		return
	
	var file = FileAccess.open(json_path, FileAccess.READ)
	if not file:
		print("❌ Failed to open JSON file")
		return
	
	var content = file.get_as_text()
	file.close()
	
	var json = JSON.parse_string(content)
	if json is Dictionary:
		print("✓ JSON is valid Dictionary")
		print("  Top-level keys: %s" % json.keys())
	else:
		print("❌ JSON is not a valid Dictionary")

func _test_stage_configs() -> void:
	print("\n--- Testing Stage Configs ---")
	var json_path = "res://data/stage_progression_matrix.json"
	if not ResourceLoader.exists(json_path):
		return
	
	var file = FileAccess.open(json_path, FileAccess.READ)
	if not file:
		return
	
	var content = file.get_as_text()
	file.close()
	
	var json = JSON.parse_string(content)
	if not json is Dictionary:
		return
	
	# Check for cycles
	if json.has("cycles"):
		print("✓ Cycles key exists")
		var cycles = json["cycles"]
		if cycles is Array and cycles.size() > 0:
			print("  Number of cycles: %d" % cycles.size())
		else:
			print("❌ Cycles is empty or not an array")
	else:
		print("❌ Cycles key missing")
	
	# Check for global settings
	if json.has("global_settings"):
		print("✓ Global settings key exists")
		var settings = json["global_settings"]
		if settings is Dictionary:
			print("  Global settings keys: %s" % settings.keys())
	else:
		print("❌ Global settings key missing")

func _test_archetypes() -> void:
	print("\n--- Testing Archetypes ---")
	var json_path = "res://data/stage_progression_matrix.json"
	if not ResourceLoader.exists(json_path):
		return
	
	var file = FileAccess.open(json_path, FileAccess.READ)
	if not file:
		return
	
	var content = file.get_as_text()
	file.close()
	
	var json = JSON.parse_string(content)
	if not json is Dictionary:
		return
	
	# Expected archetypes
	var expected_archetypes = [
		"Entry Stream",
		"Rush Protocol",
		"Shielded Packets",
		"Splitting Malware",
		"EMP Jammer",
		"Re-routing Logic",
		"Regenerative Stream",
		"Swarm Carrier",
		"Phantom Grid",
		"Final Meltdown"
	]
	
	print("Checking for expected archetypes:")
	for archetype in expected_archetypes:
		var found = false
		if json.has("cycles"):
			for cycle in json["cycles"]:
				if cycle is Dictionary and cycle.has("stages"):
					for stage in cycle["stages"]:
						if stage is Dictionary and stage.get("archetype") == archetype:
							found = true
							break
				if found:
					break
		
		if found:
			print("✓ Archetype found: %s" % archetype)
		else:
			print("❌ Archetype missing: %s" % archetype)
