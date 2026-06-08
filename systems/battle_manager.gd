extends Node

signal battle_state_changed(new_state: BattleState)
signal wave_changed(wave: int)
signal enemy_count_changed(count: int)
signal stage_time_changed(time_remaining: float)
signal battle_victory()
signal battle_defeat(reason: String)
signal upgrade_milestone_reached(wave: int)
signal hearts_changed(current: int, max: int)
signal shield_points_changed(current: int)
signal wave_skipped(skipped_to: int, reward_multiplier: float)

enum BattleState { IDLE, ACTIVE, PAUSED, DEFEATED, VICTORY }

var current_stage_config: Dictionary = {}
var current_wave: int = 1
var alive_enemy_count: int = 0
var stage_time_remaining: float = 300.0
var battle_state: BattleState = BattleState.IDLE
var max_heart_limit: int = 50
var current_hearts: int = 0
var boss_spawned: bool = false
var boss_active: bool = false
var shield_points: int = 0
var credit_gain_multiplier: float = 1.0

@export var current_wave_enemy_scene: PackedScene

var _stage_timer: Timer
var _spawn_timer: Timer

func _ready() -> void:
	_setup_timers()

func _setup_timers() -> void:
	_stage_timer = Timer.new()
	_stage_timer.wait_time = 1.0
	_stage_timer.timeout.connect(_on_stage_timer_timeout)
	add_child(_stage_timer)
	
	_spawn_timer = Timer.new()
	_spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(_spawn_timer)

func start_battle(stage_id: int) -> void:
	current_wave = 1
	alive_enemy_count = 0
	stage_time_remaining = 300.0
	current_hearts = 0
	boss_spawned = false
	boss_active = false
	shield_points = 0
	credit_gain_multiplier = 1.0
	
	var progression = get_node_or_null("/root/ProgressionManager")
	if progression:
		current_stage_config = progression.get_config_for_stage(stage_id)
		
	_set_battle_state(BattleState.ACTIVE)
	_stage_timer.start()
	
	# Calculate spawn interval based on wave density (enemies_per_wave)
	# Higher density = faster spawn rate (lower interval)
	var enemies_per_wave = current_stage_config.get("enemies_per_wave", 10)
	var base_interval = 2.0  # Base spawn interval in seconds
	var density_multiplier = 10.0 / enemies_per_wave  # Normalize to base of 10 enemies
	_spawn_timer.wait_time = base_interval * density_multiplier
	_spawn_timer.start()
	
	wave_changed.emit(current_wave)
	enemy_count_changed.emit(alive_enemy_count)
	stage_time_changed.emit(stage_time_remaining)
	hearts_changed.emit(current_hearts, max_heart_limit)

func _set_battle_state(new_state: BattleState) -> void:
	battle_state = new_state
	battle_state_changed.emit(new_state)

func _on_stage_timer_timeout() -> void:
	if battle_state != BattleState.ACTIVE:
		return
	stage_time_remaining -= 1.0
	stage_time_changed.emit(stage_time_remaining)
	if stage_time_remaining <= 0:
		_handle_victory()

func _on_spawn_timer_timeout() -> void:
	if battle_state != BattleState.ACTIVE:
		return
	
	# Check if boss should spawn at wave 100
	if current_wave >= 100 and not boss_spawned:
		_spawn_boss()
		boss_spawned = true
		boss_active = true
		_spawn_timer.stop()  # Stop regular spawning when boss spawns
		return
	
	# Don't spawn regular enemies while boss is active
	if boss_active:
		return
	
	# Spawn enemies based on wave configuration
	var enemies_to_spawn = _get_enemies_for_wave(current_wave)
	for i in range(enemies_to_spawn):
		_spawn_enemy()
		alive_enemy_count += 1
	
	enemy_count_changed.emit(alive_enemy_count)
	
	if alive_enemy_count >= max_heart_limit:
		_handle_defeat("Overflow Limit Reached")
	
	# Advance wave after spawning
	_advance_wave()

