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

var total_expected_this_wave: int = 0
var total_spawned_this_wave: int = 0
var current_wave_start_time: float = 0.0

var custom_spawner: Node = null

@export var current_wave_enemy_scene: PackedScene

var _stage_timer: Timer
var _spawn_timer: Timer
var _wave_delay_timer: Timer
var enemy_speed_global_modifier: float = 1.2 # +20% movement speed

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
	
	_wave_delay_timer = Timer.new()
	_wave_delay_timer.one_shot = true
	_wave_delay_timer.timeout.connect(_on_wave_delay_timeout)
	add_child(_wave_delay_timer)

func start_battle(stage_id: int, starting_wave: int = 1) -> void:
	current_wave = starting_wave
	alive_enemy_count = 0
	current_hearts = 0
	boss_spawned = false
	boss_active = false
	shield_points = 0
	credit_gain_multiplier = 1.0
	
	var progression = get_node_or_null("/root/ProgressionManager")
	if progression:
		current_stage_config = progression.get_config_for_stage(stage_id)
		stage_time_remaining = current_stage_config.get("boss_timer", 240.0)
	else:
		stage_time_remaining = 240.0
		
	_set_battle_state(BattleState.ACTIVE)
	# Stage timer will start when boss spawns
	
	_spawn_current_wave()
	
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
		_handle_defeat("Time Expired")

func _spawn_current_wave() -> void:
	var total_waves = current_stage_config.get("total_waves", 100)
	if current_wave >= total_waves:
		if not boss_spawned:
			_spawn_boss()
			boss_spawned = true
			boss_active = true
			_spawn_timer.stop()
			# Start stage timer when boss spawns
			_stage_timer.start()
		return
		
	total_expected_this_wave = _get_enemies_for_wave(current_wave)
	total_spawned_this_wave = 0
	current_wave_start_time = Time.get_ticks_msec() / 1000.0
	
	var spawn_interval = current_stage_config.get("spawn_interval", 0.5)
	_spawn_timer.wait_time = spawn_interval
	_spawn_timer.start()
	print("[BattleManager] 🌊 Wave %d STARTED | Expected enemies: %d" % [current_wave, total_expected_this_wave])

func _on_spawn_timer_timeout() -> void:
	if battle_state != BattleState.ACTIVE or boss_active:
		return
		
	if total_spawned_this_wave < total_expected_this_wave:
		_spawn_enemy()
		alive_enemy_count += 1
		total_spawned_this_wave += 1
		enemy_count_changed.emit(alive_enemy_count)
		
		if alive_enemy_count >= max_heart_limit:
			_handle_defeat("Overflow Limit Reached")
			return
			
	if total_spawned_this_wave >= total_expected_this_wave:
		_spawn_timer.stop()
		
		var wave_delay = current_stage_config.get("wave_delay", 2.0)
		print("[BattleManager] ⏱ Wave %d finished spawning. Delaying %.1fs before next wave..." % [current_wave, wave_delay])
		
		_wave_delay_timer.wait_time = wave_delay
		_wave_delay_timer.start()

func _check_wave_cleared() -> void:
	if battle_state != BattleState.ACTIVE or boss_active:
		return
		
	if total_spawned_this_wave >= total_expected_this_wave and alive_enemy_count <= 0:
		var wave_clear_time = (Time.get_ticks_msec() / 1000.0) - current_wave_start_time
		var data_skip_multiplier = current_stage_config.get("data_skip_multiplier", 1)
		
		# If cleared fast enough (< 1.0s) and skip is available, apply skip bonus
		if wave_clear_time < 1.0 and data_skip_multiplier > 1:
			skip_waves(data_skip_multiplier)

func _on_wave_delay_timeout() -> void:
	print("[BattleManager] _on_wave_delay_timeout triggered. State: ", get_state_string())
	if battle_state == BattleState.ACTIVE:
		_advance_wave()
		_spawn_current_wave()
	else:
		print("[BattleManager] Ignoring wave delay timeout because state is not ACTIVE")

func _get_enemies_for_wave(_wave: int) -> int:
	# Pull strictly from config; no infinite linear scaling
	return current_stage_config.get("enemies_per_wave", 10)

func _advance_wave() -> void:
	current_wave += 1
	wave_changed.emit(current_wave)
	print("[BattleManager] 📈 Advanced to wave %d" % current_wave)
	_check_wave_milestones()

