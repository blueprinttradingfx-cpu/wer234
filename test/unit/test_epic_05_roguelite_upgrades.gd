extends GutTest

func _new_generator():
	var generator_script = load("res://systems/upgrade_card_generator.gd")
	assert_not_null(generator_script, "UpgradeCardGenerator script should load")
	var generator = generator_script.new()
	assert_not_null(generator, "UpgradeCardGenerator should instantiate")
	return generator

func test_roguelite_card_generation_loads() -> void:
	var generator = _new_generator()
	assert_true(not generator.card_pool.is_empty(), "Upgrade card pool should load")

	var cards_stage_1 = generator.generate_random_cards(3, 1)
	assert_eq(cards_stage_1.size(), 3, "generate_random_cards should return 3 cards for stage 1")

	var sample_card = cards_stage_1[0]
	var required_fields = ["id", "type", "title", "description", "value", "rarity"]
	for field in required_fields:
		assert_true(sample_card.has(field), "Sample upgrade card should contain %s" % field)
	generator.free()

func test_roguelite_stage_filtering_exposes_late_cards() -> void:
	var generator = _new_generator()
	var advanced_cards = generator.get_all_cards(20)
	assert_true(advanced_cards.size() > 0, "Advanced stage card pool should not be empty")

	var advanced_ids = []
	for card in advanced_cards:
		advanced_ids.append(card.get("id", ""))
	assert_true(advanced_ids.has("overclock"), "Advanced card pool should include overclock")
	assert_true(advanced_ids.has("tech_credit_boost"), "Advanced card pool should include tech_credit_boost")
	generator.free()

func test_roguelite_effect_system_definitions() -> void:
	var effect_system_script = load("res://systems/upgrade_effect_system.gd")
	assert_not_null(effect_system_script, "UpgradeEffectSystem script should load")
	var effect_system = effect_system_script.new()
	assert_not_null(effect_system, "UpgradeEffectSystem should instantiate")

	assert_true(not effect_system.effect_definitions.is_empty(), "Effect definitions should load")
	var required_effects = ["attack_speed", "damage_boost", "shield_boost", "overclock"]
	for effect in required_effects:
		assert_true(effect_system.effect_definitions.has(effect), "Effect definitions should include %s" % effect)
	effect_system.free()

func test_roguelite_overlay_signals_exist() -> void:
	var overlay_script = load("res://scenes/overlays/software_upgrade_overlay.gd")
	assert_not_null(overlay_script, "SoftwareUpgradeOverlay script should load")
	var sample_overlay = overlay_script.new()
	assert_has_signal(sample_overlay, "upgrade_selected", "Overlay should define upgrade_selected signal")
	assert_has_signal(sample_overlay, "re_roll_requested", "Overlay should define re_roll_requested signal")
	sample_overlay.free()
