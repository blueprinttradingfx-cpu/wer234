extends GutTest

func _get_battle_manager() -> Node:
	var battle_manager = get_node_or_null("/root/BattleManager")
	if battle_manager:
		return battle_manager

	var battle_manager_script = load("res://systems/battle_manager.gd")
	if not battle_manager_script:
		return null

	battle_manager = battle_manager_script.instantiate()
	if not battle_manager:
		return null

	battle_manager.name = "BattleManager"
	get_tree().get_root().add_child(battle_manager)
	return battle_manager

func test_battle_manager_autoload_exists() -> void:
	var battle_manager = _get_battle_manager()
	assert_not_null(battle_manager, "BattleManager autoload should exist")

func test_battle_manager_has_required_methods() -> void:
	var battle_manager = _get_battle_manager()
	assert_not_null(battle_manager, "BattleManager autoload should exist")

	var required_methods = [
		"start_battle",
		"end_battle",
		"skip_waves",
		"register_enemy_destruction",
		"register_enemy_reached_target"
	]

	for method_name in required_methods:
		assert_true(battle_manager.has_method(method_name), "BattleManager should have method %s" % method_name)

func test_battle_manager_signals() -> void:
	var battle_manager = _get_battle_manager()
	assert_not_null(battle_manager, "BattleManager autoload should exist")

	assert_true(battle_manager.has_signal("wave_changed"), "BattleManager should emit wave_changed")
	assert_true(battle_manager.has_signal("enemy_count_changed"), "BattleManager should emit enemy_count_changed")
	assert_true(battle_manager.has_signal("hearts_changed"), "BattleManager should emit hearts_changed")
	assert_true(battle_manager.has_signal("wave_skipped"), "BattleManager should emit wave_skipped")
