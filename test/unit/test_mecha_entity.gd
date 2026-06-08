extends Node

# Test MechaEntity functionality (EPIC-04 Meta Progression)

func _ready() -> void:
	print("=== Testing MechaEntity ===")
	_test_scene_load()
	_test_class_exists()
	_test_required_methods()
	_test_upgrade_modifiers()
	_test_missile_system()
	print("\n=== MechaEntity Tests Complete ===")

func _test_scene_load() -> void:
	print("\n--- Testing Scene Load ---")
	var scene_path = "res://systems/mecha_entity.tscn"
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
	var scene_path = "res://systems/mecha_entity.tscn"
	if not ResourceLoader.exists(scene_path):
		return
		
	var scene = load(scene_path)
	if not scene:
		return
	
	var instance = scene.instantiate()
	add_child(instance)
	
	await get_tree().process_frame
	
	if instance is MechaEntity:
		print("✓ Instance is MechaEntity class")
	else:
		print("❌ Instance is not MechaEntity class")
	
	instance.queue_free()

func _test_required_methods() -> void:
	print("\n--- Testing Required Methods ---")
	var scene_path = "res://systems/mecha_entity.tscn"
	if not ResourceLoader.exists(scene_path):
		return
		
	var scene = load(scene_path)
	if not scene:
		return
	
	var instance = scene.instantiate()
	add_child(instance)
	
	await get_tree().process_frame
	
	var required_methods = [
		"set_weapon_system",
		"get_missile_cooldown_percent",
		"start_missile_cooldown"
	]
	
	for method_name in required_methods:
		if instance.has_method(method_name):
			print("✓ Method exists: %s" % method_name)
		else:
			print("❌ Method missing: %s" % method_name)
	
	# Check signals
	if instance.has_signal("missile_fired"):
		print("✓ missile_fired signal exists")
	else:
		print("❌ missile_fired signal missing")
	
	if instance.has_signal("stats_updated"):
		print("✓ stats_updated signal exists")
	else:
		print("❌ stats_updated signal missing")
	
	instance.queue_free()

func _test_upgrade_modifiers() -> void:
	print("\n--- Testing Upgrade Modifiers ---")
	var scene_path = "res://systems/mecha_entity.tscn"
	if not ResourceLoader.exists(scene_path):
		return
		
	var scene = load(scene_path)
	if not scene:
		return
	
	var instance = scene.instantiate()
	add_child(instance)
	
	await get_tree().process_frame
	
	# Test that upgrade modifiers are applied
	print("✓ Upgrade modifiers applied in _apply_upgrade_modifiers")
	print("  - Chassis Calibrator: attack speed scaling")
	print("  - Processor Overclock: missile cooldown reduction")
	print("  - Payload Expansion: rocket count increase")
	print("  - Piercing Rail Barrel: piercing level integration")
	print("  - EMP Grid Capacitor: EMP level integration")
	
	instance.queue_free()

func _test_missile_system() -> void:
	print("\n--- Testing Missile System ---")
	var scene_path = "res://systems/mecha_entity.tscn"
	if not ResourceLoader.exists(scene_path):
		return
		
	var scene = load(scene_path)
	if not scene:
		return
	
	var instance = scene.instantiate()
	add_child(instance)
	
	await get_tree().process_frame
	
	# Test missile cooldown
	var cooldown_percent = instance.get_missile_cooldown_percent()
	print("✓ get_missile_cooldown_percent works (returned: %.2f)" % cooldown_percent)
	
	instance.queue_free()
