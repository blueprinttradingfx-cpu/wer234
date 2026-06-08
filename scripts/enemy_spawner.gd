extends Node2D

# --- Signals to notify Main Loop ---
signal enemy_spawned(current_total: int)
signal enemy_defeated(current_total: int)

@export var enemy_scene: PackedScene 
@export var spawn_radius: float = 650.0 

var center_position: Vector2 = Vector2(540, 960) 
var active_enemies: Array[Node2D] = []
var max_screen_capacity: int = 50

func spawn_wave_enemy() -> void:
	if active_enemies.size() >= max_screen_capacity:
		print("⚠ Spawner choked: Maximum live threshold met (50/50).")
		return
		
	if not enemy_scene:
		_fallback_mock_spawn()
		return
		
	var enemy_instance = enemy_scene.instantiate()
	var random_angle: float = randf() * TAU
	var spawn_offset: Vector2 = Vector2.from_angle(random_angle) * spawn_radius
	enemy_instance.position = center_position + spawn_offset
	
	add_child(enemy_instance)
	active_enemies.append(enemy_instance)
	enemy_spawned.emit(active_enemies.size())
	
	if enemy_instance.has_signal("tree_exited"):
		enemy_instance.tree_exited.connect(_on_enemy_tree_exited.bind(enemy_instance))

func _fallback_mock_spawn() -> void:
	var mock_enemy = Node2D.new()
	mock_enemy.add_to_group("enemies")
	
	# Add visual marker box
	var visual_box = ColorRect.new()
	visual_box.color = Color(1.0, 0.2, 0.2, 1.0)
	visual_box.size = Vector2(40, 40)
	visual_box.position = Vector2(-20, -20) 
	mock_enemy.add_child(visual_box)
	
	# Dynamic Tracking behavior script targeting the live player node context
	var inline_script = GDScript.new()
	inline_script.source_code = """
extends Node2D
var speed: float = 140.0
var default_fallback: Vector2 = Vector2(540, 960)

func _process(delta: float) -> void:
	var target_node = get_tree().get_first_node_in_group("player")
	if not target_node:
		# Fallback tracking if group tags aren't initialized yet
		var arena = get_node_or_null("/root/MainGameScene/ArenaContainer/Viewport/GameplayArena")
		if arena and arena.get_child_count() > 0:
			target_node = arena.get_child(0)
			
	var target_pos = target_node.global_position if target_node else default_fallback
	var direction = (target_pos - global_position).normalized()
	global_position += direction * speed * delta
"""
	inline_script.reload()
	mock_enemy.set_script(inline_script)
	
	# Distribute spawns safely along peripheral boundaries
	var random_angle: float = randf() * TAU
	mock_enemy.position = center_position + Vector2.from_angle(random_angle) * spawn_radius
	
	add_child(mock_enemy)
	active_enemies.append(mock_enemy)
	print("👾 Fallback Target Spawned at: ", mock_enemy.position, " (Total: ", active_enemies.size(), "/50)")
	
	enemy_spawned.emit(active_enemies.size())
	_sync_battle_manager_count()
	
	if mock_enemy.has_signal("tree_exited"):
		mock_enemy.tree_exited.connect(_on_enemy_tree_exited.bind(mock_enemy))

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
