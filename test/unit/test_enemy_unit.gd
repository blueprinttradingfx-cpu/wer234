extends GutTest

const SCENE_PATH = "res://systems/enemy_unit.tscn"

func test_enemy_unit_scene_loads() -> void:
	assert_true(ResourceLoader.exists(SCENE_PATH), "EnemyUnit scene should exist")
	var scene = load(SCENE_PATH)
	assert_not_null(scene, "EnemyUnit scene should load")

func test_enemy_unit_instantiates_as_class() -> void:
	var scene = load(SCENE_PATH)
	assert_not_null(scene, "EnemyUnit scene should load")

	var instance = scene.instantiate()
	add_child(instance)
	await get_tree().process_frame
	assert_true(instance is EnemyUnit, "EnemyUnit instance should be of type EnemyUnit")
	instance.queue_free()

func test_enemy_unit_has_required_methods() -> void:
	var scene = load(SCENE_PATH)
	assert_not_null(scene, "EnemyUnit scene should load")

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
		assert_true(instance.has_method(method_name), "EnemyUnit should have method %s" % method_name)

	instance.queue_free()

func test_enemy_unit_hp_and_damage() -> void:
	var scene = load(SCENE_PATH)
	assert_not_null(scene, "EnemyUnit scene should load")

	var instance = scene.instantiate()
	add_child(instance)
	await get_tree().process_frame

	assert_true(is_equal_approx(instance.current_hp, instance.max_hp), "EnemyUnit should start at max HP")
	var initial_hp = instance.current_hp
	instance.take_damage(5.0)
	assert_true(instance.current_hp < initial_hp, "take_damage should reduce HP")
	instance.queue_free()

var _enemy_destroyed_called: bool = false

func _on_test_enemy_destroyed() -> void:
	_enemy_destroyed_called = true

func test_enemy_unit_destruction_signal() -> void:
	var scene = load(SCENE_PATH)
	assert_not_null(scene, "EnemyUnit scene should load")

	var instance = scene.instantiate()
	add_child(instance)
	await get_tree().process_frame

	_enemy_destroyed_called = false
	instance.destroyed.connect(Callable(self, "_on_test_enemy_destroyed"))

	instance.take_damage(1000.0)
	await get_tree().create_timer(0.1).timeout
	assert_true(_enemy_destroyed_called, "EnemyUnit should emit destroyed signal on death")

func test_enemy_unit_movement_controls() -> void:
	var scene = load(SCENE_PATH)
	assert_not_null(scene, "EnemyUnit scene should load")

	var instance = scene.instantiate()
	add_child(instance)
	await get_tree().process_frame

	instance.set_speed_modifier(0.5)
	assert_true(is_equal_approx(instance.speed_modifier, 0.5), "set_speed_modifier should update speed_modifier")

	var test_pos = Vector2(100, 100)
	instance.set_target_position(test_pos)
	assert_eq(instance.target_position, test_pos, "set_target_position should update target_position")
	instance.queue_free()

func test_enemy_unit_shield_mechanics() -> void:
	var scene = load(SCENE_PATH)
	assert_not_null(scene, "EnemyUnit scene should load")

	var instance = scene.instantiate()
	add_child(instance)
	await get_tree().process_frame

	instance.enable_shield(10.0, 0.5)
	assert_true(instance.max_shield_hp > 0, "enable_shield should increase max_shield_hp")

	var initial_hp = instance.current_hp
	instance.take_damage(5.0)
	assert_eq(instance.current_hp, initial_hp, "Shield should absorb damage if active")
	instance.queue_free()

func test_enemy_unit_splitting_mechanics() -> void:
	var scene = load(SCENE_PATH)
	assert_not_null(scene, "EnemyUnit scene should load")

	var instance = scene.instantiate()
	add_child(instance)
	await get_tree().process_frame

	instance.enable_splitting(2, 0, 2, 0.5)
	assert_true(instance.can_split, "enable_splitting should set can_split")
	instance.queue_free()

func test_enemy_unit_emp_mechanics() -> void:
	var scene = load(SCENE_PATH)
	assert_not_null(scene, "EnemyUnit scene should load")

	var instance = scene.instantiate()
	add_child(instance)
	await get_tree().process_frame

	instance.enable_emp(150.0, 2.0, true)
	assert_true(instance.has_emp, "enable_emp should set has_emp")
	instance.queue_free()

func test_enemy_unit_rerouting_mechanics() -> void:
	var scene = load(SCENE_PATH)
	assert_not_null(scene, "EnemyUnit scene should load")

	var instance = scene.instantiate()
	add_child(instance)
	await get_tree().process_frame

	instance.enable_re_routing(3.0)
	assert_true(instance.can_re_route, "enable_re_routing should set can_re_route")
	instance.queue_free()

func test_enemy_unit_regeneration_mechanics() -> void:
	var scene = load(SCENE_PATH)
	assert_not_null(scene, "EnemyUnit scene should load")

	var instance = scene.instantiate()
	add_child(instance)
	await get_tree().process_frame

	instance.enable_regen(1.0, 2.0)
	assert_true(instance.can_regen, "enable_regen should set can_regen")
	instance.queue_free()

func test_enemy_unit_carrier_mechanics() -> void:
	var scene = load(SCENE_PATH)
	assert_not_null(scene, "EnemyUnit scene should load")

	var instance = scene.instantiate()
	add_child(instance)
	await get_tree().process_frame

	instance.enable_carrier(5, 2.0, 0.3)
	assert_true(instance.is_carrier, "enable_carrier should set is_carrier")
	instance.queue_free()

func test_enemy_unit_cloak_mechanics() -> void:
	var scene = load(SCENE_PATH)
	assert_not_null(scene, "EnemyUnit scene should load")

	var instance = scene.instantiate()
	add_child(instance)
	await get_tree().process_frame

	instance.enable_cloak(3.0, 5.0)
	assert_true(instance.can_cloak, "enable_cloak should set can_cloak")

	assert_true(instance.has_method("is_targetable"), "EnemyUnit should have is_targetable")
	assert_true(instance.is_targetable(), "is_targetable should return a boolean")
	instance.queue_free()
