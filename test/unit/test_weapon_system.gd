extends GutTest

const SCENE_PATH = "res://systems/weapon_system.tscn"

func test_weapon_system_scene_loads() -> void:
    assert_true(ResourceLoader.exists(SCENE_PATH), "WeaponSystem scene should exist")
    var scene = load(SCENE_PATH)
    assert_not_null(scene, "WeaponSystem scene should load")

func test_weapon_system_instantiates_as_class() -> void:
    var scene = load(SCENE_PATH)
    assert_not_null(scene, "WeaponSystem scene should load")

    var instance = scene.instantiate()
    add_child(instance)
    await get_tree().process_frame
    assert_true(instance is WeaponSystem, "WeaponSystem instance should be class WeaponSystem")
    instance.queue_free()

func test_weapon_system_has_required_methods() -> void:
    var scene = load(SCENE_PATH)
    assert_not_null(scene, "WeaponSystem scene should load")

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
        assert_true(instance.has_method(method_name), "WeaponSystem should have method %s" % method_name)
    instance.queue_free()

func test_weapon_system_basic_property_updates() -> void:
    var scene = load(SCENE_PATH)
    assert_not_null(scene, "WeaponSystem scene should load")

    var instance = scene.instantiate()
    add_child(instance)
    await get_tree().process_frame

    instance.set_base_damage(15.0)
    assert_true(is_equal_approx(instance.base_damage, 15.0), "set_base_damage should update base_damage")

    instance.set_attack_speed(3.0)
    assert_true(is_equal_approx(instance.attack_speed, 3.0), "set_attack_speed should update attack_speed")

    instance.set_multi_shot_level(1)
    assert_eq(instance.multi_shot_level, 1, "set_multi_shot_level should set multi_shot_level")

    instance.set_multi_shot_level(10)
    assert_eq(instance.multi_shot_level, 2, "set_multi_shot_level should clamp multi_shot_level to 2")
    instance.queue_free()
