extends GutTest

func test_effect_definitions_load() -> void:
	var effect_system = preload("res://systems/upgrade_effect_system.gd").new()
	add_child(effect_system)
	assert_true(not effect_system.effect_definitions.is_empty(), "UpgradeEffectSystem should load effect definitions")
	assert_true(effect_system.effect_definitions.has("overclock"), "Effect definitions should include overclock")
	assert_true(effect_system.effect_definitions.has("attack_speed"), "Effect definitions should include attack_speed")
	assert_true(effect_system.effect_definitions.has("damage_boost"), "Effect definitions should include damage_boost")
	effect_system.queue_free()

func test_overclock_effect_has_duration() -> void:
	var effect_system = preload("res://systems/upgrade_effect_system.gd").new()
	add_child(effect_system)
	var overclock_def = effect_system.effect_definitions.get("overclock", {})
	assert_true(overclock_def is Dictionary, "Overclock definition should be a Dictionary")
	assert_true(overclock_def.get("duration_waves", 0) > 0, "Overclock should declare a positive duration_waves")
	effect_system.queue_free()
