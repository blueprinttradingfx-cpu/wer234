extends Node

# Test EconomyManager functionality (EPIC-09 Currency System)

func _ready() -> void:
	print("=== Testing EconomyManager ===")
	_test_autoload_exists()
	_test_required_methods()
	_test_tech_credits()
	_test_currency_integration()
	print("\n=== EconomyManager Tests Complete ===")

func _test_autoload_exists() -> void:
	print("\n--- Testing Autoload Existence ---")
	var economy = get_node_or_null("/root/EconomyManager")
	if economy:
		print("✓ EconomyManager autoload exists")
	else:
		print("❌ EconomyManager autoload not found")

func _test_required_methods() -> void:
	print("\n--- Testing Required Methods ---")
	var economy = get_node_or_null("/root/EconomyManager")
	if not economy:
		print("❌ EconomyManager not available for testing")
		return
	
	var required_methods = [
		"add_tech_credits",
		"spend_tech_credits",
		"get_tech_credits",
		"can_afford"
	]
	
	for method_name in required_methods:
		if economy.has_method(method_name):
			print("✓ Method exists: %s" % method_name)
		else:
			print("❌ Method missing: %s" % method_name)

func _test_tech_credits() -> void:
	print("\n--- Testing Tech Credits ---")
	var economy = get_node_or_null("/root/EconomyManager")
	if not economy:
		return
	
	# Test getting tech credits
	var credits = economy.get_tech_credits()
	print("✓ get_tech_credits executed (returned: %d)" % credits)
	
	# Test adding tech credits
	economy.add_tech_credits(100)
	var new_credits = economy.get_tech_credits()
	if new_credits >= credits + 100:
		print("✓ add_tech_credits works")
	else:
		print("❌ add_tech_credits failed")

func _test_currency_integration() -> void:
	print("\n--- Testing Currency Integration ---")
	var economy = get_node_or_null("/root/EconomyManager")
	if not economy:
		return
	
	# Test can_afford
	var can_afford = economy.can_afford(50)
	print("✓ can_afford executed (returned: %s)" % can_afford)
	
	# Test spend_tech_credits
	var initial_credits = economy.get_tech_credits()
	if initial_credits >= 50:
		economy.spend_tech_credits(50)
		var final_credits = economy.get_tech_credits()
		if final_credits < initial_credits:
			print("✓ spend_tech_credits works")
		else:
			print("❌ spend_tech_credits failed")
