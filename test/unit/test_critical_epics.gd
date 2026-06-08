extends Node

# Master test runner for all critical epics

var test_scenes = [
	"res://tests/test_enemy_unit.gd",
	"res://tests/test_battle_manager.gd",
	"res://tests/test_progression_manager.gd",
	"res://tests/test_save_system.gd",
	"res://tests/test_economy_manager.gd",
	"res://tests/test_mecha_entity.gd",
	"res://tests/test_stage_configurations.gd",
	"res://tests/test_ui_ux.gd"
]

func _ready() -> void:
	print("==================================================")
	print("CRITICAL EPICS TEST SUITE")
	print("==================================================")
	print("\nRunning tests for all completed critical epics:\n")
	print("- EPIC-01: Core Combat Loop")
	print("- EPIC-02: Progression & Scaling")
	print("- EPIC-08: Godot Data Layer")
	print("- EPIC-09: Currency System")
	print("- EPIC-07: UI/UX")
	print("- EPIC-11: Wave Management")
	print("- EPIC-12: Stage Configurations")
	print("- EPIC-04: Meta Progression")
	print("- EPIC-03: Stage Content")
	print("- EPIC-10: Detailed Enemy Behaviors")
	print("\n==================================================\n")
	
	_run_all_tests()

func _run_all_tests() -> void:
	for test_path in test_scenes:
		print("\n--- Loading: %s ---" % test_path)
		
		if not ResourceLoader.exists(test_path):
			print("❌ Test file not found: %s" % test_path)
			continue
		
		var script = load(test_path)
		if not script:
			print("❌ Failed to load test script: %s" % test_path)
			continue
		
		var test_node = script.new()
		add_child(test_node)
		
		await get_tree().process_frame
		await get_tree().create_timer(0.5).timeout  # Wait for tests to complete
		
		test_node.queue_free()
		await get_tree().process_frame
	
	print("\n==================================================")
	print("CRITICAL EPICS TEST SUITE COMPLETE")
	print("==================================================")
	
	# Exit after tests complete
	await get_tree().create_timer(1.0).timeout
	get_tree().quit()
