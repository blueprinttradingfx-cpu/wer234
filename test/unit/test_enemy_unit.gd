extends Node

# Test EnemyUnit functionality (EPIC-01 Core Combat Loop)

func _ready() -> void:
	print("=== Testing EnemyUnit ===")
	_test_scene_load()
	_test_class_exists()
	_test_required_methods()
	_test_hp_system()
	_test_damage_system()
	_test_movement()
	_test_shield_mechanics()
	_test_splitting_mechanics()
	_test_emp_mechanics()
	_test_re_routing_mechanics()
	_test_regeneration_mechanics()
	_test_carrier_mechanics()
	_test_cloak_mechanics()
	print("\n=== EnemyUnit Tests Complete ===")

func _test_scene_load() -> void:
	print("\n--- Testing Scene Load ---")
	var scene_path = "res://systems/enemy_unit.tscn"
	if not ResourceLoader.exists(scene_path):
		print("❌ Scene file not found: %s" % scene_path)
		return
	
	var scene = load(scene_path)
	if scene:
		print("✓ Scene loaded successfully")
	else:
		print("❌ Failed to load scene")

func _test_class_exists() -> void:
	print("\n--- Testing Class Existence ---")
	var scene_path = "res://systems/enemy_unit.tscn"
	if not ResourceLoader.exists(scene_path):
		return
		
	var scene = load(scene_path)
	if not scene:
		return
	
	var instance = scene.instantiate()
	add_child(instance)
	
	await get_tree().process_frame
	
	if instance is EnemyUnit:
		print("✓ Instance is EnemyUnit class")
	else:
		print("❌ Instance is not EnemyUnit class")
	
	instance.queue_free()

func _test_required_methods() -> void:
	print("\n--- Testing Required Methods ---")
	var scene_path = "res://systems/enemy_unit.tscn"
	if not ResourceLoader.exists(scene_path):
		return
		
	var scene = load(scene_path)
	if not scene:
		return
	
	var instance = scene.instantiate()
	add_child(instance)
	
	await get_tree().process_frame
	
	var required_methods = [
		"take_damage",
		"execute_destruction",
		"set_speed_modifier",
		"set_target_position",
		"enable_shield",
		"enable_splitting",
		"enable_emp",
		"enable_re_routing",
		"enable_regen",
		"enable_carrier",
		"enable_cloak",
		"is_targetable"
	]
	
	for method_name in required_methods:
		if instance.has_method(method_name):
			print("✓ Method exists: %s" % method_name)
		else:
			print("❌ Method missing: %s" % method_name)
	
	instance.queue_free()

func _test_hp_system() -> void:
	print("\n--- Testing HP System ---")
	var scene_path = "res://systems/enemy_unit.tscn"
	if not ResourceLoader.exists(scene_path):
		return
		
	var scene = load(scene_path)
	if not scene:
		return
	
	var instance = scene.instantiate()
	add_child(instance)
	
	await get_tree().process_frame
	
	# Test initial HP
	if is_equal_approx(instance.current_hp, instance.max_hp):
		print("✓ Initial HP equals max HP")
	else:
		print("❌ Initial HP does not equal max HP")
	
	# Test damage
	var initial_hp = instance.current_hp
	instance.take_damage(5.0)
	if instance.current_hp < initial_hp:
		print("✓ take_damage reduces HP")
	else:
		print("❌ take_damage does not reduce HP")
	
	instance.queue_free()

func _test_damage_system() -> void:
	print("\n--- Testing Damage System ---")
	var scene_path = "res://systems/enemy_unit.tscn"
	if not ResourceLoader.exists(scene_path):
		return
		
	var scene = load(scene_path)
	if not scene:
		return
	
	var instance = scene.instantiate()
	add_child(instance)
	
	await get_tree().process_frame
	
	# Test destruction signal
	var destroyed_called = false
	instance.destroyed.connect(func(): destroyed_called = true)
	
	instance.take_damage(1000.0)  # Overkill damage
	
	await get_tree().create_timer(0.1).timeout
	
	if destroyed_called:
		print("✓ destroyed signal emitted on death")
	else:
		print("❌ destroyed signal not emitted on death")
	
	instance.queue_free()

func _test_movement() -> void:
	print("\n--- Testing Movement ---")
	var scene_path = "res://systems/enemy_unit.tscn"
	if not ResourceLoader.exists(scene_path):
		return
		
	var scene = load(scene_path)
	if not scene:
		return
	
	var instance = scene.instantiate()
	add_child(instance)
	
	await get_tree().process_frame
	
	# Test speed modifier
	instance.set_speed_modifier(0.5)
	if is_equal_approx(instance.speed_modifier, 0.5):
		print("✓ set_speed_modifier works")
	else:
		print("❌ set_speed_modifier failed")
	
	# Test target position
	var test_pos = Vector2(100, 100)
	instance.set_target_position(test_pos)
	if instance.target_position == test_pos:
		print("✓ set_target_position works")
	else:
		print("❌ set_target_position failed")
	
	instance.queue_free()

