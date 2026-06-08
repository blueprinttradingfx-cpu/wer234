extends Node

# Test WeaponSystem functionality

func _ready() -> void:
	print("=== Testing WeaponSystem ===")
	_test_scene_load()
	_test_class_exists()
	_test_required_methods()
	print("\n=== WeaponSystem Tests Complete ===")

func _test_scene_load() -> void:
	print("\n--- Testing Scene Load ---")
	var scene_path = "res://systems/weapon_system.tscn"
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
	var scene_path = "res://systems/weapon_system.tscn"
	if not ResourceLoader.exists(scene_path):
		return
		
	var scene = load(scene_path)
	if not scene:
		return
	
	var instance = scene.instantiate()
	add_child(instance)
	
	await get_tree().process_frame
	
	if instance is WeaponSystem:
		print("✓ Instance is WeaponSystem class")
	else:
		print("❌ Instance is not WeaponSystem class")
	
	instance.queue_free()

func _test_required_methods() -> void:
	print("\n--- Testing Required Methods ---")
	var scene_path = "res://systems/weapon_system.tscn"
	if not ResourceLoader.exists(scene_path):
		return
		
	var scene = load(scene_path)
	if not scene:
		return
	
	var instance = scene.instantiate()
	add_child(instance)
	
	await get_tree().process_frame
	
	var required_methods = [
		"acquire_targets",
		"execute_firing_sequence",
		"deploy_projectiles",
		"set_multi_shot_level",
		"set_base_damage",
		"set_attack_speed",
		"update_weapon_speed"
	]
	
	for method_name in required_methods:
		if instance.has_method(method_name):
			print("✓ Method exists: %s" % method_name)
		else:
			print("❌ Method missing: %s" % method_name)
	
	# Test basic method calls
	print("\n--- Testing Basic Method Calls ---")
	
	# Test set_base_damage
	instance.set_base_damage(15.0)
	if is_equal_approx(instance.base_damage, 15.0):
		print("✓ set_base_damage works")
	else:
		print("❌ set_base_damage failed")
	
	# Test set_attack_speed
	instance.set_attack_speed(3.0)
	if is_equal_approx(instance.attack_speed, 3.0):
		print("✓ set_attack_speed works")
	else:
		print("❌ set_attack_speed failed")
	
	# Test set_multi_shot_level
	instance.set_multi_shot_level(1)
	if instance.multi_shot_level == 1:
		print("✓ set_multi_shot_level works")
	else:
		print("❌ set_multi_shot_level failed")
	
	# Test clamping
	instance.set_multi_shot_level(10)
	if instance.multi_shot_level == 2:
		print("✓ Multi-shot level clamping works")
	else:
		print("❌ Multi-shot level clamping failed")
	
	instance.queue_free()
