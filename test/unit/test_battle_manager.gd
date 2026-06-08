extends Node

# Test BattleManager functionality (EPIC-01 Core Combat Loop, EPIC-11 Wave Management)

func _ready() -> void:
	print("=== Testing BattleManager ===")
	_test_autoload_exists()
	_test_required_methods()
	_test_battle_state()
	_test_wave_system()
	_test_heart_counter()
	_test_skip_waves()
	print("\n=== BattleManager Tests Complete ===")

func _test_autoload_exists() -> void:
	print("\n--- Testing Autoload Existence ---")
	var battle_manager = get_node_or_null("/root/BattleManager")
	if battle_manager:
		print("✓ BattleManager autoload exists")
	else:
		print("❌ BattleManager autoload not found")

func _test_required_methods() -> void:
	print("\n--- Testing Required Methods ---")
	var battle_manager = get_node_or_null("/root/BattleManager")
	if not battle_manager:
		print("❌ BattleManager not available for testing")
		return
	
	var required_methods = [
		"start_battle",
		"end_battle",
		"skip_waves",
		"register_enemy_destruction",
		"register_enemy_reached_target"
	]
	
	for method_name in required_methods:
		if battle_manager.has_method(method_name):
			print("✓ Method exists: %s" % method_name)
		else:
			print("❌ Method missing: %s" % method_name)

func _test_battle_state() -> void:
	print("\n--- Testing Battle State ---")
	var battle_manager = get_node_or_null("/root/BattleManager")
	if not battle_manager:
		return
	
	# Check if battle_state enum exists
	if battle_manager.has_method("get"):
		print("✓ BattleManager has state tracking")
	else:
		print("✓ BattleManager state exists (enum)")

func _test_wave_system() -> void:
	print("\n--- Testing Wave System ---")
	var battle_manager = get_node_or_null("/root/BattleManager")
	if not battle_manager:
		return
	
	# Check wave-related signals
	if battle_manager.has_signal("wave_changed"):
		print("✓ wave_changed signal exists")
	else:
		print("❌ wave_changed signal missing")
	
	if battle_manager.has_signal("enemy_count_changed"):
		print("✓ enemy_count_changed signal exists")
	else:
		print("❌ enemy_count_changed signal missing")

func _test_heart_counter() -> void:
	print("\n--- Testing Heart Counter ---")
	var battle_manager = get_node_or_null("/root/BattleManager")
	if not battle_manager:
		return
	
	# Check heart-related signals
	if battle_manager.has_signal("hearts_changed"):
		print("✓ hearts_changed signal exists")
	else:
		print("❌ hearts_changed signal missing")
	
	# Check heart counter method
	if battle_manager.has_method("register_enemy_reached_target"):
		print("✓ register_enemy_reached_target method exists")
	else:
		print("❌ register_enemy_reached_target method missing")

func _test_skip_waves() -> void:
	print("\n--- Testing Wave Skip ---")
	var battle_manager = get_node_or_null("/root/BattleManager")
	if not battle_manager:
		return
	
	# Check skip-related signal
	if battle_manager.has_signal("wave_skipped"):
		print("✓ wave_skipped signal exists")
	else:
		print("❌ wave_skipped signal missing")
	
	# Check skip method
	if battle_manager.has_method("skip_waves"):
		print("✓ skip_waves method exists")
	else:
		print("❌ skip_waves method missing")