func _test_shield_mechanics() -> void:
	print("\n--- Testing Shield Mechanics ---")
	var scene_path = "res://systems/enemy_unit.tscn"
	if not ResourceLoader.exists(scene_path):
		return
		
	var scene = load(scene_path)
	if not scene:
		return
	
	var instance = scene.instantiate()
	add_child(instance)
	
	await get_tree().process_frame
	
	# Enable shield
	instance.enable_shield(10.0, 0.5)
	if instance.max_shield_hp > 0:
		print("✓ Shield enabled successfully")
	else:
		print("❌ Shield not enabled")
	
	# Test shield absorption
	var initial_hp = instance.current_hp
	instance.take_damage(5.0)
	if instance.current_hp == initial_hp:  # HP should not change if shield absorbs
		print("✓ Shield absorbs damage")
	else:
		print("❌ Shield does not absorb damage")
	
	instance.queue_free()

func _test_splitting_mechanics() -> void:
	print("\n--- Testing Splitting Mechanics ---")
	var scene_path = "res://systems/enemy_unit.tscn"
	if not ResourceLoader.exists(scene_path):
		return
		
	var scene = load(scene_path)
	if not scene:
		return
	
	var instance = scene.instantiate()
	add_child(instance)
	
	await get_tree().process_frame
	
	# Enable splitting
	instance.enable_splitting(2, 0, 2, 0.5)
	if instance.can_split:
		print("✓ Splitting enabled successfully")
	else:
		print("❌ Splitting not enabled")
	
	instance.queue_free()

func _test_emp_mechanics() -> void:
	print("\n--- Testing EMP Mechanics ---")
	var scene_path = "res://systems/enemy_unit.tscn"
	if not ResourceLoader.exists(scene_path):
		return
		
	var scene = load(scene_path)
	if not scene:
		return
	
	var instance = scene.instantiate()
	add_child(instance)
	
	await get_tree().process_frame
	
	# Enable EMP
	instance.enable_emp(150.0, 2.0, true)
	if instance.has_emp:
		print("✓ EMP enabled successfully")
	else:
		print("❌ EMP not enabled")
	
	instance.queue_free()

func _test_re_routing_mechanics() -> void:
	print("\n--- Testing Re-routing Mechanics ---")
	var scene_path = "res://systems/enemy_unit.tscn"
	if not ResourceLoader.exists(scene_path):
		return
		
	var scene = load(scene_path)
	if not scene:
		return
	
	var instance = scene.instantiate()
	add_child(instance)
	
	await get_tree().process_frame
	
	# Enable re-routing
	instance.enable_re_routing(3.0)
	if instance.can_re_route:
		print("✓ Re-routing enabled successfully")
	else:
		print("❌ Re-routing not enabled")
	
	instance.queue_free()

func _test_regeneration_mechanics() -> void:
	print("\n--- Testing Regeneration Mechanics ---")
	var scene_path = "res://systems/enemy_unit.tscn"
	if not ResourceLoader.exists(scene_path):
		return
		
	var scene = load(scene_path)
	if not scene:
		return
	
	var instance = scene.instantiate()
	add_child(instance)
	
	await get_tree().process_frame
	
	# Enable regeneration
	instance.enable_regen(1.0, 2.0)
	if instance.can_regen:
		print("✓ Regeneration enabled successfully")
	else:
		print("❌ Regeneration not enabled")
	
	instance.queue_free()

func _test_carrier_mechanics() -> void:
	print("\n--- Testing Carrier Mechanics ---")
	var scene_path = "res://systems/enemy_unit.tscn"
	if not ResourceLoader.exists(scene_path):
		return
		
	var scene = load(scene_path)
	if not scene:
		return
	
	var instance = scene.instantiate()
	add_child(instance)
	
	await get_tree().process_frame
	
	# Enable carrier
	instance.enable_carrier(5, 2.0, 0.3)
	if instance.is_carrier:
		print("✓ Carrier enabled successfully")
	else:
		print("❌ Carrier not enabled")
	
	instance.queue_free()

func _test_cloak_mechanics() -> void:
	print("\n--- Testing Cloak Mechanics ---")
	var scene_path = "res://systems/enemy_unit.tscn"
	if not ResourceLoader.exists(scene_path):
		return
		
	var scene = load(scene_path)
	if not scene:
		return
	
	var instance = scene.instantiate()
	add_child(instance)
	
	await get_tree().process_frame
	
	# Enable cloak
	instance.enable_cloak(3.0, 5.0)
	if instance.can_cloak:
		print("✓ Cloak enabled successfully")
	else:
		print("❌ Cloak not enabled")
	
	# Test is_targetable
	if instance.has_method("is_targetable"):
		var targetable = instance.is_targetable()
		print("✓ is_targetable method works (returns: %s)" % targetable)
	else:
		print("❌ is_targetable method missing")
	
	instance.queue_free()
