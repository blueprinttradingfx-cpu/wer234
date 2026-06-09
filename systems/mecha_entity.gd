extends Node2D
class_name MechaEntity

# --- SIGNALS ---
signal missile_fired(target: Node2D, damage: float)
signal stats_updated()

# --- VARIABLES (Values populated from JSON via ProgressionManager) ---
var base_attack_damage: float = 0.0
var base_attack_speed: float = 0.0 # attacks per second
var missile_damage: float = 0.0
var missile_max_targets: int = 0
var missile_cooldown: float = 0.0 # seconds
var _emp_level: int = 0

var current_mecha_id: String = "mecha_unit_alpha_base"
var progression_manager = null
var weapon_system = null

# --- HOMING MISSILE SKILL ---
var missile_timer: Timer
var missile_cooldown_remaining: float = 0.0

func _ready() -> void:
	progression_manager = get_node_or_null("/root/ProgressionManager")
	
	# Setup missile cooldown timer (with safe default)
	missile_timer = Timer.new()
	missile_timer.wait_time = 10.0  # Safe default until stats are loaded
	missile_timer.timeout.connect(Callable(self, "_on_missile_cooldown_complete"))
	add_child(missile_timer)
	
	_load_mecha_stats()
	_center_position()

func _center_position() -> void:
	var viewport = get_viewport()
	var viewport_size = viewport.get_visible_rect().size
	global_position = Vector2(viewport_size.x / 2.0, viewport_size.y / 2.0)

func _load_mecha_stats() -> void:
	if progression_manager:
		var mecha_stats = progression_manager.get_active_mecha_stats()
		if not mecha_stats.is_empty():
			current_mecha_id = mecha_stats.get("mecha_id", "mecha_unit_alpha_base")
			var base_stats = mecha_stats.get("base_stats", {})
			base_attack_damage = base_stats.get("attack_damage", 10.0)
			base_attack_speed = base_stats.get("attack_speed", 1.0)
			
			var skill = mecha_stats.get("skill", {})
			missile_damage = skill.get("total_damage", 50.0)
			missile_cooldown = skill.get("cooldown", 10.0)
			missile_max_targets = int(missile_damage / missile_damage) # Calculate rocket count
	
	# Apply upgrade modifiers
	_apply_upgrade_modifiers()
	
	# Update weapon system if connected
	if weapon_system:
		weapon_system.set_base_damage(base_attack_damage)
		weapon_system.set_attack_speed(base_attack_speed)
	
	stats_updated.emit()

func _apply_upgrade_modifiers() -> void:
	# Chassis Calibrator: attack speed scales from base to 8.0
	var chassis_level = SaveSystem.get_upgrade_level("ballistic_core", "chassis_calibrator_level")
	if chassis_level > 0:
		base_attack_speed = lerp(base_attack_speed, 8.0, float(chassis_level) / 10.0)
	
	# Processor Overclock: missile cooldown 10.0 → 4.0
	var overclock_level = SaveSystem.get_upgrade_level("energy_matrix", "processor_overclock_level")
	if overclock_level > 0:
		missile_cooldown = lerp(10.0, 4.0, float(overclock_level) / 10.0)
	
	# Payload Expansion: rockets 5 → 15
	var payload_level = SaveSystem.get_upgrade_level("energy_matrix", "payload_expansion_level")
	if payload_level > 0:
		missile_max_targets = lerp(5, 15, float(payload_level) / 10.0)
	
	# Piercing Rail Barrel: piercing level 0 → 2
	var piercing_level = SaveSystem.get_upgrade_level("ballistic_core", "piercing_barrel_level")
	if weapon_system and weapon_system.has_method("set_piercing_level"):
		weapon_system.set_piercing_level(piercing_level)
	
	# EMP Grid Capacitor: emp level 0 → 5
	var emp_level = SaveSystem.get_upgrade_level("energy_matrix", "emp_grid_level")
	_emp_level = emp_level
	
	# Update missile timer
	if missile_timer:
		missile_timer.wait_time = missile_cooldown

func start_missile_cooldown() -> void:
	missile_cooldown_remaining = missile_cooldown
	missile_timer.start()

func _on_missile_cooldown_complete() -> void:
	_fire_homing_missiles()

func _fire_homing_missiles() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return
	
	# Sort enemies by proximity
	enemies.sort_custom(Callable(self, "_compare_enemy_distance"))
	
	# Fire missiles at up to max_targets
	var targets_to_fire = min(enemies.size(), missile_max_targets)
	var emp_targets = []  # Track targets for EMP effect
	
	for i in range(targets_to_fire):
		var target = enemies[i]
		if is_instance_valid(target):
			# Apply damage immediately (100% hit rate)
			if target.has_method("take_damage"):
				target.take_damage(missile_damage)
			
			emp_targets.append(target)
			missile_fired.emit(target, missile_damage)
	
	# Apply EMP crowd control if enabled
	if _emp_level > 0 and not emp_targets.is_empty():
		_apply_emp_effect(emp_targets)
	
	# Restart cooldown
	start_missile_cooldown()

func _apply_emp_effect(targets: Array) -> void:
	# EMP radius increases with level
	var emp_radius = 100.0 + (_emp_level * 50.0)
	var emp_stun_duration = 1.0 + (_emp_level * 0.5)  # Seconds
	
	var all_enemies = get_tree().get_nodes_in_group("enemies")
	
	for target in targets:
		if not is_instance_valid(target):
			continue
		
		# Find enemies within EMP radius of each target
		for enemy in all_enemies:
			if not is_instance_valid(enemy):
				continue
			
			if enemy == target:
				continue
			
			var distance = target.global_position.distance_to(enemy.global_position)
			if distance <= emp_radius:
				# Apply stun effect if enemy has the method
				if enemy.has_method("apply_stun"):
					enemy.apply_stun(emp_stun_duration)
				elif enemy.has_method("set_speed_modifier"):
					# Fallback: slow down enemy instead
					enemy.set_speed_modifier(0.2)  # 20% speed
					# Create a timer to restore speed
					var restore_timer = get_tree().create_timer(emp_stun_duration)
					restore_timer.timeout.connect(func(): 
						if is_instance_valid(enemy) and enemy.has_method("set_speed_modifier"):
							enemy.set_speed_modifier(1.0)
					)

func set_weapon_system(ws: WeaponSystem) -> void:
	weapon_system = ws
	if weapon_system:
		weapon_system.set_base_damage(base_attack_damage)
		weapon_system.set_attack_speed(base_attack_speed)

func _process(delta: float) -> void:
	# Update cooldown display
	if missile_timer and not missile_timer.is_stopped():
		missile_cooldown_remaining = missile_timer.time_left

func get_missile_cooldown_percent() -> float:
	if missile_cooldown <= 0:
		return 1.0
	return 1.0 - (missile_cooldown_remaining / missile_cooldown)

## Comparator for sorting enemies by distance from this node
func _compare_enemy_distance(a: Node2D, b: Node2D) -> int:
	var da = global_position.distance_to(a.global_position)
	var db = global_position.distance_to(b.global_position)
	if da < db:
		return -1
	elif da > db:
		return 1
	return 0
