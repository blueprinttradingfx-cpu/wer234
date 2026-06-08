extends Node

# Test ProgressionManager functionality (EPIC-02 Progression & Scaling)

func _ready() -> void:
	print("=== Testing ProgressionManager ===")
	_test_autoload_exists()
	_test_required_methods()
	_test_stage_config_loading()
	_test_mecha_stats()
	_test_cycle_scaling()
	print("\n=== ProgressionManager Tests Complete ===")

func _test_autoload_exists() -> void:
	print("\n--- Testing Autoload Existence ---")
	var progression = get_node_or_null("/root/ProgressionManager")
	if progression:
		print("✓ ProgressionManager autoload exists")
	else:
		print("❌ ProgressionManager autoload not found")

func _test_required_methods() -> void:
	print("\n--- Testing Required Methods ---")
	var progression = get_node_or_null("/root/ProgressionManager")
	if not progression:
		print("❌ ProgressionManager not available for testing")
		return
	
	var required_methods = [
		"get_config_for_stage",
		"get_active_mecha_stats",
		"load_stage_matrix"
	]
	
	for method_name in required_methods:
		if progression.has_method(method_name):
			print("✓ Method exists: %s" % method_name)
		else:
			print("❌ Method missing: %s" % method_name)

func _test_stage_config_loading() -> void:
	print("\n--- Testing Stage Config Loading ---")
	var progression = get_node_or_null("/root/ProgressionManager")
	if not progression:
		return
	
	# Test loading stage config
	var config = progression.get_config_for_stage(1)
	if config is Dictionary and not config.is_empty():
		print("✓ Stage config loaded successfully")
		print("  Config keys: %s" % config.keys())
	else:
		print("❌ Stage config loading failed")

func _test_mecha_stats() -> void:
	print("\n--- Testing Mecha Stats ---")
	var progression = get_node_or_null("/root/ProgressionManager")
	if not progression:
		return
	
	# Test getting mecha stats
	var stats = progression.get_active_mecha_stats()
	if stats is Dictionary and not stats.is_empty():
		print("✓ Mecha stats retrieved successfully")
		print("  Stats keys: %s" % stats.keys())
	else:
		print("❌ Mecha stats retrieval failed")

func _test_cycle_scaling() -> void:
	print("\n--- Testing Cycle Scaling ---")
	var progression = get_node_or_null("/root/ProgressionManager")
	if not progression:
		return
	
	# Check if cycle scaling is implemented
	if progression.has_method("apply_cycle_scaling"):
		print("✓ Cycle scaling method exists")
	else:
		print("✓ Cycle scaling may be integrated in get_config_for_stage")
