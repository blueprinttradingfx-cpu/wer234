extends Control

# --- Mid-Run Powerup Button Mappings ---
@onready var atk_spd_btn: Button = %AtkSpdBtn
@onready var pierce_btn: Button = %PierceBtn
@onready var cooldown_btn: Button = %CooldownBtn
@onready var move_spd_btn: Button = %MoveSpdBtn
@onready var matrix_btn: Button = %MatrixBtn
@onready var overclock_btn: Button = %OverclockBtn

# --- Scene Unique Node Mappings ---
@onready var alive_counter_label: Label = %AliveCounterLabel
@onready var clock_label: Label = %ClockLabel
@onready var wave_label: Label = %WaveLabel
@onready var gameplay_arena: Node2D = %GameplayArena
@onready var battery_progress: ProgressBar = %BatteryProgress

const UPGRADE_EFFECT_SYSTEM := preload("res://systems/upgrade_effect_system.gd")

# --- Timers and Combat Handles ---
var weapon_system: Node2D = null
var wave_spawn_timer: Timer
var spawner_node: Node2D = null
var mecha_instance: Node2D = null
var battery_update_timer: Timer
var upgrade_effect_system: UpgradeEffectSystem = null
var current_upgrade_overlay: SoftwareUpgradeOverlay = null

# --- Live Stats Modifiers ---
var multi_shot_level: int = 0
var pierce_unlocked: bool = true 
var is_overclock_active: bool = false

# --- Core Matrix Parameters ---
var alive_enemies_count: int = 0:
	set(value):
		alive_enemies_count = value
		_update_ui()
		if alive_enemies_count >= 50:
			trigger_system_overflow_failure()

var current_stage: int = 11
var current_wave: int = 11
var match_remaining_time: float = 292.0
var is_game_active: bool = false

func _ready() -> void:
	_setup_enemy_spawner()
	_setup_scene_timers()
	_setup_upgrade_effect_system()
	_connect_autoload_signals()
	_load_initial_upgrades()
	_start_current_game_session()

func _setup_enemy_spawner() -> void:
	spawner_node = get_node_or_null("EnemySpawner")
	if not spawner_node:
		print("🚀 EnemySpawner node not found in scene tree. Creating dynamically...")
		spawner_node = Node2D.new()
		spawner_node.name = "EnemySpawner"
		var spawner_script = load("res://scripts/enemy_spawner.gd")
		if spawner_script:
			spawner_node.set_script(spawner_script)
		add_child(spawner_node)

func _setup_scene_timers() -> void:
	# Instantiate WeaponSystem component
	var weapon_scene = load("res://systems/weapon_system.tscn")
	if weapon_scene:
		weapon_system = weapon_scene.instantiate()
		add_child(weapon_system)
		if weapon_system.has_signal("enemy_shot_fired"):
			weapon_system.enemy_shot_fired.connect(_on_enemy_shot_fired)
	else:
		push_error("[MainGameScene] Failed to load WeaponSystem scene")
	
	wave_spawn_timer = Timer.new()
	wave_spawn_timer.wait_time = 0.6 
	wave_spawn_timer.timeout.connect(_on_wave_spawn_cycle)
	add_child(wave_spawn_timer)
	
	# Battery UI update timer
	battery_update_timer = Timer.new()
	battery_update_timer.wait_time = 0.1  # Update 10 times per second
	battery_update_timer.timeout.connect(_update_battery_ui)
	add_child(battery_update_timer)

func _connect_autoload_signals() -> void:
	var bm = get_node_or_null("/root/BattleManager")
	if bm:
		bm.battle_state_changed.connect(_on_battle_state_changed)
		bm.wave_changed.connect(_on_wave_changed)
		bm.enemy_count_changed.connect(_on_enemy_count_changed)
		bm.stage_time_changed.connect(_on_stage_time_changed)
		bm.battle_victory.connect(_on_battle_victory)
		bm.battle_defeat.connect(_on_battle_defeat)
		bm.upgrade_milestone_reached.connect(_on_upgrade_milestone_reached)

func _load_initial_upgrades() -> void:
	var ss = get_node_or_null("/root/SaveSystem")
	if ss and ss.has_method("get_upgrade_level"):
		multi_shot_level = ss.get_upgrade_level("ballistic_core", "multi_shot_loader_level")
		var attack_speed_upgrade = ss.get_upgrade_level("ballistic_core", "chassis_calibrator_level")
		var pierce_upgrade = ss.get_upgrade_level("ballistic_core", "piercing_barrel_level")
		
		if weapon_system:
			weapon_system.set_multi_shot_level(multi_shot_level)
			weapon_system.set_attack_speed(2.5 + (attack_speed_upgrade * 0.55)) # 2.5 to 8.0
			if pierce_upgrade > 0:
				pierce_unlocked = true

