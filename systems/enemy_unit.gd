extends CharacterBody2D
class_name EnemyUnit

# --- SIGNALS ---
signal destroyed()

# --- VARIABLES ---
@export var max_hp: float = 10.0
var current_hp: float = 10.0

@export var base_speed: float = 35.0  # Reduced by 30% (was 50.0) to allow bullets to catch up
@export var speed_modifier: float = 1.0
var is_boss: bool = false
var archetype: String = "normal"

# Square path movement (fallback if PathFollow2D not used)
var path_center: Vector2 = Vector2(540, 960)
var square_size: float = 400.0
var path_index: int = 0
var use_manual_square: bool = false

# Shield mechanics (for Shielded Packets archetype)
var max_shield_hp: float = 0.0
var current_shield_hp: float = 0.0
var shield_damage_reduction: float = 0.5  # 50% damage reduction while shield active

# Splitting mechanics (for Splitting Malware archetype)
var can_split: bool = false
var split_count: int = 2  # Number of children to spawn
var split_depth: int = 0  # Current split depth
var max_split_depth: int = 2  # Maximum split depth to prevent infinite splitting
var child_hp_multiplier: float = 0.5  # Children have 50% of parent HP

# EMP mechanics (for EMP Jammer archetype)
var has_emp: bool = false
var emp_radius: float = 150.0
var emp_duration: float = 2.0  # Seconds
var emp_on_death: bool = true  # Trigger EMP on death

# Re-routing mechanics (for Re-routing Logic archetype)
var can_re_route: bool = false
var re_route_interval: float = 3.0  # Seconds between path changes
var re_route_timer: float = 0.0

# Regeneration mechanics (for Regenerative Stream archetype)
var can_regen: bool = false
var regen_rate: float = 1.0  # HP per second
var regen_timer: float = 0.0
var regen_pause_duration: float = 2.0  # Pause regeneration after taking damage
var regen_pause_timer: float = 0.0

# Swarm Carrier mechanics (for Swarm Carrier archetype)
var is_carrier: bool = false
var payload_capacity: int = 5  # Max number of payload enemies to spawn
var payload_spawned: int = 0
var spawn_interval: float = 2.0  # Seconds between spawns
var spawn_timer: float = 0.0
var payload_hp_multiplier: float = 0.3  # Payload enemies have 30% of carrier HP

# Phantom/Cloak mechanics (for Phantom Grid archetype)
var can_cloak: bool = false
var is_cloaked: bool = false
var cloak_duration: float = 3.0  # Seconds cloaked
var cloak_cooldown: float = 5.0  # Seconds between cloaks
var cloak_timer: float = 0.0
var cloak_cooldown_timer: float = 0.0

var battle_manager = null
var target_position: Vector2 = Vector2.ZERO

# --- Path Tracking State Parameters ---
var follower_node: PathFollow2D = null
var is_on_path_track: bool = false
var entry_target_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	add_to_group("enemies")
	current_hp = max_hp
	battle_manager = get_node_or_null("/root/BattleManager")
	
	# Set initial path index for manual square movement
	var corners = [
		Vector2(134, 252),   # Top-Left
		Vector2(965, 254),   # Top-Right
		Vector2(962, 1480),  # Bottom-Right
		Vector2(136, 1478)   # Bottom-Left
	]
	var closest_index = 0
	var closest_dist = INF
	for i in range(4):
		var dist = global_position.distance_to(corners[i])
		if dist < closest_dist:
			closest_dist = dist
			closest_index = i
	path_index = closest_index

func initialize_path_movement(wrapper: PathFollow2D) -> void:
	follower_node = wrapper
	# Snap directly to Point 0 (top-left, 134,252) and start following immediately
	follower_node.progress = 0.0
	is_on_path_track = true
	position = Vector2.ZERO


func _physics_process(delta: float) -> void:
	_handle_re_routing(delta)
	_handle_regeneration(delta)
	_handle_carrier_spawn(delta)
	_handle_cloak(delta)

	# Handle movement based on whether using PathFollow2D or manual square
	if follower_node and not use_manual_square:
		if not is_on_path_track:
			# PHASE 1: Walk from the Top-Right spawn point down to the Path Entrance
			var speed = base_speed * speed_modifier 
			var direction = (entry_target_position - global_position).normalized()
			velocity = direction * speed 
			move_and_slide() 
			
			# Upon reaching the track, snap internal tracking coordinates over to Path Follower manipulation
			if global_position.distance_to(entry_target_position) < 15.0:
				is_on_path_track = true
				# Snap enemy local position to center inside the PathFollow2D container
				position = Vector2.ZERO 
		else:
			# PHASE 2: Lock onto track and circle using PathFollow2D progress offset properties
			var speed = base_speed * speed_modifier 
			follower_node.progress += speed * delta
	else:
		# Manual square corner movement
		_move_toward_target(delta)


