extends GutTest

const SCENE_PATH = "res://systems/mecha_entity.tscn"

func test_mecha_entity_scene_loads() -> void:
    assert_true(ResourceLoader.exists(SCENE_PATH), "MechaEntity scene should exist")

func test_mecha_entity_instantiates_as_class() -> void:
    var scene = load(SCENE_PATH)
    assert_not_null(scene, "MechaEntity scene should load")

    var instance = scene.instantiate()
    add_child(instance)
    await get_tree().process_frame
    assert_true(instance is MechaEntity, "MechaEntity instance should be class MechaEntity")
    instance.queue_free()

func test_mecha_entity_has_required_methods_and_signals() -> void:
    var scene = load(SCENE_PATH)
    assert_not_null(scene, "MechaEntity scene should load")

    var instance = scene.instantiate()
    add_child(instance)
    await get_tree().process_frame

    var required_methods = [
        "set_weapon_system",
        "get_missile_cooldown_percent",
        "start_missile_cooldown"
    ]
    for method_name in required_methods:
        assert_true(instance.has_method(method_name), "MechaEntity should have method %s" % method_name)

    assert_has_signal(instance, "missile_fired", "MechaEntity should emit missile_fired")
    assert_has_signal(instance, "stats_updated", "MechaEntity should emit stats_updated")
    instance.queue_free()

func test_mecha_entity_missile_system_query() -> void:
    var scene = load(SCENE_PATH)
    assert_not_null(scene, "MechaEntity scene should load")
    var instance = scene.instantiate()
    add_child(instance)
    await get_tree().process_frame

    assert_true(is_instance_valid(instance), "MechaEntity instance should be valid")
    assert_true(instance.get_missile_cooldown_percent() >= 0.0, "get_missile_cooldown_percent should return a numeric value")
    instance.queue_free()
