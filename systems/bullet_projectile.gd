extends Area2D
class_name BulletProjectile

@export var speed: float = 2500.0  # Increased speed to catch moving targets
var damage_value: float = 10.0
var target_node: Node2D = null
var direction_vector: Vector2 = Vector2.ZERO
var lifetime: float = 5.0  # Increased lifetime for longer range
var frames_since_init: int = 0
var spawn_pos: Vector2 = Vector2.ZERO
var max_distance: float = 5000.0  # Increased max distance to reduce misses
var target_became_invalid: bool = false  # Track if we already logged target invalidity
var piercing_level: int = 0  # Number of additional enemies to pierce through
var _already_hit: Array = []  # Track pierced enemies to avoid double-hits

func _ready() -> void:
	body_entered.connect(Callable(self, "_on_body_entered"))
	area_entered.connect(Callable(self, "_on_area_entered"))
	# Auto-destroy after lifetime with miss logging
	get_tree().create_timer(lifetime).timeout.connect(Callable(self, "_on_lifetime_expired"))

func initialize(start_pos: Vector2, target: Node2D, dmg: float) -> void:
	global_position = start_pos
	spawn_pos = start_pos
	target_node = target
	damage_value = dmg
	frames_since_init = 0
	if is_instance_valid(target):
		var target_pos = target_node.global_position
		direction_vector = (target_pos - start_pos).normalized()
	else:
		# No valid target - bullet will travel straight up (shouldn't happen with fixed weapon system)
		direction_vector = Vector2.UP

func _physics_process(delta: float) -> void:
	frames_since_init += 1
	
	# If the unit moves or shifts positions, actively track it down
	if is_instance_valid(target_node) and target_node.is_inside_tree() and target_node.is_in_group("enemies"):
		target_became_invalid = false  # Reset flag while target is valid
		var target_pos = target_node.global_position
		direction_vector = (target_pos - global_position).normalized()
		
		# Direct hit detection: if bullet is very close to target, apply damage immediately
		var distance_to_target = global_position.distance_to(target_pos)
		if distance_to_target < 50.0:  # Collision radius of bullet + target (increased from 25)
			_apply_hit(target_node)
			return
	else:
		# Target was destroyed or became invalid - try to acquire new nearest target
		if not target_became_invalid:
			target_became_invalid = true
			
			# Find nearest enemy
			var enemies = get_tree().get_nodes_in_group("enemies")
			var nearest_enemy = null
			var nearest_distance = INF
			
			for enemy in enemies:
				if is_instance_valid(enemy):
					var dist = global_position.distance_to(enemy.global_position)
					if dist < nearest_distance:
						nearest_distance = dist
						nearest_enemy = enemy
			
			if nearest_enemy:
				target_node = nearest_enemy
				target_became_invalid = false  # Reset since we have a new target
				#print("[BulletProjectile] Re-acquired target: %s at %s" % [nearest_enemy.name, nearest_enemy.global_position])
			#else:
				#print("[BulletProjectile] No valid enemies to re-acquire. Curving lost.")
	
	global_position += direction_vector * speed * delta
	
	# Rotate projectile towards trajectory vector
	rotation = direction_vector.angle()
	
	# Check if bullet has traveled too far without hitting
	var distance_traveled = global_position.distance_to(spawn_pos)
	if distance_traveled > max_distance:
		var target_pos = target_node.global_position if is_instance_valid(target_node) else Vector2.ZERO
		var target_name = target_node.name if is_instance_valid(target_node) else "NONE"
		#print("[BulletProjectile] MISS (Max Distance) - Bullet at %s, Target %s was at %s. Distance traveled: %.1f" % [global_position, target_name, target_pos, distance_traveled])
		queue_free()
		return

	# Fallback collision check: query overlapping bodies/areas each frame
	# This ensures damage is applied even if signals don't fire in some edge cases
	var overlapped_bodies = get_overlapping_bodies()
	for body in overlapped_bodies:
		if is_instance_valid(body) and body.is_in_group("enemies") and body.has_method("take_damage"):
			_apply_hit(body)
			return

	var overlapped_areas = get_overlapping_areas()
	for area in overlapped_areas:
		if is_instance_valid(area) and area.is_in_group("enemies") and area.has_method("take_damage"):
			_apply_hit(area)
			return

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		_apply_hit(body)

func _on_area_entered(area: Area2D) -> void:
	# Extra check: if this collided area is the expected target_node, prefer that
	if is_instance_valid(target_node) and area == target_node:
		if area.has_method("take_damage"):
			_apply_hit(area)
			return
	if area.is_in_group("enemies") and area.has_method("take_damage"):
		_apply_hit(area)

## Centralized hit handler: applies damage, then either pierces through or dies.
func _apply_hit(target: Node) -> void:
	if target in _already_hit:
		return  # Already pierced through this enemy
	
	# Primary target gets full damage
	var is_pierce_hit = not _already_hit.is_empty()
	var applied_damage = damage_value * (0.5 if is_pierce_hit else 1.0)
	
	if target.has_method("take_damage"):
		target.take_damage(applied_damage)
	
	_already_hit.append(target)
	
	# If we still have piercing budget, continue flying
	if piercing_level > 0 and _already_hit.size() <= piercing_level:
		# Don't queue_free — bullet continues along its trajectory
		print("[BulletProjectile] Pierced through %s (%d/%d)" % [target.name, _already_hit.size(), piercing_level + 1])
		return
	
	# No pierce remaining — bullet is spent
	queue_free()

func _on_lifetime_expired() -> void:
	# Bullet timed out without hitting anything
	var target_pos = target_node.global_position if is_instance_valid(target_node) else Vector2.ZERO
	var target_name = target_node.name if is_instance_valid(target_node) else "NONE"
	print("[BulletProjectile] MISS (Lifetime Expired) - Bullet at %s, Target %s was at %s." % [global_position, target_name, target_pos])
	queue_free()
