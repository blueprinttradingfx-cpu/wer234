extends Node
class_name UpgradeEffectSystem

const EFFECTS_PATH: String = "res://data/upgrade_effects.json"

var effect_definitions: Dictionary = {}
var active_effects: Array = []

func _init() -> void:
	_load_effect_definitions()

func _load_effect_definitions() -> void:
	if not FileAccess.file_exists(EFFECTS_PATH):
		push_warning("[UpgradeEffectSystem] Missing effect definition file: %s" % EFFECTS_PATH)
		return

	var file = FileAccess.open(EFFECTS_PATH, FileAccess.READ)
	if not file:
		push_warning("[UpgradeEffectSystem] Failed to open effect definition file")
		return

	var content: String = file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(content)
	if parsed is Dictionary and parsed.has("effects"):
		effect_definitions = parsed["effects"]
	else:
		push_warning("[UpgradeEffectSystem] Invalid effect definition JSON")

func apply_upgrade(upgrade_type: String, value: float, context: Dictionary) -> void:
	if not effect_definitions.has(upgrade_type):
		push_warning("[UpgradeEffectSystem] Unknown upgrade type: %s" % upgrade_type)
		return

	var definition: Dictionary = effect_definitions[upgrade_type]
	var effect: Dictionary = {
		"type": upgrade_type,
		"value": value,
		"definition": definition,
		"context": context,
		"remaining_waves": int(definition.get("duration_waves", 0)),
		"multiplier": definition.get("multiplier", 1.0)
	}

	_activate_effect(effect)

	if effect["remaining_waves"] > 0:
		active_effects.append(effect)

func tick_wave() -> void:
	for effect in active_effects.duplicate():
		effect["remaining_waves"] -= 1
		if effect["remaining_waves"] <= 0:
			_deactivate_effect(effect)

func _activate_effect(effect: Dictionary) -> void:
	var effect_type: String = effect["type"]	
	var value: float = effect["value"]
	var ctx: Dictionary = effect["context"]
	var weapon_system = ctx.get("weapon_system")
	var mecha_instance = ctx.get("mecha_instance")
	var battle_manager = ctx.get("battle_manager")

	match effect_type:
		"attack_speed":
			if weapon_system:
				weapon_system.set_attack_speed(weapon_system.attack_speed * (1.0 + value))
				print("[UpgradeEffectSystem] Applied attack speed boost: +%.0f%%" % (value * 100.0))
		"damage_boost":
			if weapon_system:
				weapon_system.set_base_damage(weapon_system.base_damage * (1.0 + value))
				print("[UpgradeEffectSystem] Applied damage boost: +%.0f%%" % (value * 100.0))
		"bullet_velocity":
			print("[UpgradeEffectSystem] Bullet velocity upgrade applied, but no runtime implementation is available yet.")
		"shield_boost":
			if battle_manager:
				battle_manager.add_shield_points(int(value))
		"missile_cooldown":
			if mecha_instance:
				mecha_instance.missile_battery_cooldown = max(0.5, mecha_instance.missile_battery_cooldown + value)
				if mecha_instance.has_node("missile_cooldown_timer"):
					var timer = mecha_instance.get_node("missile_cooldown_timer")
					if timer is Timer:
						timer.wait_time = mecha_instance.missile_battery_cooldown
				print("[UpgradeEffectSystem] Applied missile cooldown adjustment: %.2fs" % value)
		"multi_shot":
			if weapon_system:
				weapon_system.set_multi_shot_level(min(2, weapon_system.multi_shot_level + int(value)))
				print("[UpgradeEffectSystem] Increased multi-shot level")
		"piercing":
			if weapon_system:
				weapon_system.set_piercing_level(min(2, weapon_system.piercing_level + int(value)))
				print("[UpgradeEffectSystem] Increased piercing level")
		"payload_expansion":
			if mecha_instance:
				mecha_instance.missile_max_targets = int(round(mecha_instance.missile_max_targets * (1.0 + value)))
				print("[UpgradeEffectSystem] Increased missile payload capacity")
		"overclock":
			if weapon_system:
				effect["multiplier"] = value
				weapon_system.set_attack_speed(weapon_system.attack_speed * value)
				weapon_system.set_base_damage(weapon_system.base_damage * value)
				print("[UpgradeEffectSystem] Applied overclock x%.2f for %d waves" % [value, effect["remaining_waves"]])
		"tech_credit_boost":
			if battle_manager:
				battle_manager.apply_credit_gain_multiplier(1.0 + value)
				print("[UpgradeEffectSystem] Applied tech credit gain boost: +%.0f%%" % (value * 100.0))
		_:
			push_warning("[UpgradeEffectSystem] No apply logic for effect type: %s" % effect_type)

func _deactivate_effect(effect: Dictionary) -> void:
	var effect_type: String = effect["type"]
	var ctx: Dictionary = effect["context"]
	var weapon_system = ctx.get("weapon_system")
	var multiplier: float = effect.get("multiplier", 1.0)

	if effect_type == "overclock" and weapon_system:
		if multiplier != 0:
			weapon_system.set_attack_speed(weapon_system.attack_speed / multiplier)
			weapon_system.set_base_damage(weapon_system.base_damage / multiplier)
			print("[UpgradeEffectSystem] Overclock expired")

	active_effects.erase(effect)
