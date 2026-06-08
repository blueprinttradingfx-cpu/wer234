extends Node
class_name UpgradeCardGenerator

const CARD_POOL_PATH: String = "res://data/upgrade_card_pool.json"

var card_pool: Array = []
var rarity_weights: Dictionary = {
	"common": 60,
	"rare": 30,
	"legendary": 10
}
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _init() -> void:
	_rng.randomize()
	_load_card_pool()

func generate_random_cards(count: int = 3, stage_id: int = 1) -> Array:
	var pool: Array = _get_stage_filtered_pool(stage_id)
	if pool.is_empty():
		return []

	var selected: Array = []
	var available: Array = pool.duplicate(true)

	while selected.size() < count and not available.is_empty():
		var chosen_index: int = _pick_weighted_index(available)
		if chosen_index < 0 or chosen_index >= available.size():
			break

		selected.append(available[chosen_index].duplicate(true))
		available.remove_at(chosen_index)

	return selected

func get_all_cards(stage_id: int = 1) -> Array:
	return _get_stage_filtered_pool(stage_id)

func _load_card_pool() -> void:
	if not FileAccess.file_exists(CARD_POOL_PATH):
		push_warning("[UpgradeCardGenerator] Missing card pool: %s" % CARD_POOL_PATH)
		card_pool = _build_default_card_pool()
		return

	var file := FileAccess.open(CARD_POOL_PATH, FileAccess.READ)
	if not file:
		push_warning("[UpgradeCardGenerator] Failed to open card pool: %s" % CARD_POOL_PATH)
		card_pool = _build_default_card_pool()
		return

	var content: String = file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(content)
	if not parsed is Dictionary or not parsed.has("cards"):
		push_warning("[UpgradeCardGenerator] Invalid card pool JSON; using fallback pool.")
		card_pool = _build_default_card_pool()
		return

	rarity_weights = parsed.get("rarity_weights", rarity_weights)
	card_pool = []
	for card in parsed["cards"]:
		if card is Dictionary:
			card_pool.append(card)

	if card_pool.is_empty():
		push_warning("[UpgradeCardGenerator] Card pool loaded empty; using fallback pool.")
		card_pool = _build_default_card_pool()

func _get_stage_filtered_pool(stage_id: int) -> Array:
	var filtered: Array = []
	for card in card_pool:
		if not card is Dictionary:
			continue

		var min_stage: int = int(card.get("min_stage", 1))
		var max_stage: int = int(card.get("max_stage", 9999))
		if stage_id >= min_stage and stage_id <= max_stage:
			filtered.append(card)

	return filtered

func _pick_weighted_index(pool: Array) -> int:
	var total_weight: float = 0.0
	for card in pool:
		total_weight += _weight_for_card(card)

	if total_weight <= 0.0:
		return _rng.randi_range(0, pool.size() - 1)

	var roll: float = _rng.randf_range(0.0, total_weight)
	var running: float = 0.0
	for i in range(pool.size()):
		running += _weight_for_card(pool[i])
		if roll <= running:
			return i

	return pool.size() - 1

func _weight_for_card(card: Dictionary) -> float:
	var rarity: String = str(card.get("rarity", "common"))
	var rarity_weight: float = float(rarity_weights.get(rarity, 0))
	var card_weight: float = float(card.get("weight", 1))
	return max(0.0, rarity_weight * card_weight)

func _build_default_card_pool() -> Array:
	return [
		{
			"id": "attack_speed",
			"type": "attack_speed",
			"title": "⚡ Attack Speed",
			"description": "+12% Attack Speed",
			"value": 0.12,
			"rarity": "common",
			"min_stage": 1,
			"weight": 1
		},
		{
			"id": "damage_boost",
			"type": "damage_boost",
			"title": "💥 Damage Boost",
			"description": "+10% Damage",
			"value": 0.10,
			"rarity": "common",
			"min_stage": 1,
			"weight": 1
		},
		{
			"id": "bullet_velocity",
			"type": "bullet_velocity",
			"title": "💨 Bullet Velocity",
			"description": "+10% Bullet Velocity",
			"value": 0.10,
			"rarity": "common",
			"min_stage": 1,
			"weight": 1
		},
		{
			"id": "shield_boost",
			"type": "shield_boost",
			"title": "🛡️ Shield Boost",
			"description": "+1 Shield",
			"value": 1.0,
			"rarity": "common",
			"min_stage": 1,
			"weight": 1
		},
		{
			"id": "missile_cooldown",
			"type": "missile_cooldown",
			"title": "🔋 Missile Cooldown",
			"description": "-0.5s Missile Cooldown",
			"value": -0.5,
			"rarity": "common",
			"min_stage": 1,
			"weight": 1
		},
		{
			"id": "multi_shot",
			"type": "multi_shot",
			"title": "🔫 Multi-Shot",
			"description": "+1 Multi-Shot Projectile",
			"value": 1.0,
			"rarity": "rare",
			"min_stage": 5,
			"weight": 0.8
		},
		{
			"id": "piercing",
			"type": "piercing",
			"title": "🥷 Piercing Rounds",
			"description": "+1 Pierce Level",
			"value": 1.0,
			"rarity": "rare",
			"min_stage": 5,
			"weight": 0.8
		},
		{
			"id": "payload_expansion",
			"type": "payload_expansion",
			"title": "📦 Payload Expansion",
			"description": "+15% Payload Capacity",
			"value": 0.15,
			"rarity": "rare",
			"min_stage": 10,
			"weight": 0.7
		},
		{
			"id": "overclock",
			"type": "overclock",
			"title": "⚡ Overclock",
			"description": "+25% DPS for 5 waves",
			"value": 1.25,
			"rarity": "legendary",
			"min_stage": 15,
			"weight": 0.5
		},
		{
			"id": "tech_credit_boost",
			"type": "tech_credit_boost",
			"title": "💎 Credit Matrix",
			"description": "+20% Tech Credit gain",
			"value": 0.20,
			"rarity": "legendary",
			"min_stage": 20,
			"weight": 0.4
		}
	]