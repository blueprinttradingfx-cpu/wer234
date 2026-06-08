extends GutTest

var test_scenes = [
	"res://test/unit/test_enemy_unit.gd",
	"res://test/unit/test_battle_manager.gd",
	"res://test/unit/test_progression_manager.gd",
	"res://test/unit/test_save_system.gd",
	"res://test/unit/test_economy_manager.gd",
	"res://test/unit/test_mecha_entity.gd",
	"res://test/unit/test_stage_configurations.gd",
    "res://test/unit/test_ui_ux.gd"
]

func test_critical_epics_test_files_exist() -> void:
	for test_path in test_scenes:
		assert_true(ResourceLoader.exists(test_path), "Critical epic test file should exist: %s" % test_path)

func test_critical_epics_scripts_load() -> void:
	for test_path in test_scenes:
		var script = load(test_path)
		assert_not_null(script, "Critical epic test script should load: %s" % test_path)
		var instance = script.new()