func _check_wave_milestones() -> void:
	# Upgrade selection milestones every 20 waves
	if current_wave in [20, 40, 60, 80]:
		print("[BattleManager] Upgrade milestone reached at wave %d" % current_wave)
		upgrade_milestone_reached.emit(current_wave)

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
	#print("[BattleManager] _spawn_enemy called. custom_spawner is: ", custom_spawner)
	if is_instance_valid(custom_spawner) and custom_spawner.has_method("spawn_wave_enemy"):
		#print("[BattleManager] Calling custom_spawner.spawn_wave_enemy()")
		var spawned_enemy = custom_spawner.spawn_wave_enemy()
		if not spawned_enemy:
			print("[BattleManager] spawn_wave_enemy returned null. Returning.")
			return # Capacity reached
		
		# Apply stage configuration
		if not current_stage_config.is_empty() and spawned_enemy.has_method("set_speed_modifier"):
			var enemy_hp = current_stage_config.get("enemy_hp", 10.0)
			var velocity_mod = current_stage_config.get("velocity_modifier", 1.0) * enemy_speed_global_modifier
			var base_speed = current_stage_config.get("enemy_movement_speed", -1.0)
			
			spawned_enemy.set("max_hp", enemy_hp)
			spawned_enemy.set("current_hp", enemy_hp)
			spawned_enemy.set_speed_modifier(velocity_mod)
			
			if base_speed > 0:
				if "base_speed" in spawned_enemy:
					spawned_enemy.set("base_speed", base_speed)
				elif "speed" in spawned_enemy:
					spawned_enemy.set("speed", base_speed)
			
			var archetype = current_stage_config.get("archetype", "The Entry Stream")
			_apply_archetype_mechanics(spawned_enemy, archetype, enemy_hp)
			
		if spawned_enemy.has_signal("destroyed"):
			spawned_enemy.destroyed.connect(_on_enemy_destroyed)
		return

	print("[BattleManager] Falling back to manual load!")
	var enemy_scene = load("res://systems/enemy_unit.tscn")
	if not enemy_scene:
		push_error("[BattleManager] Failed to load enemy_unit.tscn")
		return
	
	var enemy = enemy_scene.instantiate()
	
	# Apply stage configuration to enemy (includes cycle scaling from ProgressionManager)
	if not current_stage_config.is_empty():
		var enemy_hp = current_stage_config.get("enemy_hp", 10.0)
		var velocity_mod = current_stage_config.get("velocity_modifier", 1.0)
		var base_speed = current_stage_config.get("enemy_movement_speed", -1.0)
		
		enemy.max_hp = enemy_hp
		enemy.current_hp = enemy_hp
		if enemy.has_method("set_speed_modifier"):
			enemy.set_speed_modifier(velocity_mod)
		
		if base_speed > 0:
			if "base_speed" in enemy:
				enemy.base_speed = base_speed
			elif "speed" in enemy:
				enemy.speed = base_speed
			
		var archetype = current_stage_config.get("archetype", "The Entry Stream")
		_apply_archetype_mechanics(enemy, archetype, enemy_hp)
	
	# Spawn at random edge position
	var spawn_pos = _get_random_spawn_position()
	enemy.global_position = spawn_pos
	
	# Add to scene tree
	get_tree().current_scene.add_child(enemy)
	
	# Connect to destroyed signal for proper cleanup
	if enemy.has_signal("destroyed"):
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

func end_battle(reason: String = "Manual End") -> void:
	if battle_state == BattleState.ACTIVE:
		_handle_defeat(reason)

func get_state_string() -> String:
	match battle_state:
		BattleState.IDLE: return "IDLE"
		BattleState.ACTIVE: return "ACTIVE"
		BattleState.PAUSED: return "PAUSED"
		BattleState.VICTORY: return "VICTORY"
		BattleState.DEFEATED: return "DEFEATED"
	return "UNKNOWN"

func _apply_archetype_mechanics(enemy: Node2D, archetype: String, base_hp: float) -> void:
	if not is_instance_valid(enemy):
		return
		
	# Store archetype identifier on the unit if supported (useful for debugging/logging)
	if "archetype" in enemy:
		enemy.set("archetype", archetype)

	match archetype:
		"Shielded Packets":
			if enemy.has_method("enable_shield"):
				# 50% HP as shield, 50% damage reduction
				enemy.enable_shield(base_hp * 0.5, 0.5)
		"Splitting Malware":
			if enemy.has_method("enable_splitting"):
				# 2 children, 0 depth, max 2 depth, 50% hp multiplier
				enemy.enable_splitting(2, 0, 2, 0.5)
		"The EMP Jammer":
			if enemy.has_method("enable_emp"):
				# 150px radius, 2s duration, on death
				enemy.enable_emp(150.0, 2.0, true)
		"Re-routing Logic":
			if enemy.has_method("enable_re_routing"):
				# 3 seconds interval
				enemy.enable_re_routing(3.0)
		"Regenerative Stream":
			if enemy.has_method("enable_regen"):
				# 10% HP per sec, 2s pause
				enemy.enable_regen(base_hp * 0.1, 2.0)
		"Swarm Carrier":
			if enemy.has_method("enable_carrier"):
				# 3 payload size, 2s interval, 30% hp
				enemy.enable_carrier(3, 2.0, 0.3)
		"The Phantom Grid":
			if enemy.has_method("enable_cloak"):
				# 3s cloak, 5s cooldown
				enemy.enable_cloak(3.0, 5.0)
		"The Final Meltdown":
			# Curated combination of the deadliest mechanics (Shield + Splitting + Regen)
			if enemy.has_method("enable_shield"):
				enemy.enable_shield(base_hp * 0.5, 0.5)
			if enemy.has_method("enable_regen"):
				enemy.enable_regen(base_hp * 0.1, 2.0)
			if enemy.has_method("enable_splitting"):
				enemy.enable_splitting(2, 0, 2, 0.5)
		_:
			# "The Entry Stream", "The Rush Protocol" or unhandled defaults have no extra mechanics
			pass

func pause_battle() -> void:
	if battle_state == BattleState.ACTIVE:
		_set_battle_state(BattleState.PAUSED)
		_stage_timer.paused = true
		_spawn_timer.paused = true
		_wave_delay_timer.paused = true

func resume_battle() -> void:
	if battle_state == BattleState.PAUSED:
		_set_battle_state(BattleState.ACTIVE)
		_stage_timer.paused = false
		_spawn_timer.paused = false
		_wave_delay_timer.paused = false

func register_enemy_destruction() -> void:
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
	_check_wave_cleared()

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
	print("[BattleManager] ☠ BATTLE DEFEAT TRIGGERED: ", reason)
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
