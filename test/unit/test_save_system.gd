extends Node

# Test SaveSystem functionality (EPIC-08 Godot Data Layer)

func _ready() -> void:
	print("=== Testing SaveSystem ===")
	_test_autoload_exists()
	_test_required_methods()
	_test_save_load()
	_test_upgrade_system()
	_test_economy()
	_test_mecha_progression()
	print("\n=== SaveSystem Tests Complete ===")

func _test_autoload_exists() -> void:
	print("\n--- Testing Autoload Existence ---")
	var save_system = get_node_or_null("/root/SaveSystem")
	if save_system:
		print("✓ SaveSystem autoload exists")
	else:
		print("❌ SaveSystem autoload not found")

func _test_required_methods() -> void:
	print("\n--- Testing Required Methods ---")
	var save_system = get_node_or_null("/root/SaveSystem")
	if not save_system:
		print("❌ SaveSystem not available for testing")
		return
	
	var required_methods = [
		"load_game",
		"save_game",
		"get_current_stage",
		"get_highest_stage",
		"unlock_mecha",
		"set_active_mecha",
		"get_upgrade_level",
		"set_upgrade_level",
		"get_tech_credits",
		"set_tech_credits",
		"add_tech_credits",
		"deduct_tech_credits"
	]
	
	for method_name in required_methods:
		if save_system.has_method(method_name):
			print("✓ Method exists: %s" % method_name)
		else:
			print("❌ Method missing: %s" % method_name)

func _test_save_load() -> void:
	print("\n--- Testing Save/Load ---")
	var save_system = get_node_or_null("/root/SaveSystem")
	if not save_system:
		return
	
	# Test saving
	save_system.save_game()
	print("✓ save_game executed")
	
	# Test loading
	save_system.load_game()
	print("✓ load_game executed")

func _test_upgrade_system() -> void:
	print("\n--- Testing Upgrade System ---")
	var save_system = get_node_or_null("/root/SaveSystem")
	if not save_system:
		return
	
	# Test getting upgrade level
	var level = save_system.get_upgrade_level("ballistic_core", "chassis_calibrator_level")
	print("✓ get_upgrade_level executed (returned: %d)" % level)
	
	# Test setting upgrade level
	save_system.set_upgrade_level("ballistic_core", "chassis_calibrator_level", 1)
	print("✓ set_upgrade_level executed")

func _test_economy() -> void:
	print("\n--- Testing Economy ---")
	var save_system = get_node_or_null("/root/SaveSystem")
	if not save_system:
		return
	
	# Test getting tech credits
	var credits = save_system.get_tech_credits()
	print("✓ get_tech_credits executed (returned: %d)" % credits)
	
	# Test adding tech credits
	save_system.add_tech_credits(100)
	var new_credits = save_system.get_tech_credits()
	if new_credits > credits:
		print("✓ add_tech_credits works")
	else:
		print("❌ add_tech_credits failed")
	
	# Test deducting tech credits
	save_system.deduct_tech_credits(50)
	var final_credits = save_system.get_tech_credits()
	if final_credits < new_credits:
		print("✓ deduct_tech_credits works")
	else:
		print("❌ deduct_tech_credits failed")

func _test_mecha_progression() -> void:
	print("\n--- Testing Mecha Progression ---")
	var save_system = get_node_or_null("/root/SaveSystem")
	if not save_system:
		return
	
	# Test getting current stage
	var stage = save_system.get_current_stage()
	print("✓ get_current_stage executed (returned: %d)" % stage)
	
	# Test getting highest stage
	var highest = save_system.get_highest_stage()
	print("✓ get_highest_stage executed (returned: %d)" % highest)
	
	# Test unlocking mecha
	save_system.unlock_mecha("test_mecha")
	print("✓ unlock_mecha executed")
	
	# Test setting active mecha
	save_system.set_active_mecha("mecha_unit_alpha_base")
	print("✓ set_active_mecha executed")
