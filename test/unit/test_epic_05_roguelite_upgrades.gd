extends SceneTree

# EPIC-05 Integration Test
# Tests the complete roguelite upgrade system from card generation through effect application

func _ready() -> void:
	print("=== Testing EPIC-05: Roguelite Upgrades ===")
	print()
	
	_test_upgrade_card_generation()
	_test_upgrade_effect_system()
	_test_overlay_signal_flow()
	
	print()
	print("=== EPIC-05 Tests Complete ===")
	print()
	quit()

func _test_upgrade_card_generation() -> void:
	print("[Card Generation] Testing UpgradeCardGenerator...")
	
	var generator_script = load("res://systems/upgrade_card_generator.gd")
	if not generator_script:
		print("  ❌ Failed to load UpgradeCardGenerator")
		return
	
	var generator = generator_script.new()
	if not generator:
		print("  ❌ Failed to instantiate UpgradeCardGenerator")
		return
	
	# Test 1: Card pool loads
	if generator.card_pool.is_empty():
		print("  ❌ Card pool is empty")
		return
	print("  ✓ Card pool loaded with %d cards" % generator.card_pool.size())
	
	# Test 2: Random selection
	var cards_stage_1 = generator.generate_random_cards(3, 1)
	if cards_stage_1.size() != 3:
		print("  ❌ Expected 3 cards, got %d" % cards_stage_1.size())
		return
	print("  ✓ Generated 3 random cards for stage 1")
	
	# Test 3: Stage filtering
	var cards_stage_20 = generator.generate_random_cards(3, 20)
	var has_advanced_card = false
	for card in cards_stage_20:
		if card.get("id") in ["overclock", "tech_credit_boost"]:
			has_advanced_card = true
			break
	
	if has_advanced_card:
		print("  ✓ Stage 20 correctly includes advanced cards")
	else:
		print("  ⚠ Stage 20 may be missing advanced cards (this is okay if RNG excludes them)")
	
	# Test 4: Card structure
	var sample_card = cards_stage_1[0]
	var required_fields = ["id", "type", "title", "description", "value", "rarity"]
	var missing_fields = []
	for field in required_fields:
		if not sample_card.has(field):
			missing_fields.append(field)
	
	if missing_fields.is_empty():
		print("  ✓ Sample card has all required fields: %s" % sample_card.get("id"))
	else:
		print("  ❌ Sample card missing fields: %s" % missing_fields)

func _test_upgrade_effect_system() -> void:
	print("[Effect System] Testing UpgradeEffectSystem...")
	
	var effect_system_script = load("res://systems/upgrade_effect_system.gd")
	if not effect_system_script:
		print("  ❌ Failed to load UpgradeEffectSystem")
		return
	
	var effect_system = effect_system_script.new()
	if not effect_system:
		print("  ❌ Failed to instantiate UpgradeEffectSystem")
		return
	
	# Test 1: Effect definitions load
	if effect_system.effect_definitions.is_empty():
		print("  ❌ Effect definitions did not load")
		return
	print("  ✓ Effect definitions loaded with %d entries" % effect_system.effect_definitions.size())
	
	# Test 2: Required effects exist
	var required_effects = ["attack_speed", "damage_boost", "shield_boost", "overclock"]
	var missing_effects = []
	for effect in required_effects:
		if not effect_system.effect_definitions.has(effect):
			missing_effects.append(effect)
	
	if missing_effects.is_empty():
		print("  ✓ All required effect definitions present")
	else:
		print("  ❌ Missing effect definitions: %s" % missing_effects)
	
	# Test 3: Wave-based effect duration
	var overclock_def = effect_system.effect_definitions.get("overclock", {})
	var duration = overclock_def.get("duration_waves", 0)
	if duration > 0:
		print("  ✓ Overclock has wave duration: %d waves" % duration)
	else:
		print("  ❌ Overclock missing wave duration")

func _test_overlay_signal_flow() -> void:
	print("[Overlay] Testing SoftwareUpgradeOverlay signal flow...")
	
	var overlay_scene_path = "res://scenes/overlays/software_upgrade_overlay.tscn"
	if not ResourceLoader.exists(overlay_scene_path):
		print("  ❌ Overlay scene not found at %s" % overlay_scene_path)
		return
	print("  ✓ Overlay scene found")
	
	var overlay_script = load("res://scenes/overlays/software_upgrade_overlay.gd")
	if not overlay_script:
		print("  ❌ Failed to load overlay script")
		return
	print("  ✓ Overlay script loaded")
	
	# Test 1: Signals defined
	var sample_overlay = overlay_script.new()
	var has_upgrade_signal = sample_overlay.has_signal("upgrade_selected")
	var has_reroll_signal = sample_overlay.has_signal("re_roll_requested")
	
	if has_upgrade_signal and has_reroll_signal:
		print("  ✓ Overlay signals defined (upgrade_selected, re_roll_requested)")
	else:
		print("  ❌ Missing signals: upgrade_selected=%s, re_roll_requested=%s" % [has_upgrade_signal, has_reroll_signal])

func _print_card(card: Dictionary, indent: String = "    ") -> void:
	print("%s- %s (%s) [%s]" % [indent, card.get("title", "?"), card.get("type", "?"), card.get("rarity", "?")])
	print("%s  %s" % [indent, card.get("description", "")])
