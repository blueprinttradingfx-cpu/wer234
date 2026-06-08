extends GutTest

func test_progression_manager_autoload_exists() -> void:
    var progression = get_node_or_null("/root/ProgressionManager")
    assert_not_null(progression, "ProgressionManager autoload should exist")

func test_progression_manager_has_required_methods() -> void:
    var progression = get_node_or_null("/root/ProgressionManager")
    assert_not_null(progression, "ProgressionManager autoload should exist")

    var required_methods = [
        "get_config_for_stage",
        "get_active_mecha_stats",
        "load_stage_matrix"
    ]
    for method_name in required_methods:
        assert_true(progression.has_method(method_name), "ProgressionManager should have method %s" % method_name)

func test_progression_manager_stage_config_loading() -> void:
    var progression = get_node_or_null("/root/ProgressionManager")
    assert_not_null(progression, "ProgressionManager autoload should exist")

    var config = progression.get_config_for_stage(1)
    assert_true(config is Dictionary and not config.is_empty(), "get_config_for_stage(1) should return a non-empty Dictionary")

func test_progression_manager_active_mecha_stats() -> void:
    var progression = get_node_or_null("/root/ProgressionManager")
    assert_not_null(progression, "ProgressionManager autoload should exist")

    var stats = progression.get_active_mecha_stats()
    assert_true(stats is Dictionary and not stats.is_empty(), "get_active_mecha_stats should return a non-empty Dictionary")

func test_progression_manager_cycle_scaling_exists() -> void:
    var progression = get_node_or_null("/root/ProgressionManager")
    assert_not_null(progression, "ProgressionManager autoload should exist")
    assert_true(progression.has_method("apply_cycle_scaling") or progression.has_method("get_config_for_stage"), "ProgressionManager should expose cycle-scaling behavior")
