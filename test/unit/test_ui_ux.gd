extends Node

# Test UI/UX functionality (EPIC-07 UI/UX)

func _ready() -> void:
	print("=== Testing UI/UX ===")
	_test_main_gundam_scene()
	_test_battle_hud()
	_test_main_navigation()
	_test_upgrades_screen()
	print("\n=== UI/UX Tests Complete ===")

func _test_main_gundam_scene() -> void:
	print("\n--- Testing Main Gundam Scene ---")
	var scene_path = "res://scenes/screens/main_gundam/main_gundam_scene.tscn"
	if not ResourceLoader.exists(scene_path):
		print("❌ Scene file not found: %s" % scene_path)
		return
	
	var scene = load(scene_path)
	if scene:
		print("✓ Main gundam scene loaded successfully")
		
		var instance = scene.instantiate()
		add_child(instance)
		
		await get_tree().process_frame
		
		# Check for expected UI elements
		var expected_nodes = [
			"StageLabel",
			"WaveLabel",
			"EnemyCountLabel",
			"TimerLabel",
			"SettingsButton"
		]
		
		for node_name in expected_nodes:
			var node = instance.find_child(node_name, true, false)
			if node:
				print("✓ UI element found: %s" % node_name)
			else:
				print("❌ UI element missing: %s" % node_name)
		
		instance.queue_free()
	else:
		print("❌ Failed to load scene")

func _test_battle_hud() -> void:
	print("\n--- Testing Battle HUD ---")
	var scene_path = "res://scenes/screens/main_gundam/main_gundam_scene.tscn"
	if not ResourceLoader.exists(scene_path):
		return
	
	var scene = load(scene_path)
	if not scene:
		return
	
	var instance = scene.instantiate()
	add_child(instance)
	
	await get_tree().process_frame
	
	# Check for HUD elements
	var hud_elements = [
		"StageLabel",
		"WaveLabel",
		"EnemyCountLabel",
		"TimerLabel"
	]
	
	var hud_found = false
	for node_name in hud_elements:
		var node = instance.find_child(node_name, true, false)
		if node:
			hud_found = true
			break
	
	if hud_found:
		print("✓ Battle HUD elements present")
	else:
		print("❌ Battle HUD elements missing")
	
	instance.queue_free()

func _test_main_navigation() -> void:
	print("\n--- Testing Main Navigation ---")
	var scene_path = "res://scenes/screens/main_gundam/main_gundam_scene.tscn"
	if not ResourceLoader.exists(scene_path):
		return
	
	var scene = load(scene_path)
	if not scene:
		return
	
	var instance = scene.instantiate()
	add_child(instance)
	
	await get_tree().process_frame
	
	# Check for navigation buttons
	var nav_buttons = [
		"ShopButton",
		"HangarButton",
		"UpgradesButton",
		"BattlePassButton",
		"LeaderboardButton"
	]
	
	var nav_found = false
	for node_name in nav_buttons:
		var node = instance.find_child(node_name, true, false)
		if node:
			nav_found = true
			break
	
	if nav_found:
		print("✓ Navigation buttons present")
	else:
		print("❌ Navigation buttons missing")
	
	instance.queue_free()

func _test_upgrades_screen() -> void:
	print("\n--- Testing Upgrades Screen ---")
	var scene_path = "res://scenes/screens/upgrades_screen.tscn"
	if not ResourceLoader.exists(scene_path):
		print("❌ Scene file not found: %s" % scene_path)
		return
	
	var scene = load(scene_path)
	if scene:
		print("✓ Upgrades screen loaded successfully")
		
		var instance = scene.instantiate()
		add_child(instance)
		
		await get_tree().process_frame
		
		# Check for expected UI elements
		var expected_nodes = [
			"BackButton",
			"CreditsLabel",
			"BallisticCore",
			"EnergyMatrix"
		]
		
		for node_name in expected_nodes:
			var node = instance.find_child(node_name, true, false)
			if node:
				print("✓ UI element found: %s" % node_name)
			else:
				print("❌ UI element missing: %s" % node_name)
		
		# Check for required methods
		var required_methods = [
			"_load_upgrade_data",
			"_build_upgrade_ui",
			"_on_upgrade_purchased"
		]
		
		for method_name in required_methods:
			if instance.has_method(method_name):
				print("✓ Method exists: %s" % method_name)
			else:
				print("❌ Method missing: %s" % method_name)
		
		instance.queue_free()
	else:
		print("❌ Failed to load scene")
