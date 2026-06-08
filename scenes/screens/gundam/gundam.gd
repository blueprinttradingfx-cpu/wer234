extends Node2D

# --- EMOTION SYSTEM ---
enum BlobEmotion {
	IDLE, HAPPY, SURPRISED, SAD, ANGRY, SLEEPY, SLEEPING, WINKING, EXCITED, SMIRK, BLINK,
	LOW_POWER,
	DAMAGED,
	OVERHEAT,
	CHARGING,
	MAINTENANCE_COMPLETE,
	SOFTWARE_DEBUGGED,
	PETTED,
	COMBAT_MODE,
	VICTORY,
	DEFEAT
}

# --- COSTUME SYSTEM ---
enum GundamCostume {
	BASE,
	RX_78_2_GUNDAM,
	NU_GUNDAM,
	FREEDOM_GUNDAM,
	WING_ZERO,
	BARBATOS
}

@export var base_emotion: BlobEmotion = BlobEmotion.IDLE

# --- NODE REFERENCES ---
@onready var body_bone: Bone2D = $Skeleton2D/BodyBone2D
@onready var left_leg_bone: Bone2D = $Skeleton2D/BodyBone2D/LeftLegBone2D
@onready var right_leg_bone: Bone2D = $Skeleton2D/BodyBone2D/RightLegBone2D
@onready var body: Sprite2D = $Skeleton2D/BodyBone2D/Body
@onready var head: Sprite2D = $Skeleton2D/BodyBone2D/HeadBone/Head
@onready var left_eye: Sprite2D = $Skeleton2D/BodyBone2D/HeadBone/LeftEye
@onready var right_eye: Sprite2D = $Skeleton2D/BodyBone2D/HeadBone/RightEye
@onready var mouth: Sprite2D = $Skeleton2D/BodyBone2D/HeadBone/Mouth

# --- HOMING MISSILE SYSTEM ---
signal missile_fired(targets: Array, damage_per_rocket: float)

var missile_cooldown_timer: Timer
var missile_battery_cooldown: float = 10.0
var missile_damage_per_rocket: float = 10.0
var missile_max_targets: int = 5
var missile_current_cooldown: float = 0.0
var missile_processor_overclock_level: int = 0  # Reduces cooldown
var missile_payload_expansion_level: int = 0  # Increases rocket count

func _ready() -> void:
	_apply_emotion(base_emotion)
	_setup_missile_system()
	_load_missile_upgrades()

func _setup_missile_system() -> void:
	missile_cooldown_timer = Timer.new()
	missile_cooldown_timer.wait_time = missile_battery_cooldown
	missile_cooldown_timer.timeout.connect(_on_missile_cooldown_complete)
	add_child(missile_cooldown_timer)
	missile_cooldown_timer.start()

func _load_missile_upgrades() -> void:
	var ss = get_node_or_null("/root/SaveSystem")
	if ss and ss.has_method("get_upgrade_level"):
		missile_processor_overclock_level = ss.get_upgrade_level("energy_matrix", "processor_overclock_level")
		missile_payload_expansion_level = ss.get_upgrade_level("energy_matrix", "payload_expansion_level")
		_update_missile_stats()

func _update_missile_stats() -> void:
	# Processor Overclock: Reduces cooldown from 10.0 to 4.0 seconds
	var cooldown_reduction = missile_processor_overclock_level * 0.6  # 0.6s per level
	missile_battery_cooldown = max(4.0, 10.0 - cooldown_reduction)
	
	# Payload Expansion: Increases rockets from 5 to 15
	missile_max_targets = 5 + (missile_payload_expansion_level * 1)  # +1 per level
	
	if missile_cooldown_timer:
		missile_cooldown_timer.wait_time = missile_battery_cooldown

func change_base_emotion(new_emotion: BlobEmotion) -> void:
	base_emotion = new_emotion
	_apply_emotion(base_emotion)

func _apply_emotion(emotion: BlobEmotion) -> void:
	match emotion:
		BlobEmotion.COMBAT_MODE:
			if left_eye: left_eye.modulate = Color(1, 0.2, 0.2)
			if right_eye: right_eye.modulate = Color(1, 0.2, 0.2)
			print("[MECHA STATE]: Systems operational. Weapons online.")
		BlobEmotion.OVERHEAT:
			if left_eye: left_eye.modulate = Color(1, 1, 0)
			if right_eye: right_eye.modulate = Color(1, 1, 0)
			print("[MECHA STATE]: Warning. Thermal dissipation limits reached.")
		BlobEmotion.DEFEAT:
			if left_eye: left_eye.modulate = Color(0.2, 0.2, 0.2)
			if right_eye: right_eye.modulate = Color(0.2, 0.2, 0.2)
			print("[MECHA STATE]: System offline. Emergency power drop down.")
		BlobEmotion.VICTORY:
			if left_eye: left_eye.modulate = Color(0.2, 1.0, 0.2)
			if right_eye: right_eye.modulate = Color(0.2, 1.0, 0.2)
			print("[MECHA STATE]: Operational area clear. Posing for victory.")
		_:
			if left_eye: left_eye.modulate = Color(1, 1, 1)
			if right_eye: right_eye.modulate = Color(1, 1, 1)

func _on_missile_cooldown_complete() -> void:
	_fire_homing_missiles()

func _fire_homing_missiles() -> void:
	var targets = _acquire_missile_targets()
	if targets.is_empty():
		return
	
	print("🚀 [MISSILE LAUNCH] Firing ", targets.size(), " missiles at targets")
	missile_fired.emit(targets, missile_damage_per_rocket)
	
	# Apply damage to targets
	for target in targets:
		if is_instance_valid(target) and target.has_method("take_damage"):
			target.take_damage(missile_damage_per_rocket)
	
	# Restart cooldown
	if missile_cooldown_timer:
		missile_cooldown_timer.start()

func _acquire_missile_targets() -> Array:
	var targets: Array = []
	var live_enemies = get_tree().get_nodes_in_group("enemies")
	
	if live_enemies.is_empty():
		return targets
	
	# Sort by proximity to mecha
	live_enemies.sort_custom(func(a, b): 
		return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
	)
	
	# Get up to max_targets closest enemies
	for i in range(min(missile_max_targets, live_enemies.size())):
		if is_instance_valid(live_enemies[i]):
			targets.append(live_enemies[i])
	
	return targets

func get_missile_cooldown_percent() -> float:
	if missile_cooldown_timer:
		return 1.0 - (missile_cooldown_timer.time_left / missile_cooldown_timer.wait_time)
	return 0.0