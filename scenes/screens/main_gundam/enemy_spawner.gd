extends Node2D

# --- Signals to notify Main Loop ---
signal enemy_spawned(current_total: int)
signal enemy_defeated(current_total: int)

@export var enemy_scene: PackedScene 
@export var spawn_radius: float = 650.0 

var center_position: Vector2 = Vector2(540, 960) 
var active_enemies: Array[Node2D] = []
var max_screen_capacity: int = 50

# Injected by main_gundam_scene.gd after setup - avoids fragile absolute/find_child lookups
var square_path_node: Path2D = null
var gameplay_arena_node: Node2D = null

func spawn_wave_enemy() -> Node2D:
	print("[EnemySpawner] spawn_wave_enemy called")
	if active_enemies.size() >= max_screen_capacity:
		print("[EnemySpawner] Capacity reached")
		return null
		
	if not enemy_scene:
		print("[EnemySpawner] enemy_scene is null! Falling back to mock")
		return _fallback_mock_spawn()

	# 1. Fetch our visual path via injected reference
	var square_path = square_path_node
	if not square_path:
		print("[EnemySpawner] square_path is null! Falling back to manual square")
		return _spawn_enemy_manual_square()

	# 2. Instantiate a PathFollow2D wrapper
	var path_follower = PathFollow2D.new()
	path_follower.rotates = false # Keeps your enemy sprite upright while circling
	path_follower.loop = true     # Allows non-stop circling until the match ends
	
	# 3. Instantiate the enemy unit and attach it to the follower wrapper
	var enemy_instance = enemy_scene.instantiate() 
	print("[EnemySpawner] Instantiated enemy: ", enemy_instance)
	path_follower.add_child(enemy_instance); 
	
	# 4. Attach the wrapper to the path
	square_path.add_child(path_follower)
	
	# 5. Tell the enemy it's riding on a path follower
	if enemy_instance.has_method("initialize_path_movement"):
		enemy_instance.initialize_path_movement(path_follower)
	
	active_enemies.append(enemy_instance)
	enemy_spawned.emit(active_enemies.size())
	
	if enemy_instance.has_signal("tree_exited"):
		enemy_instance.tree_exited.connect(_on_enemy_tree_exited.bind(enemy_instance))
		
	return enemy_instance

func _spawn_enemy_manual_square() -> Node2D:
	# Try to use Path2D first, fall back to true manual movement
	var square_path = square_path_node
	
	if square_path:
		# Use PathFollow2D like the main spawn function
		var path_follower = PathFollow2D.new()
		path_follower.rotates = false
		path_follower.loop = true
		
		var enemy_instance = enemy_scene.instantiate()
		path_follower.add_child(enemy_instance); 
		square_path.add_child(path_follower)
		
		if enemy_instance.has_method("initialize_path_movement"):
			enemy_instance.initialize_path_movement(path_follower)
		
		active_enemies.append(enemy_instance)
		enemy_spawned.emit(active_enemies.size())
		
		if enemy_instance.has_signal("tree_exited"):
			enemy_instance.tree_exited.connect(_on_enemy_tree_exited.bind(enemy_instance))
			
		return enemy_instance
	else:
		# True manual square corner movement fallback - spawn at path Point 0
		var enemy_instance = enemy_scene.instantiate()
		enemy_instance.position = Vector2(134, 252)
		
		# Add to GameplayArena for proper collision detection
		if gameplay_arena_node:
			gameplay_arena_node.add_child(enemy_instance)
		else:
			add_child(enemy_instance)
		
		active_enemies.append(enemy_instance)
		enemy_spawned.emit(active_enemies.size())
		
		if enemy_instance.has_signal("tree_exited"):
			enemy_instance.tree_exited.connect(_on_enemy_tree_exited.bind(enemy_instance))
			
		return enemy_instance

