extends GutTest

func test_main_gundam_scene_contains_ui_elements() -> void:
	var scene_path = "res://scenes/screens/main_gundam/main_gundam_scene.tscn"
	assert_true(ResourceLoader.exists(scene_path), "Main Gundam scene should exist")
	var file = FileAccess.open(scene_path, FileAccess.READ)
	assert_not_null(file, "Main Gundam scene file should open")
	var scene_text = file.get_as_text()
	file.close()

	var expected_nodes = [
		"StageLabel",
		"WaveLabel",
		"AliveCounterLabel",
		"ClockLabel",
        "SettingsButton"
	]
	for node_name in expected_nodes:
		assert_true(scene_text.find("node name=\"%s\"" % node_name) != -1, "Main Gundam scene should contain %s" % node_name)

func test_battle_hud_elements_exist() -> void:
	var scene_path = "res://scenes/screens/main_gundam/main_gundam_scene.tscn"
	assert_true(ResourceLoader.exists(scene_path), "Main Gundam scene should exist")
	var file = FileAccess.open(scene_path, FileAccess.READ)
	assert_not_null(file, "Main Gundam scene file should open")
	var scene_text = file.get_as_text()
	file.close()

	var hud_elements = [
		"StageLabel",
		"WaveLabel",
		"AliveCounterLabel",
        "ClockLabel"
	]
	for node_name in hud_elements:
		assert_true(scene_text.find("node name=\"%s\"" % node_name) != -1, "Battle HUD should contain %s" % node_name)

func test_main_navigation_buttons_exist() -> void:
	var scene_path = "res://scenes/screens/main_gundam/main_gundam_scene.tscn"
	assert_true(ResourceLoader.exists(scene_path), "Main Gundam scene should exist")
	var file = FileAccess.open(scene_path, FileAccess.READ)
	assert_not_null(file, "Main Gundam scene file should open")
	var scene_text = file.get_as_text()
	file.close()

	var nav_buttons = [
		"ShopButton",
		"HangarButton",
		"UpgradesButton",
		"BattlePassButton",
        "LeaderboardButton"
	]
	for node_name in nav_buttons:
		assert_true(scene_text.find("node name=\"%s\"" % node_name) != -1, "Main navigation should contain %s" % node_name)

func test_upgrades_screen_contains_core_ui_and_methods() -> void:
	var scene_path = "res://scenes/screens/upgrades_screen.tscn"
	assert_true(ResourceLoader.exists(scene_path), "Upgrades screen should exist")
	var scene = load(scene_path)
	assert_not_null(scene, "Upgrades screen should load")

	var instance = scene.instantiate()
	if instance:
		var expected_nodes = [
			"CreditsLabel",
			"BallisticCore",
			"EnergyMatrix"
		]
		for node_name in expected_nodes:
			assert_true(instance.find_child(node_name, true, false) != null, "Upgrades screen should contain %s" % node_name)

		var required_methods = [
			"_load_upgrade_data",
			"_build_upgrade_ui",
			"_on_upgrade_purchased"
		]
		for method_name in required_methods:
			assert_true(instance.has_method(method_name), "Upgrades screen instance should have %s" % method_name)
		instance.queue_free()
		return

	var file = FileAccess.open(scene_path, FileAccess.READ)
	assert_not_null(file, "Upgrades screen file should open")
	var scene_text = file.get_as_text()
	file.close()

	var expected_nodes = [
		"BackButton",
		"CreditsLabel",
		"BallisticCore",
		"EnergyMatrix"
	]
	for node_name in expected_nodes:
		assert_true(scene_text.find("node name=\"%s\"" % node_name) != -1, "Upgrades screen should contain %s" % node_name)

	var script = load("res://scenes/screens/upgrades_screen.gd")
	assert_true(script is Script, "Upgrades screen script should load")

	var required_methods = [
		"_load_upgrade_data",
		"_build_upgrade_ui",
		"_on_upgrade_purchased"
	]
	for method_name in required_methods:
		assert_true(script.has_method(method_name), "Upgrades screen script should have %s" % method_name)
