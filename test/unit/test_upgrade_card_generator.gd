extends GutTest

func _new_generator():
	var generator_script = load("res://systems/upgrade_card_generator.gd")
	assert_not_null(generator_script, "UpgradeCardGenerator script should load")
	var generator = generator_script.new()
	assert_not_null(generator, "UpgradeCardGenerator should instantiate")
	return generator

func test_card_pool_loaded() -> void:
	var generator = _new_generator()
	assert_true(not generator.card_pool.is_empty(), "Upgrade card pool should not be empty")
	generator.free()

func test_random_selection_returns_unique_cards() -> void:
	var generator = _new_generator()
	var selection = generator.generate_random_cards(3, 1)
	assert_eq(selection.size(), 3, "generate_random_cards should return the requested number of cards")
	generator.free()

	var ids = []
	for card in selection:
		ids.append(card.get("id", ""))

	var seen = []
	for item_id in ids:
		assert_false(seen.has(item_id), "Selected cards should all be unique")
		seen.append(item_id)

func test_stage_filtering_exposes_late_cards() -> void:
	var generator = _new_generator()
	var advanced_cards = generator.get_all_cards(20)
	assert_true(advanced_cards.size() > 0, "Advanced stage card pool should not be empty")

	var advanced_ids = []
	for card in advanced_cards:
		advanced_ids.append(card.get("id", ""))

	assert_true(advanced_ids.has("overclock"), "Advanced stage cards should include overclock")
	assert_true(advanced_ids.has("tech_credit_boost"), "Advanced stage cards should include tech_credit_boost")
	generator.free()

func test_sample_card_has_required_fields() -> void:
	var generator = _new_generator()
	var selection = generator.generate_random_cards(3, 1)
	assert_true(selection.size() > 0, "Selection should return cards")

	var sample_card = selection[0]
	var required_fields = ["id", "type", "title", "description", "value", "rarity"]
	for field in required_fields:
		assert_true(sample_card.has(field), "Sample upgrade card should contain %s" % field)
	generator.free()