func _spawn_mock_manual_square() -> Node2D:
	# Try to use Path2D first, fall back to true manual movement
	var square_path = square_path_node
	
	if square_path:
		# Use PathFollow2D like the main fallback spawn function
		var path_follower = PathFollow2D.new()
		path_follower.rotates = false
		path_follower.loop = true
		
		var mock_enemy = Area2D.new()
		mock_enemy.add_to_group("enemies")
		mock_enemy.collision_layer = 1
		mock_enemy.collision_mask = 0
		mock_enemy.monitorable = true
		
		# Add collision shape
		var collision_shape = CollisionShape2D.new()
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = 20.0
		collision_shape.shape = circle_shape
		mock_enemy.add_child(collision_shape)
		
		# Add visual marker
		var visual_box = ColorRect.new()
		visual_box.color = Color(1.0, 0.2, 0.2, 1.0)
		visual_box.size = Vector2(40, 40)
		visual_box.position = Vector2(-20, -20)
		mock_enemy.add_child(visual_box)
		
		# PathFollow2D movement script
		var inline_script = GDScript.new()
		inline_script.source_code = """
extends Area2D
var speed: float = 140.0
var max_hp: float = 10.0
var current_hp: float = 10.0

var follower_node: PathFollow2D = null
var is_on_path_track: bool = false
var entry_target_position: Vector2 = Vector2.ZERO

signal destroyed()

func initialize_path_movement(wrapper: PathFollow2D) -> void:
	follower_node = wrapper
	# Snap to Point 0 (top-left, 134,252) and start following immediately
	follower_node.progress = 0.0
	is_on_path_track = true
	position = Vector2.ZERO

func _process(delta: float) -> void:
	if not follower_node:
		return
	if not is_on_path_track:
		var direction = (entry_target_position - global_position).normalized()
		global_position += direction * speed * delta
		if global_position.distance_to(entry_target_position) < 15.0:
			is_on_path_track = true
			position = Vector2.ZERO
	else:
		follower_node.progress += speed * delta

func take_damage(amount: float) -> void:
	current_hp -= amount
	if current_hp <= 0:
		destroyed.emit()
		if follower_node and is_instance_valid(follower_node):
			follower_node.queue_free()
		else:
			queue_free()
"""
		inline_script.reload()
		mock_enemy.set_script(inline_script)
		
		# Attach components to each other and place on path
		path_follower.add_child(mock_enemy)
		square_path.add_child(path_follower)
		mock_enemy.initialize_path_movement(path_follower)
		
		active_enemies.append(mock_enemy)
		
		if mock_enemy.has_signal("destroyed"):
			mock_enemy.destroyed.connect(_on_enemy_tree_exited.bind(mock_enemy))
		
		enemy_spawned.emit(active_enemies.size())
		_sync_battle_manager_count()
		return mock_enemy
	else:
		# True manual square corner movement fallback for mock enemies
		var mock_enemy = Area2D.new()
		mock_enemy.add_to_group("enemies")
		mock_enemy.collision_layer = 1
		mock_enemy.collision_mask = 0
		mock_enemy.monitorable = true
		
		# Add collision shape
		var collision_shape = CollisionShape2D.new()
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = 20.0
		collision_shape.shape = circle_shape
		mock_enemy.add_child(collision_shape)
		
		# Add visual marker
		var visual_box = ColorRect.new()
		visual_box.color = Color(1.0, 0.2, 0.2, 1.0)
		visual_box.size = Vector2(40, 40)
		visual_box.position = Vector2(-20, -20)
		mock_enemy.add_child(visual_box)
		
		# Manual square path movement script
		var inline_script = GDScript.new()
		inline_script.source_code = """
extends Area2D
var speed: float = 140.0
var center_pos: Vector2 = Vector2(540, 960)
var square_size: float = 400.0
var path_index: int = 0
var max_hp: float = 10.0
var current_hp: float = 10.0

signal destroyed()

func _ready() -> void:
	# Set initial path index based on spawn position
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

func _process(delta: float) -> void:
	var corners = [
		Vector2(134, 252),   # Top-Left
		Vector2(965, 254),   # Top-Right
		Vector2(962, 1480),  # Bottom-Right
		Vector2(136, 1478)   # Bottom-Left
	]
	var target_corner = corners[path_index]
	var direction = (target_corner - global_position).normalized()
	global_position += direction * speed * delta
	if global_position.distance_to(target_corner) < 10.0:
		path_index = (path_index + 1) % 4

func take_damage(amount: float) -> void:
	current_hp -= amount
	if current_hp <= 0:
		destroyed.emit()
		queue_free()
"""
		inline_script.reload()
		mock_enemy.set_script(inline_script)
		
		# Spawn at path Point 0 (134, 252)
		mock_enemy.position = Vector2(134, 252)
		
		# Add to GameplayArena
		if gameplay_arena_node:
			gameplay_arena_node.add_child(mock_enemy)
		else:
			add_child(mock_enemy)
		
		active_enemies.append(mock_enemy)
		
		if mock_enemy.has_signal("destroyed"):
			mock_enemy.destroyed.connect(_on_enemy_tree_exited.bind(mock_enemy))
		
		enemy_spawned.emit(active_enemies.size())
		_sync_battle_manager_count()
		return mock_enemy

