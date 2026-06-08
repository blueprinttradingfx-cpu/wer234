extends Node

# Ensure "extends Node" is exactly on line 1 without leading spaces or characters.

func _ready() -> void:
	print("=== Testing Main Gundam Scene ===")
	_test_scene_load()
	_test_required_nodes()

func _test_scene_load() -> void:
	print("\n--- Testing Scene Load ---")
	var scene_path = "res://scenes/screens/main_gundam/main_gundam_scene.tscn"
	if not ResourceLoader.exists(scene_path):
		print("❌ Scene file not found: %s" % scene_path)
		return
	
	var scene = load(scene_path)
	if scene:
		print("✓ Scene loaded successfully")
	else:
		print("❌ Failed to load scene")

func _test_required_nodes() -> void:
	print("\n--- Testing Required Nodes ---")
	var scene_path = "res://scenes/screens/main_gundam/main_gundam_scene.tscn"
	if not ResourceLoader.exists(scene_path):
		return
		
	var scene = load(scene_path)
	if not scene:
		return
	
	var instance = scene.instantiate()
	add_child(instance)
	
	# Wait for the scene tree to initialize nodes safely
	await get_tree().process_frame
	
	var required_nodes = [
		"AtkSpdBtn",
		"PierceBtn", 
		"CooldownBtn",
		"MoveSpdBtn",
		"MatrixBtn",
		"OverclockBtn",
		"AliveCounterLabel",
		"ClockLabel",
		"WaveLabel",
		"GameplayArena",
		"SettingsButton",
		"BatteryProgress",
		"ShopButton",
		"HangarButton",
		"UpgradesButton",
		"BattlePassButton",
		"LeaderboardButton"
	]
	
	for node_name in required_nodes:
		var node = instance.get_node_or_null("%" + node_name)
		if node:
			print("✓ Found node: %s" % node_name)
		else:
			print("❌ Missing node: %s" % node_name)
			
	instance.queue_free()