func _start_current_game_session() -> void:
	is_game_active = true
	var pm = get_node_or_null("/root/ProgressionManager")
	if pm and "current_player_stage" in pm:
		current_stage = pm.current_player_stage
		
	var bm = get_node_or_null("/root/BattleManager")
	if bm and bm.has_method("start_battle"):
		bm.start_battle(current_stage)
		
	_instantiate_active_mecha()
	
	if is_instance_valid(weapon_system): weapon_system.update_weapon_speed()
	if is_instance_valid(wave_spawn_timer): wave_spawn_timer.start()
	if is_instance_valid(battery_update_timer): battery_update_timer.start()

func _instantiate_active_mecha() -> void:
	if not gameplay_arena: return
	for child in gameplay_arena.get_children():
		child.queue_free()
		
	var target_mecha_path = "res://scenes/screens/gundam/gundam.tscn"
	if ResourceLoader.exists(target_mecha_path):
		var mecha_scene = load(target_mecha_path)
		mecha_instance = mecha_scene.instantiate()
		mecha_instance.add_to_group("player") # Explicit group mapping for dynamic tracking scripts
		gameplay_arena.add_child(mecha_instance)
		
		# Connect missile fired signal
		if mecha_instance.has_signal("missile_fired"):
			mecha_instance.missile_fired.connect(_on_missile_fired)
		
		await get_tree().process_frame
		if is_instance_valid(mecha_instance) and mecha_instance.has_method("change_base_emotion"):
			mecha_instance.change_base_emotion(18) 

func _update_ui() -> void:
	if alive_counter_label:
		alive_counter_label.text = "%d / 50" % alive_enemies_count

func _update_battery_ui() -> void:
	if battery_progress and is_instance_valid(mecha_instance) and mecha_instance.has_method("get_missile_cooldown_percent"):
		var cooldown_percent = mecha_instance.get_missile_cooldown_percent()
		battery_progress.value = cooldown_percent * 100.0

func _on_enemy_shot_fired(projectile_data: Dictionary) -> void:
	if not is_game_active: return
	
	var target_position = projectile_data.get("target_position", Vector2.ZERO)
	var damage = projectile_data.get("damage", 10.0)
	var bullet_index = projectile_data.get("bullet_index", 0)
	
	print("⚔ [WEAPONS FIRE] Shot fired at: ", target_position, " damage: ", damage, " index: ", bullet_index)
	
	# WeaponSystem handles the actual damage via take_damage() on enemies
	# This signal is for VFX/audio feedback hooks 

func _on_missile_fired(targets: Array, damage_per_rocket: float) -> void:
	if not is_game_active: return
	print("🚀 [MISSILE IMPACT] ", targets.size(), " missiles dealing ", damage_per_rocket, " damage each")

func _on_wave_spawn_cycle() -> void:
	if not is_game_active: return
	if is_instance_valid(spawner_node) and spawner_node.has_method("spawn_wave_enemy"):
		spawner_node.spawn_wave_enemy()

func open_popup_view(menu_type: String) -> void:
	print("Instantiating overlay view container sector: ", menu_type.to_upper())

func trigger_system_overflow_failure() -> void:
	is_game_active = false
	if is_instance_valid(weapon_system): weapon_system.fire_timer.stop()
	if is_instance_valid(wave_spawn_timer): wave_spawn_timer.stop()
	if is_instance_valid(battery_update_timer): battery_update_timer.stop()
	
	print("💥 STAGE OVERFLOW FAILURE: Combat zone breached.")
	var mecha = gameplay_arena.get_child(0) if gameplay_arena.get_child_count() > 0 else null
	if mecha and mecha.has_method("change_base_emotion"):
		mecha.change_base_emotion(20) 

func trigger_stage_clear_victory() -> void:
	is_game_active = false
	if is_instance_valid(weapon_system): weapon_system.fire_timer.stop()
	if is_instance_valid(wave_spawn_timer): wave_spawn_timer.stop()
	if is_instance_valid(battery_update_timer): battery_update_timer.stop()
	
	print("🏆 STAGE CLEAR VICTORY: Operational sector stabilized.")
	var mecha = gameplay_arena.get_child(0) if gameplay_arena.get_child_count() > 0 else null
	if mecha and mecha.has_method("change_base_emotion"):
		mecha.change_base_emotion(19)

# --- BattleManager Signal Handlers ---
func _on_battle_state_changed(new_state: int) -> void:
	match new_state:
		0: is_game_active = false
		1: is_game_active = true
		2: is_game_active = false

func _on_wave_changed(wave: int) -> void:
	current_wave = wave
	if wave_label: wave_label.text = "[WAVE %d/100]" % wave
	_tick_upgrade_effects_for_wave()

func _on_enemy_count_changed(count: int) -> void:
	alive_enemies_count = count