func set_speed_modifier(modifier: float) -> void:
	speed_modifier = modifier


func set_target_position(pos: Vector2) -> void:
	target_position = pos

func _move_toward_target(delta: float) -> void:
	# Manual square corner movement
	var speed = base_speed * speed_modifier
	
	var corners = [
		Vector2(134, 252),   # Top-Left
		Vector2(965, 254),   # Top-Right
		Vector2(962, 1480),  # Bottom-Right
		Vector2(136, 1478)   # Bottom-Left
	]
	
	var target_corner = corners[path_index]
	var direction = (target_corner - global_position).normalized()
	velocity = direction * speed
	
	move_and_slide()
	
	if global_position.distance_to(target_corner) < 10.0:
		path_index = (path_index + 1) % 4

func _handle_re_routing(delta: float) -> void:
	if not can_re_route:
		return
	
	re_route_timer -= delta
	if re_route_timer <= 0:
		_change_target_position()
		re_route_timer = re_route_interval


func _change_target_position() -> void:
	var viewport = get_viewport()
	if not viewport:
		return
	
	var viewport_size = viewport.get_visible_rect().size
	
	# Random position within viewport bounds
	var new_x = randf_range(50, viewport_size.x - 50)
	var new_y = randf_range(50, viewport_size.y - 50)
	target_position = Vector2(new_x, new_y)


func _handle_regeneration(delta: float) -> void:
	if not can_regen:
		return
	
	# Handle regeneration pause timer
	if regen_pause_timer > 0:
		regen_pause_timer -= delta
		return
	
	# Regenerate HP
	regen_timer += delta
	if regen_timer >= 1.0:  # Regenerate every second
		var heal_amount = regen_rate
		current_hp = min(current_hp + heal_amount, max_hp)
		regen_timer = 0.0


func _handle_carrier_spawn(delta: float) -> void:
	if not is_carrier:
		return
	
	# Check if we've spawned all payload
	if payload_spawned >= payload_capacity:
		return
	
	spawn_timer -= delta
	if spawn_timer <= 0:
		_spawn_payload_enemy()
		spawn_timer = spawn_interval


func _handle_cloak(delta: float) -> void:
	if not can_cloak:
		return
	
	# Handle cooldown
	if cloak_cooldown_timer > 0:
		cloak_cooldown_timer -= delta
		return
	
	# Handle active cloak
	if is_cloaked:
		cloak_timer -= delta
		if cloak_timer <= 0:
			_uncloak()
			cloak_cooldown_timer = cloak_cooldown
	else:
		# Auto-cloak when cooldown is ready
		_cloak()


func _cloak() -> void:
	is_cloaked = true
	cloak_timer = cloak_duration
	modulate = Color(1, 1, 1, 0.3)  # Fade to 30% opacity


func _uncloak() -> void:
	is_cloaked = false
	modulate = Color(1, 1, 1, 1.0)  # Restore full opacity


func is_targetable() -> bool:
	# Cloaked enemies are not targetable
	return not is_cloaked


func _spawn_payload_enemy() -> void:
	var enemy_scene = load("res://systems/enemy_unit.tscn")
	if not enemy_scene:
		push_error("[EnemyUnit] Failed to load enemy_unit.tscn for carrier payload")
		return
	
	var payload = enemy_scene.instantiate()
	
	# Set payload HP based on multiplier
	payload.max_hp = max_hp * payload_hp_multiplier
	payload.current_hp = payload.max_hp
	
	# Spawn at carrier position with slight offset
	var offset = Vector2(randf_range(-30, 30), randf_range(-30, 30))
	payload.global_position = global_position + offset
	
	# Add to scene tree
	get_tree().current_scene.add_child(payload)
	
	# Connect to destroyed signal for proper cleanup
	payload.destroyed.connect(_on_child_destroyed)
	
	payload_spawned += 1


func take_damage(amount: float) -> void:
	# Pause regeneration when taking damage
	if can_regen:
		regen_pause_timer = regen_pause_duration

	# Shield mechanics: absorb damage first, then apply reduction
	var actual_damage = amount

	if current_shield_hp > 0:
		# Shield absorbs damage first
		if current_shield_hp >= amount:
			current_shield_hp -= amount
			actual_damage = 0
		else:
			var overflow = amount - current_shield_hp
			current_shield_hp = 0
			actual_damage = overflow * shield_damage_reduction  # Apply reduction after shield breaks
	else:
		# No shield, apply full damage
		actual_damage = amount

	current_hp -= actual_damage
	if current_hp <= 0:
		execute_destruction()


