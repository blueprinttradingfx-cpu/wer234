extends Node2D
class_name WeaponSystem

# --- SIGNALS ---
signal enemy_shot_fired(projectile_data: Dictionary)

# --- CONSTANTS ---
const BASE_ENEMY_HP := 10.0

# --- CONFIGURATION REFERENCES (Injected by BattleManager) ---
var base_damage: float = 0.0 # Populated from JSON via MechaEntity
var attack_speed: float = 0.0 # Populated from JSON via MechaEntity

# --- MULTI-SHOT UPGRADE STATE ---
# Level 0: Pure Single Shot
# Level 1: [Single] -> [Single] -> [Dual]
# Level 2: [Single] -> [Dual] -> [Triple]
var multi_shot_level: int = 0 

# --- TACTICIAN PROTOCOL UPGRADE STATE ---
# Piercing: Bullets can hit multiple enemies in line
# EMP: Missiles stun nearby enemies
var piercing_level: int = 0
var emp_level: int = 0 

# --- INTERNAL CORE AUTOMATION STATE ---
var shot_sequence_index: int = 0
@onready var fire_timer: Timer = $FireTimer

func _ready() -> void:
	setup_fire_timer()

func setup_fire_timer() -> void:
	if fire_timer:
		fire_timer.timeout.connect(Callable(self, "_on_fire_timer_timeout"))
		update_weapon_speed()
	else:
		push_error("[WeaponSystem] FireTimer not found")

## Call this whenever attack speed upgrades are purchased or applied
func update_weapon_speed() -> void:
	if fire_timer:
		if attack_speed > 0:
			fire_timer.wait_time = 1.0 / attack_speed
			fire_timer.start()
			print("[WeaponSystem] ✅ Timer STARTED | attack_speed=", attack_speed, " | interval=", fire_timer.wait_time, "s")
		else:
			fire_timer.stop()
			print("[WeaponSystem] ⚠ Timer STOPPED | attack_speed=", attack_speed)

func _on_fire_timer_timeout() -> void:
	var target_enemies = acquire_targets()
	if target_enemies.is_empty():
		return # Idle state: No enemies within screen boundaries
	
	#print("[WeaponSystem] FIRE | attack_speed=", attack_speed, " | fire_interval=", fire_timer.wait_time, "s | base_damage=", base_damage)
	execute_firing_sequence(target_enemies)

## Scans the screen context to return valid targets sorted by closest distance
func acquire_targets() -> Array[Node2D]:
	var targets: Array[Node2D] = []
	var live_enemies = get_tree().get_nodes_in_group("enemies")
	
	# Early exit if the screen board is completely clear
	if live_enemies.is_empty():
		return targets
	
	# Create (distance, enemy) pairs for robust sorting
	var distance_pairs: Array = []
	var my_pos = global_position
	
	for enemy in live_enemies:
		if is_instance_valid(enemy) and enemy is Node2D:
			var distance = my_pos.distance_to(enemy.global_position)
			distance_pairs.append([distance, enemy])
	
	if distance_pairs.is_empty():
		return targets
	
	# Sort by distance (first element of each pair)
	distance_pairs.sort_custom(func(a, b): return a[0] < b[0])
	
	# Extract sorted enemies
	for pair in distance_pairs:
		targets.append(pair[1])
	
	return targets

## Evaluates the strict sequential cadence rules based on Upgrade Level
func execute_firing_sequence(available_targets: Array[Node2D]) -> void:
	var bullet_count: int = 1 # Default Level 0 Baseline
	
	match multi_shot_level:
		1:
			# Sequence rhythm: Single (0) -> Single (1) -> Dual (2)
			if shot_sequence_index == 2:
				bullet_count = 2
			else:
				bullet_count = 1
			shot_sequence_index = (shot_sequence_index + 1) % 3
			
		2:
			# Sequence rhythm: Single (0) -> Dual (1) -> Triple (2)
			if shot_sequence_index == 1:
				bullet_count = 2
			elif shot_sequence_index == 2:
				bullet_count = 3
			else:
				bullet_count = 1
			shot_sequence_index = (shot_sequence_index + 1) % 3
			
		_:
			# Level 0 default behavior: Flat loop, no indexing calculation needed
			bullet_count = 1
			
	# Deploy the calculated bullet array into target entities
	deploy_projectiles(bullet_count, available_targets)

## Distributes shots across distinct targets to resolve local crowd density
func deploy_projectiles(count: int, targets: Array[Node2D]) -> void:
	if targets.is_empty():
		return
	
	# Primary targeting: all shots focus nearest enemy first
	# This ensures concentrated fire on closest threat
	var primary_target = targets[0]  # Always the nearest
	
	for i in range(count):
		# Cycle through targets only after primary is focused
		# i=0: always nearest | i=1+: next nearest (if multi-shot upgrade active)
		var target = primary_target if i == 0 else (targets[i] if i < targets.size() else primary_target)
		
		if is_instance_valid(target):
			# Emit tracking payload for visual projectile instancing
			enemy_shot_fired.emit({
				"target_node": target,
				"target_position": target.global_position,
				"damage": base_damage,
				"bullet_index": i,
				"piercing_level": piercing_level
			})

func _apply_damage_with_piercing(target: Node2D, damage: float) -> void:
	if target.has_method("take_damage"):
		target.take_damage(damage)
	
	# Piercing logic: if piercing_level > 0, damage enemies behind the target
	if piercing_level > 0:
		var pierce_count = piercing_level
		var enemies = get_tree().get_nodes_in_group("enemies")
		
		# Find enemies behind the target (further from center)
		var mycha_pos = global_position
		var target_dist = mycha_pos.distance_to(target.global_position)
		
		for enemy in enemies:
			if pierce_count <= 0:
				break
			
			if enemy == target:
				continue
			
			if not is_instance_valid(enemy):
				continue
			
			var enemy_dist = mycha_pos.distance_to(enemy.global_position)
			
			# Check if enemy is behind target (further away) and in roughly the same direction
			if enemy_dist > target_dist:
				var to_target = (target.global_position - mycha_pos).normalized()
				var to_enemy = (enemy.global_position - mycha_pos).normalized()
				var dot_product = to_target.dot(to_enemy)
				
				# If dot product > 0.7, enemies are in similar direction (within ~45 degrees)
				if dot_product > 0.7:
					if enemy.has_method("take_damage"):
						enemy.take_damage(damage * 0.5) # Piercing does reduced damage
					pierce_count -= 1

## Set multi-shot level from upgrades
func set_multi_shot_level(level: int) -> void:
	multi_shot_level = clamp(level, 0, 2)
	shot_sequence_index = 0 # Reset sequence on level change

## Update base damage from upgrades
func set_base_damage(damage: float) -> void:
	base_damage = damage

## Update attack speed from upgrades
func set_attack_speed(speed: float) -> void:
	attack_speed = speed
	update_weapon_speed()

## Set piercing level from upgrades
func set_piercing_level(level: int) -> void:
	piercing_level = clamp(level, 0, 2)

## Set EMP level from upgrades
func set_emp_level(level: int) -> void:
	emp_level = clamp(level, 0, 5)