func _get_enemies_for_wave(wave: int) -> int:
	# Calculate enemies per wave based on stage config and wave progression
	var base_enemies = current_stage_config.get("enemies_per_wave", 10)
	
	# Wave scaling: every 10 waves, increase enemy count by 1
	var wave_scaling = floor(wave / 10.0)
	
	# Cap at reasonable maximum
	var total_enemies = min(base_enemies + wave_scaling, 30)
	
	return int(total_enemies)

func _advance_wave() -> void:
	current_wave += 1
	wave_changed.emit(current_wave)
	
	# Wave milestone events
	_check_wave_milestones()

func _check_wave_milestones() -> void:
	# Upgrade selection milestones every 20 waves
	if current_wave in [20, 40, 60, 80]:
		print("[BattleManager] Upgrade milestone reached at wave %d" % current_wave)
		upgrade_milestone_reached.emit(current_wave)
		return

	# Difficulty milestones at 25, 50, 75
	if current_wave == 25:
		print("[BattleManager] Wave 25 milestone reached - increased difficulty")
		# Could add special wave events here
	elif current_wave == 50:
		print("[BattleManager] Wave 50 milestone reached - mid-boss event")
		# Could add mini-boss or special event
	elif current_wave == 75:
		print("[BattleManager] Wave 75 milestone reached - pre-boss surge")
		# Could add enemy surge or special composition

func skip_waves(waves_to_skip: int) -> void:
	if battle_state != BattleState.ACTIVE:
		return
	
	# Calculate target wave
	var target_wave = current_wave + waves_to_skip
	
	# Don't skip past wave 100 (boss wave)
	if target_wave >= 100:
		target_wave = 99
	
	# Get data_skip_multiplier from stage config
	var skip_multiplier = current_stage_config.get("data_skip_multiplier", 1)
	
	# Apply skip
	current_wave = target_wave
	wave_changed.emit(current_wave)
	wave_skipped.emit(target_wave, float(skip_multiplier))
	
	print("[BattleManager] Skipped to wave %d with reward multiplier %d" % [target_wave, skip_multiplier])

func _spawn_enemy() -> void:
	var enemy_scene = load("res://systems/enemy_unit.tscn")
	if not enemy_scene:
		push_error("[BattleManager] Failed to load enemy_unit.tscn")
		return
	
	var enemy = enemy_scene.instantiate()
	
	# Apply stage configuration to enemy (includes cycle scaling from ProgressionManager)
	if not current_stage_config.is_empty():
		var enemy_hp = current_stage_config.get("enemy_hp", 10.0)
		var velocity_mod = current_stage_config.get("velocity_modifier", 1.0)
		
		enemy.max_hp = enemy_hp
		enemy.current_hp = enemy_hp
		enemy.set_speed_modifier(velocity_mod)
	
	# Spawn at random edge position
	var spawn_pos = _get_random_spawn_position()
	enemy.global_position = spawn_pos
	
	# Add to scene tree
	get_tree().current_scene.add_child(enemy)
	
	# Connect to destroyed signal for proper cleanup
	enemy.destroyed.connect(_on_enemy_destroyed)

func _get_random_spawn_position() -> Vector2:
	var viewport = get_viewport()
	if not viewport:
		return Vector2.ZERO
	
	var viewport_size = viewport.get_visible_rect().size
	var edge = randi() % 4  # 0: top, 1: right, 2: bottom, 3: left
	var pos = Vector2.ZERO
	
	match edge:
		0:  # top
			pos = Vector2(randf() * viewport_size.x, -50)
		1:  # right
			pos = Vector2(viewport_size.x + 50, randf() * viewport_size.y)
		2:  # bottom
			pos = Vector2(randf() * viewport_size.x, viewport_size.y + 50)
		3:  # left
			pos = Vector2(-50, randf() * viewport_size.y)
	
	return pos

func _on_enemy_destroyed() -> void:
	register_enemy_destroyed()

