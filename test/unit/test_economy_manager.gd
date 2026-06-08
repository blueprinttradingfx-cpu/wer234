extends GutTest

func test_save_system_autoload_exists() -> void:
	var save_system = get_node_or_null("/root/SaveSystem")
	assert_not_null(save_system, "SaveSystem autoload should exist")

func test_save_system_has_required_methods() -> void:
	var save_system = get_node_or_null("/root/SaveSystem")
	assert_not_null(save_system, "SaveSystem autoload should exist")

	var required_methods = [
		"add_tech_credits",
		"deduct_tech_credits",
		"get_tech_credits",
        "set_tech_credits"
	]
	for method_name in required_methods:
		assert_true(save_system.has_method(method_name), "SaveSystem should have method %s" % method_name)

func test_save_system_tech_credits_operations() -> void:
	var save_system = get_node_or_null("/root/SaveSystem")
	assert_not_null(save_system, "SaveSystem autoload should exist")

	var credits = save_system.get_tech_credits()
	save_system.add_tech_credits(100)
	assert_true(save_system.get_tech_credits() >= credits + 100, "add_tech_credits should increase credits")
	save_system.deduct_tech_credits(50)
	assert_true(save_system.get_tech_credits() <= credits + 50, "deduct_tech_credits should decrease credits")

func test_save_system_set_tech_credits() -> void:
	var save_system = get_node_or_null("/root/SaveSystem")
	assert_not_null(save_system, "SaveSystem autoload should exist")
	assert_true(save_system.has_method("set_tech_credits"), "SaveSystem should have set_tech_credits")