func _on_stage_time_changed(time_remaining: float) -> void:
	match_remaining_time = time_remaining
	if clock_label:
		var minutes: int = int(match_remaining_time) / 60
		var seconds: int = int(match_remaining_time) % 60
		clock_label.text = "%02d:%02d" % [minutes, seconds]

func _on_battle_victory() -> void:
	trigger_stage_clear_victory()

func _on_battle_defeat(_reason: String) -> void:
	trigger_system_overflow_failure()

func _on_upgrade_milestone_reached(wave: int) -> void:
	print("[MainGameScene] Upgrade milestone popup opening for wave %d" % wave)
	_show_upgrade_overlay(wave)

func _setup_upgrade_effect_system() -> void:
	if upgrade_effect_system:
		return
	upgrade_effect_system = UPGRADE_EFFECT_SYSTEM.new()
	add_child(upgrade_effect_system)

func _show_upgrade_overlay(wave: int) -> void:
	var battle_manager = get_node_or_null("/root/BattleManager")
	if battle_manager:
		battle_manager.pause_battle()

	if current_upgrade_overlay and is_instance_valid(current_upgrade_overlay):
		current_upgrade_overlay.queue_free()

	var overlay_scene = load("res://scenes/overlays/software_upgrade_overlay.tscn")
	if not overlay_scene:
		push_error("[MainGameScene] Failed to load upgrade overlay scene")
		if battle_manager:
			battle_manager.resume_battle()
		return

	current_upgrade_overlay = overlay_scene.instantiate()
	if current_upgrade_overlay:
		current_upgrade_overlay.upgrade_selected.connect(_on_upgrade_selected)
		current_upgrade_overlay.re_roll_requested.connect(_on_upgrade_reroll_requested)
		add_child(current_upgrade_overlay)

func _close_upgrade_overlay() -> void:
	if current_upgrade_overlay and is_instance_valid(current_upgrade_overlay):
		current_upgrade_overlay.queue_free()
		current_upgrade_overlay = null

	var battle_manager = get_node_or_null("/root/BattleManager")
	if battle_manager:
		battle_manager.resume_battle()

func _on_upgrade_selected(upgrade_type: String, value: float) -> void:
	print("[MainGameScene] Upgrade selected: %s (%.2f)" % [upgrade_type, value])
	_apply_upgrade_effect(upgrade_type, value)
	_close_upgrade_overlay()

func _on_upgrade_reroll_requested() -> void:
	print("[MainGameScene] Upgrade reroll requested")

func _apply_upgrade_effect(upgrade_type: String, value: float) -> void:
	var battle_manager = get_node_or_null("/root/BattleManager")	
	var effect_context = {
		"weapon_system": weapon_system,
		"mecha_instance": mecha_instance,
		"battle_manager": battle_manager
	}

	if upgrade_effect_system:
		upgrade_effect_system.apply_upgrade(upgrade_type, value, effect_context)
	else:
		print("[MainGameScene] Missing UpgradeEffectSystem to apply %s" % upgrade_type)

func _tick_upgrade_effects_for_wave() -> void:
	if upgrade_effect_system:
		upgrade_effect_system.tick_wave()

# --- Button Panel Connections ---
func _on_atk_spd_btn_pressed() -> void:
	var ss = get_node_or_null("/root/SaveSystem")
	if ss and ss.has_method("get_upgrade_level"):
		var current_level = ss.get_upgrade_level("ballistic_core", "chassis_calibrator_level")
		var new_level = min(current_level + 1, 10)
		ss.set_upgrade_level("ballistic_core", "chassis_calibrator_level", new_level)
		if weapon_system:
			weapon_system.set_attack_speed(2.5 + (new_level * 0.55))

func _on_pierce_btn_pressed() -> void:
	pierce_unlocked = true
	var ss = get_node_or_null("/root/SaveSystem")
	if ss and ss.has_method("set_upgrade_level"):
		ss.set_upgrade_level("ballistic_core", "piercing_barrel_level", 1)

func _on_cooldown_btn_pressed() -> void:
	# This button now controls multi-shot level instead of cooldown
	var ss = get_node_or_null("/root/SaveSystem")
	if ss and ss.has_method("get_upgrade_level"):
		var current_level = ss.get_upgrade_level("ballistic_core", "multi_shot_loader_level")
		var new_level = min(current_level + 1, 2)
		ss.set_upgrade_level("ballistic_core", "multi_shot_loader_level", new_level)
		if weapon_system:
			weapon_system.set_multi_shot_level(new_level)

func _on_overclock_btn_pressed() -> void:
	if is_overclock_active: return
	is_overclock_active = true
	if overclock_btn: overclock_btn.disabled = true
	print("🔥 SYSTEM OVERCLOCK RUNNING: Maximum performance output initiated.")
	var mecha = gameplay_arena.get_child(0) if gameplay_arena.get_child_count() > 0 else null
	if mecha and mecha.has_method("change_base_emotion"):
		mecha.change_base_emotion(13)