func _spawn_boss() -> void:
	var boss_scene = load("res://systems/boss_unit.tscn")
	if not boss_scene:
		push_error("[BattleManager] Failed to load boss_unit.tscn")
		return
	
	var boss = boss_scene.instantiate()
	
	# Apply boss HP from stage configuration
	if not current_stage_config.is_empty():
		var boss_hp = current_stage_config.get("boss_hp", 100.0)
		boss.set_boss_hp(boss_hp)
	
	# Spawn boss at top of screen
	var viewport = get_viewport()
	if viewport:
		var viewport_size = viewport.get_visible_rect().size
		boss.global_position = Vector2(viewport_size.x / 2.0, -100)
	
	# Add to scene tree
	get_tree().current_scene.add_child(boss)
	
	# Connect to destroyed signal for stage completion
	boss.destroyed.connect(_on_boss_defeated)
	
	print("[BattleManager] Boss spawned at wave %s" % current_wave)

func _on_boss_defeated() -> void:
	boss_active = false
	print("[BattleManager] Boss defeated - triggering stage completion")
	_handle_victory()

func register_enemy_destroyed() -> void:
	if alive_enemy_count > 0:
		alive_enemy_count -= 1
		enemy_count_changed.emit(alive_enemy_count)

func register_enemy_reached_target() -> void:
	# Enemy reached the mecha - consume shield first, then lose a heart
	if shield_points > 0:
		shield_points = max(0, shield_points - 1)
		shield_points_changed.emit(shield_points)
		print("[BattleManager] Shield absorbed damage. Remaining shields: %d" % shield_points)
		return

	current_hearts += 1
	hearts_changed.emit(current_hearts, max_heart_limit)
	
	if current_hearts >= max_heart_limit:
		_handle_defeat("Heart Limit Reached")

func _handle_defeat(reason: String) -> void:
	_set_battle_state(BattleState.DEFEATED)
	_stage_timer.stop()
	_spawn_timer.stop()
	
	var progression = get_node_or_null("/root/ProgressionManager")
	if progression:
		var active_stage = progression.current_player_stage
		var checks = progression.evaluate_mecha_unlocks(active_stage)
		if not checks.is_empty():
			var unlocked_bot = checks[0]
			progression.set_active_mecha(unlocked_bot.get("mecha_id", ""))
			print("ALERT: Equipped catch-up mecha: ", unlocked_bot.get("name", ""))
	
	battle_defeat.emit(reason)

func _handle_victory() -> void:
	_set_battle_state(BattleState.VICTORY)
	_stage_timer.stop()
	_spawn_timer.stop()
	
	# Award tech credits for stage completion
	var economy = get_node_or_null("/root/EconomyManager")
	if economy:
		var base_award = 10  # Base award for stage completion
		var credits_awarded = int(round(base_award * credit_gain_multiplier))
		economy.add_tech_credits(credits_awarded, "stage_completion")
		print("[BattleManager] Awarded %d tech credits for stage completion (multiplier: %.2f)" % [credits_awarded, credit_gain_multiplier])
	
	var progression = get_node_or_null("/root/ProgressionManager")
	if progression:
		progression.advance_stage()
		
	battle_victory.emit()

func add_shield_points(amount: int) -> void:
	shield_points = max(0, shield_points + amount)
	shield_points_changed.emit(shield_points)
	print("[BattleManager] Added %d shield points. Total shields: %d" % [amount, shield_points])

func apply_credit_gain_multiplier(multiplier: float) -> void:
	credit_gain_multiplier = max(1.0, credit_gain_multiplier * multiplier)
	print("[BattleManager] Credit gain multiplier set to %.2f" % credit_gain_multiplier)

func pause_battle() -> void:
	if battle_state == BattleState.ACTIVE:
		_set_battle_state(BattleState.PAUSED)
		_stage_timer.stop()
		_spawn_timer.stop()

func resume_battle() -> void:
	if battle_state == BattleState.PAUSED:
		_set_battle_state(BattleState.ACTIVE)
		_stage_timer.start()
		_spawn_timer.start()
