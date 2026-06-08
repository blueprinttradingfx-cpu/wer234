extends SceneTree

func _ready() -> void:
	print("=== Testing UpgradeCardGenerator ===")

	var generator_script = load("res://systems/upgrade_card_generator.gd")
	if not generator_script:
		print("❌ Failed to load UpgradeCardGenerator script")
		return

	var generator = generator_script.new()
	if not generator:
		print("❌ Failed to instantiate UpgradeCardGenerator")
		return

	_test_card_pool_loaded(generator)
	_test_random_selection(generator)
	_test_stage_filtering(generator)

	print("=== UpgradeCardGenerator tests complete ===")

func _test_card_pool_loaded(generator: Node) -> void:
	if not generator.card_pool or generator.card_pool.empty():
		print("❌ Card pool did not load correctly")
	else:
		print("✓ Card pool loaded with %d entries" % generator.card_pool.size())

func _test_random_selection(generator: Node) -> void:
	var selection = generator.generate_random_cards(3, 1)
	if selection.size() != 3:
		print("❌ Expected 3 cards, got %d" % selection.size())
	else:
		var ids: Array = []
		for card in selection:
			ids.append(card.get("id", ""))

		var seen: Array = []
		var duplicate_found: bool = false
		for id in ids:
			if id in seen:
				duplicate_found = true
				break
			seen.append(id)

		if duplicate_found:
			print("❌ Duplicate cards were selected in the same draw: %s" % str(ids))
		else:
			print("✓ Random card selection returns unique cards")

func _test_stage_filtering(generator: Node) -> void:
	var early_cards = generator.get_all_cards(1)
	var advanced_cards = generator.get_all_cards(20)
	if early_cards.size() == 0 or advanced_cards.size() == 0:
		print("❌ Stage filtering failed; got empty filtered pool")
	else:
		var early_ids = []
		for card in early_cards:
			early_ids.append(card.get("id", ""))
		var advanced_ids = []
		for card in advanced_cards:
			advanced_ids.append(card.get("id", ""))
		if early_ids.has("overclock"):
			print("❌ Legendary card exposed too early")
		else:
			print("✓ Stage filtering hides high-tier cards until later stages")
		if not advanced_ids.has("overclock"):
			print("❌ Advanced stage filtering did not include late-tier cards")
		else:
			print("✓ Advanced stage filtering exposes late-tier cards")
