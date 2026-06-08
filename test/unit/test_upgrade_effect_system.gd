extends Node

# Test UpgradeEffectSystem during development

func _ready() -> void:
	print("=== Testing UpgradeEffectSystem ===")
	var effect_system = preload("res://systems/upgrade_effect_system.gd").new()
	add_child(effect_system)

	if effect_system.effect_definitions.empty():
		print("❌ UpgradeEffectSystem failed to load effect definitions")
	else:
		print("✓ UpgradeEffectSystem loaded %d effect definitions" % effect_system.effect_definitions.size())
		if effect_system.effect_definitions.has("overclock"):
			print("✓ Overclock effect definition available")
		else:
			print("❌ Overclock effect definition missing")

	print("=== UpgradeEffectSystem Test Complete ===")
