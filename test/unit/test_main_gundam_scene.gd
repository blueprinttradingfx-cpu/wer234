extends GutTest

const SCENE_PATH = "res://scenes/screens/main_gundam/main_gundam_scene.tscn"

func test_main_gundam_scene_loads() -> void:
	assert_true(ResourceLoader.exists(SCENE_PATH), "Main Gundam scene should exist")

func test_main_gundam_scene_contains_required_nodes() -> void:
	var file = FileAccess.open(SCENE_PATH, FileAccess.READ)
	assert_not_null(file, "Main Gundam scene file should open")
	var scene_text = file.get_as_text()
	file.close()

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
		assert_true(scene_text.find("node name=\"%s\"" % node_name) != -1, "Main Gundam scene should contain %s" % node_name)
