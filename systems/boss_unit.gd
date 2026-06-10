extends CharacterBody2D
class_name BossUnit

# --- SIGNALS ---
signal destroyed()
signal phase_changed(phase: int)

# --- VARIABLES ---
@export var max_hp: float = 100.0
var current_hp: float = 100.0

@export var base_speed: float = 30.0
@export var speed_modifier: float = 1.0
var is_boss: bool = true
var archetype: String = "boss"

var battle_manager = null
var target_position: Vector2 = Vector2.ZERO

# Boss-specific
var current_phase: int = 1
var max_phases: int = 3
var phase_hp_thresholds: Array[float] = [0.66, 0.33]  # Phase changes at 66% and 33% HP

func _ready() -> void:
	add_to_group("enemies")
	add_to_group("boss")
	current_hp = max_hp
	battle_manager = get_node_or_null("/root/BattleManager")
	
	# Set default target to center of screen
	var viewport = get_viewport()
	if viewport:
		var viewport_size = viewport.get_visible_rect().size
		target_position = Vector2(viewport_size.x / 2.0, viewport_size.y / 2.0)

func _physics_process(delta: float) -> void:
	_move_toward_target(delta)
	_check_phase_transition()

func set_speed_modifier(modifier: float) -> void:
	speed_modifier = modifier

func set_target_position(pos: Vector2) -> void:
	target_position = pos

func set_boss_hp(hp: float) -> void:
	max_hp = hp
	current_hp = hp

func _move_toward_target(delta: float) -> void:
	if target_position == Vector2.ZERO:
		return
	
	var direction = (target_position - global_position).normalized()
	var speed = base_speed * speed_modifier
	velocity = direction * speed
	
	move_and_slide()

func _check_phase_transition() -> void:
	var hp_percent = current_hp / max_hp
	
	# Check if we should transition to next phase
	for i in range(phase_hp_thresholds.size()):
		if current_phase == (i + 1) and hp_percent <= phase_hp_thresholds[i]:
			_transition_to_phase(current_phase + 1)

func _transition_to_phase(new_phase: int) -> void:
	if new_phase > max_phases:
		return
	
	current_phase = new_phase
	print("[BossUnit] Transitioning to phase %s" % current_phase)
	
	# Apply phase-specific modifiers
	match current_phase:
		2:
			speed_modifier *= 1.5  # Speed up in phase 2
		3:
			speed_modifier *= 2.0  # Speed up more in phase 3
	
	phase_changed.emit(current_phase)

func take_damage(amount: float) -> void:
	current_hp -= amount
	if current_hp <= 0:
		execute_destruction()

func execute_destruction() -> void:
	print("[BossUnit] execute_destruction CALLED!")
	# Handshake validation to prevent dual-frame reporting errors
	remove_from_group("enemies")
	remove_from_group("boss")
	
	if battle_manager and battle_manager.has_method("register_enemy_destroyed"):
		battle_manager.register_enemy_destroyed()
	
	destroyed.emit()
	print("[BossUnit] destroyed signal emitted!")
	
	# Trigger boss explosion visual systems here before freeing memory
	queue_free()
