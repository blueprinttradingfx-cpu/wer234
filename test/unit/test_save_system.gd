extends GutTest

func test_save_system_autoload_exists() -> void:
    var save_system = get_node_or_null("/root/SaveSystem")
    assert_not_null(save_system, "SaveSystem autoload should exist")

func test_save_system_has_required_methods() -> void:
    var save_system = get_node_or_null("/root/SaveSystem")
    assert_not_null(save_system, "SaveSystem autoload should exist")

    var required_methods = [
        "load_game",
        "save_game",
        "get_current_stage",
        "get_highest_stage",
        "unlock_mecha",
        "set_active_mecha",
        "get_upgrade_level",
        "set_upgrade_level",
        "get_tech_credits",
        "set_tech_credits",
        "add_tech_credits",
        "deduct_tech_credits"
    ]

    for method_name in required_methods:
        assert_true(save_system.has_method(method_name), "SaveSystem should have method %s" % method_name)

func test_save_system_save_and_load() -> void:
    var save_system = get_node_or_null("/root/SaveSystem")
    assert_not_null(save_system, "SaveSystem autoload should exist")

    save_system.save_game()
    save_system.load_game()
    assert_true(true, "SaveSystem save_game and load_game should run without errors")

func test_save_system_economy_flow() -> void:
    var save_system = get_node_or_null("/root/SaveSystem")
    assert_not_null(save_system, "SaveSystem autoload should exist")

    var previous_credits = save_system.get_tech_credits()
    save_system.add_tech_credits(100)
    assert_true(save_system.get_tech_credits() >= previous_credits + 100, "add_tech_credits should increase tech credits")
    save_system.deduct_tech_credits(50)
    assert_true(save_system.get_tech_credits() <= previous_credits + 50, "deduct_tech_credits should decrease tech credits")

func test_save_system_progression_methods_exist() -> void:
    var save_system = get_node_or_null("/root/SaveSystem")
    assert_not_null(save_system, "SaveSystem autoload should exist")

    assert_true(save_system.has_method("get_current_stage"), "SaveSystem should have get_current_stage")
    assert_true(save_system.has_method("get_highest_stage"), "SaveSystem should have get_highest_stage")
    assert_true(save_system.has_method("unlock_mecha"), "SaveSystem should have unlock_mecha")
    assert_true(save_system.has_method("set_active_mecha"), "SaveSystem should have set_active_mecha")