func enable_shield(shield_hp: float, damage_reduction: float = 0.5) -> void:
	max_shield_hp = shield_hp
	current_shield_hp = shield_hp
	shield_damage_reduction = damage_reduction


func enable_splitting(count: int = 2, depth: int = 0, max_depth: int = 2, hp_mult: float = 0.5) -> void:
	can_split = true
	split_count = count
	split_depth = depth
	max_split_depth = max_depth
	child_hp_multiplier = hp_mult


func enable_emp(radius: float = 150.0, duration: float = 2.0, on_death: bool = true) -> void:
	has_emp = true
	emp_radius = radius
	emp_duration = duration
	emp_on_death = on_death


func enable_re_routing(interval: float = 3.0) -> void:
	can_re_route = true
	re_route_interval = interval
	re_route_timer = interval  # Start with full interval


func enable_regen(rate: float = 1.0, pause_duration: float = 2.0) -> void:
	can_regen = true
	regen_rate = rate
	regen_pause_duration = pause_duration


func enable_carrier(capacity: int = 5, interval: float = 2.0, hp_mult: float = 0.3) -> void:
	is_carrier = true
	payload_capacity = capacity
	spawn_interval = interval
	payload_hp_multiplier = hp_mult
	spawn_timer = interval  # Start with full interval


func enable_cloak(duration: float = 3.0, cooldown: float = 5.0) -> void:
	can_cloak = true
	cloak_duration = duration
	cloak_cooldown = cooldown
	cloak_cooldown_timer = 0.0  # Start ready to cloak


func execute_destruction() -> void:
	# Handle splitting before destruction
	if can_split and split_depth < max_split_depth:
		_spawn_split_children()
	
	# Handle EMP pulse before destruction
	if has_emp and emp_on_death:
		_trigger_emp_pulse()
	
	# Handshake validation to prevent dual-frame reporting errors
	remove_from_group("enemies")
	
	if battle_manager and battle_manager.has_method("register_enemy_destruction"):
		battle_manager.register_enemy_destruction()
	
	destroyed.emit()
	
	# Clean up the PathFollow2D wrapper if it exists to preserve memory
	if follower_node and is_instance_valid(follower_node):
		follower_node.queue_free()
	else:
		queue_free()


func _spawn_split_children() -> void:
	var enemy_scene = load("res://systems/enemy_unit.tscn")
	if not enemy_scene:
		push_error("[EnemyUnit] Failed to load enemy_unit.tscn for splitting")
		return
	
	for i in range(split_count):
		var child = enemy_scene.instantiate()
		
		# Set child HP based on multiplier
		child.max_hp = max_hp * child_hp_multiplier
		child.current_hp = child.max_hp
		
		# Enable splitting for children with increased depth
		if split_depth + 1 < max_split_depth:
			child.enable_splitting(split_count, split_depth + 1, max_split_depth, child_hp_multiplier)
		
		# Spawn at parent position with slight offset
		var offset = Vector2(randf_range(-20, 20), randf_range(-20, 20))
		child.global_position = global_position + offset
		
		# Add to scene tree
		get_tree().current_scene.add_child(child)
		
		# Connect to destroyed signal for proper cleanup
		child.destroyed.connect(_on_child_destroyed)


func _on_child_destroyed() -> void:
	if battle_manager and battle_manager.has_method("register_enemy_destruction"):
		battle_manager.register_enemy_destruction()


func _trigger_emp_pulse() -> void:
	var all_enemies = get_tree().get_nodes_in_group("enemies")
	
	for enemy in all_enemies:
		if not is_instance_valid(enemy):
			continue
		
		if enemy == self:
			continue
		
		var distance = global_position.distance_to(enemy.global_position)
		if distance <= emp_radius:
			# Apply stun effect if enemy has the method
			if enemy.has_method("apply_stun"):
				enemy.apply_stun(emp_duration)
			elif enemy.has_method("set_speed_modifier"):
				# Fallback: slow down enemy instead
				enemy.set_speed_modifier(0.2)  # 20% speed
				# Create a timer to restore speed
				var restore_timer = get_tree().create_timer(emp_duration)
				restore_timer.timeout.connect(func(): 
					if is_instance_valid(enemy) and enemy.has_method("set_speed_modifier"):
						enemy.set_speed_modifier(1.0)
				)
				