func _fallback_mock_spawn() -> Node2D:
	# 1. Fetch our visual path via injected reference
	var square_path = square_path_node
	if not square_path:
		_spawn_mock_manual_square()
		return
	# 2. Instantiate a PathFollow2D wrapper
	var path_follower = PathFollow2D.new()
	path_follower.rotates = false
	path_follower.loop = true

	var mock_enemy = Area2D.new()
	mock_enemy.add_to_group("enemies")
	mock_enemy.collision_layer = 1  # Layer 1 for enemies (matches enemy_unit.tscn)
	mock_enemy.collision_mask = 0
	mock_enemy.monitorable = true  # Allow bullets to detect this area
	
	# Add collision shape for bullet detection
	var collision_shape = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = 20.0
	collision_shape.shape = circle_shape
	mock_enemy.add_child(collision_shape)
	
	# Add visual marker box
	var visual_box = ColorRect.new()
	visual_box.color = Color(1.0, 0.2, 0.2, 1.0)
	visual_box.size = Vector2(40, 40)
	visual_box.position = Vector2(-20, -20) 
	mock_enemy.add_child(visual_box)
	
	# Dynamic Tracking behavior script using PathFollow2D progress properties
	var inline_script = GDScript.new()
	inline_script.source_code = """
extends Area2D
var speed: float = 140.0
var max_hp: float = 10.0
var current_hp: float = 10.0

var follower_node: PathFollow2D = null
var is_on_path_track: bool = false
var entry_target_position: Vector2 = Vector2.ZERO

signal destroyed()

func initialize_path_movement(wrapper: PathFollow2D) -> void:
	follower_node = wrapper
	# Snap to Point 0 (top-left, 134,252) and start following immediately
	follower_node.progress = 0.0
	is_on_path_track = true
	position = Vector2.ZERO

func _process(delta: float) -> void:
	if not follower_node:
		return
	if not is_on_path_track:
		var direction = (entry_target_position - global_position).normalized()
		global_position += direction * speed * delta
		if global_position.distance_to(entry_target_position) < 15.0:
			is_on_path_track = true
			position = Vector2.ZERO
	else:
		follower_node.progress += speed * delta

func take_damage(amount: float) -> void:
	current_hp -= amount
	if current_hp <= 0:
		destroyed.emit()
		if follower_node and is_instance_valid(follower_node):
			follower_node.queue_free()
		else:
			queue_free()
"""
	inline_script.reload()
	mock_enemy.set_script(inline_script)
	
	# Attach components to each other and place on path
	path_follower.add_child(mock_enemy)
	square_path.add_child(path_follower)
	mock_enemy.initialize_path_movement(path_follower)
	
	active_enemies.append(mock_enemy)
	
	# Connect destroyed signal for proper cleanup
	if mock_enemy.has_signal("destroyed"):
		mock_enemy.destroyed.connect(_on_enemy_tree_exited.bind(mock_enemy))
	
	enemy_spawned.emit(active_enemies.size())
	_sync_battle_manager_count()
	return mock_enemy

func _on_enemy_tree_exited(enemy_node: Node2D) -> void:
	if enemy_node in active_enemies:
		active_enemies.erase(enemy_node)
		
	var bm = get_node_or_null("/root/BattleManager")
	if bm:
		if bm.has_method("register_enemy_destroyed"):
			bm.register_enemy_destroyed()
		_sync_battle_manager_count()
		
	enemy_defeated.emit(active_enemies.size())

func _sync_battle_manager_count() -> void:
	var bm = get_node_or_null("/root/BattleManager")
	if bm:
		bm.alive_enemy_count = active_enemies.size()
		if bm.has_signal("enemy_count_changed"):
			bm.enemy_count_changed.emit(active_enemies.size())
