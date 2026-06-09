extends Control

# --- Mid-Run Powerup Button Mappings ---
@onready var atk_spd_btn: Button = %AtkSpdBtn
@onready var pierce_btn: Button = %PierceBtn
@onready var cooldown_btn: Button = %CooldownBtn
@onready var move_spd_btn: Button = %MoveSpdBtn
@onready var matrix_btn: Button = %MatrixBtn
@onready var overclock_btn: Button = %OverclockBtn

# --- Footer Button Mappings ---
@onready var shop_btn: Button = %ShopButton
@onready var hangar_btn: Button = %HangarButton
@onready var upgrades_btn: Button = %UpgradesButton
@onready var battle_pass_btn: Button = %BattlePassButton
@onready var leaderboard_btn: Button = %LeaderboardButton

# --- Scene Unique Node Mappings ---
@onready var alive_counter_label: Label = %AliveCounterLabel
@onready var clock_label: Label = %ClockLabel
@onready var wave_label: Label = %WaveLabel
@onready var stage_label: Label = %StageLabel
@onready var gameplay_arena: Node2D = %GameplayArena
@onready var battery_progress: ProgressBar = %BatteryProgress
@onready var settings_button: Button = %SettingsButton
@onready var player_icon_btn: Button = %PlayerIconButton
@onready var player_name_label: Label = %PlayerNameLabel
@onready var gold_label: Label = %GoldLabel
@onready var diamond_label: Label = %DiamondLabel

const UPGRADE_EFFECT_SYSTEM := preload("res://systems/upgrade_effect_system.gd")

# --- Timers and Combat Handles ---
var weapon_system: Node2D = null
var spawner_node: Node2D = null
var mecha_instance: Node2D = null
var battery_update_timer: Timer
var upgrade_effect_system: UpgradeEffectSystem = null
var current_upgrade_overlay: SoftwareUpgradeOverlay = null
var current_game_over_overlay: GameOverOverlay = null
var settings_overlay_scene: PackedScene = preload("res://scenes/overlays/settings_overlay.tscn")
var player_info_scene: PackedScene = preload("res://scenes/overlays/player_info_overlay.tscn")

# --- Live Stats Modifiers ---
var multi_shot_level: int = 0
var pierce_unlocked: bool = true 
var is_overclock_active: bool = false

# --- Core Matrix Parameters ---
var alive_enemies_count: int = 0:
	set(value):
		alive_enemies_count = value
		_update_ui()
		if alive_enemies_count >= 50 and is_game_active:
			trigger_system_overflow_failure()

var current_stage: int = 11
var current_wave: int = 11
var match_remaining_time: float = 292.0
var is_game_active: bool = false

func _ready() -> void:
	_setup_enemy_spawner()
	_setup_scene_timers()
	_connect_autoload_signals()
	_load_initial_upgrades()
	
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
	if player_icon_btn:
		player_icon_btn.pressed.connect(_on_player_icon_pressed)
		
	_connect_ui_buttons()
	_update_header_resources()
	_start_current_game_session()

func _update_header_resources() -> void:
	var save_system = get_node_or_null("/root/SaveSystem")
	if save_system:
		if gold_label: gold_label.text = "💰 " + str(save_system.get_tech_credits())
		if diamond_label: diamond_label.text = "💎 0" # Or pull premium currency if implemented

func _connect_ui_buttons() -> void:
	if atk_spd_btn: atk_spd_btn.pressed.connect(_on_software_powerup_pressed)
	if pierce_btn: pierce_btn.pressed.connect(_on_software_powerup_pressed)
	if cooldown_btn: cooldown_btn.pressed.connect(_on_software_powerup_pressed)
	if move_spd_btn: move_spd_btn.pressed.connect(_on_software_powerup_pressed)
	if matrix_btn: matrix_btn.pressed.connect(_on_software_powerup_pressed)
	if overclock_btn: overclock_btn.pressed.connect(_on_software_powerup_pressed)
	
	if shop_btn: shop_btn.pressed.connect(_on_footer_btn_pressed.bind("res://scenes/screens/shop_screen.tscn"))
	if hangar_btn: hangar_btn.pressed.connect(_on_footer_btn_pressed.bind("res://scenes/screens/hangar_screen.tscn"))
	if upgrades_btn: upgrades_btn.pressed.connect(_on_footer_btn_pressed.bind("res://scenes/screens/upgrades_screen.tscn"))
	if battle_pass_btn: battle_pass_btn.pressed.connect(_on_footer_btn_pressed.bind("res://scenes/screens/battle_pass_screen.tscn"))
	if leaderboard_btn: leaderboard_btn.pressed.connect(_on_footer_btn_pressed.bind("res://scenes/screens/leaderboard_screen.tscn"))

func _on_software_powerup_pressed() -> void:
	_show_upgrade_overlay(current_wave)

func _on_footer_btn_pressed(scene_path: String) -> void:
	if ResourceLoader.exists(scene_path):
		get_tree().change_scene_to_file(scene_path)
	else:
		push_warning("Scene not found: " + scene_path)

func _setup_enemy_spawner() -> void:
	spawner_node = get_node_or_null("EnemySpawner")
	if not spawner_node:
		print("🚀 EnemySpawner node not found in scene tree. Creating dynamically...")
		spawner_node = Node2D.new()
		spawner_node.name = "EnemySpawner"
		var spawner_script = load("res://scenes/screens/main_gundam/enemy_spawner.gd")
		if spawner_script:
			spawner_node.set_script(spawner_script)
		spawner_node.set("enemy_scene", load("res://systems/enemy_unit.tscn"))
		add_child(spawner_node)
		
		# Register spawner with BattleManager
		var bm = get_node_or_null("/root/BattleManager")
		if bm:
			bm.set("custom_spawner", spawner_node)
	
	# Inject direct references so the spawner never needs fragile node path lookups
	if spawner_node:
		await get_tree().process_frame  # Let _ready() run on spawner first
		var square_path = gameplay_arena.get_node_or_null("SquarePath") if gameplay_arena else null
		if square_path and "square_path_node" in spawner_node:
			spawner_node.square_path_node = square_path
			print("✅ [EnemySpawner] square_path_node injected: ", square_path.get_path())
		else:
			print("⚠ [EnemySpawner] SquarePath not found in GameplayArena!")
		if "gameplay_arena_node" in spawner_node:
			spawner_node.gameplay_arena_node = gameplay_arena

func _setup_scene_timers() -> void:
	# Instantiate WeaponSystem component
	var weapon_scene = load("res://systems/weapon_system.tscn")
	if weapon_scene:
		weapon_system = weapon_scene.instantiate()
		add_child(weapon_system)
		if weapon_system.has_signal("enemy_shot_fired"):
			weapon_system.enemy_shot_fired.connect(_on_enemy_shot_fired)
		
		# Create MechaEntity and connect weapon system so JSON stats flow through
		var mecha_entity_script = load("res://systems/mecha_entity.gd")
		if mecha_entity_script:
			mecha_instance = Node2D.new()
			mecha_instance.name = "MechaEntity"
			mecha_instance.set_script(mecha_entity_script)
			mecha_instance.weapon_system = weapon_system
			add_child(mecha_instance)
			# _ready() on mecha_entity will call _load_mecha_stats() which sets weapon_system speed
			print("[MainGameScene] ✅ MechaEntity created & weapon_system connected | atk_speed=", weapon_system.attack_speed)
		else:
			# Fallback: manually set attack speed from JSON
			print("[MainGameScene] ⚠ mecha_entity.gd not found, setting weapon speed from ProgressionManager directly")
			var pm = get_node_or_null("/root/ProgressionManager")
			if pm:
				var stats = pm.get_active_mecha_stats()
				var base_stats = stats.get("base_stats", {})
				weapon_system.set_attack_speed(base_stats.get("attack_speed", 1.0))
				weapon_system.set_base_damage(base_stats.get("attack_damage", 10.0))
	else:
		push_error("[MainGameScene] Failed to load WeaponSystem scene")
	
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
		bm.wave_skipped.connect(_on_wave_skipped)

func _load_initial_upgrades() -> void:
	var ss = get_node_or_null("/root/SaveSystem")
	if ss and ss.has_method("get_upgrade_level"):
		multi_shot_level = ss.get_upgrade_level("ballistic_core", "multi_shot_loader_level")
		var pierce_upgrade = ss.get_upgrade_level("ballistic_core", "piercing_barrel_level")
		
		if weapon_system:
			weapon_system.set_multi_shot_level(multi_shot_level)
			# Attack speed is now driven by mecha_entity._load_mecha_stats() from JSON
			if pierce_upgrade > 0:
				pierce_unlocked = true

func _start_current_game_session() -> void:
	is_game_active = true
	var pm = get_node_or_null("/root/ProgressionManager")
	if pm and "current_player_stage" in pm:
		current_stage = pm.current_player_stage
	
	# Load saved wave
	var save_sys = get_node_or_null("/root/SaveSystem")
	if save_sys and save_sys.has_method("get_current_wave"):
		current_wave = save_sys.get_current_wave()
		
	# Update header labels with real values
	if stage_label:
		stage_label.text = "STAGE %d" % current_stage
	if wave_label:
		wave_label.text = "[WAVE %d/100]" % current_wave
	if clock_label:
		var minutes: int = int(match_remaining_time) / 60
		var seconds: int = int(match_remaining_time) % 60
		clock_label.text = "DEATH IN %02d:%02d" % [minutes, seconds]
		if match_remaining_time <= 30.0:
			clock_label.modulate = Color.RED
		else:
			clock_label.modulate = Color.WHITE
	if alive_counter_label:
		alive_counter_label.text = "%d / 50" % alive_enemies_count
		
	var bm = get_node_or_null("/root/BattleManager")
	if bm and bm.has_method("start_battle"):
		bm.start_battle(current_stage, current_wave)
		
	_instantiate_active_mecha()
	
	# Setup upgrade effect system and restore saved effects
	_setup_upgrade_effect_system()
	
	if is_instance_valid(weapon_system): weapon_system.update_weapon_speed()
	if is_instance_valid(battery_update_timer): battery_update_timer.start()

func _instantiate_active_mecha() -> void:
	if not gameplay_arena: 
		push_error("[MainGameScene] GameplayArena not found!")
		return
	for child in gameplay_arena.get_children():
		# Preserve SquarePath so the enemy spawner keeps its path reference
		if child.name == "SquarePath":
			continue
		child.queue_free()
		
	var target_mecha_path = "res://scenes/screens/gundam/gundam.tscn"
	if ResourceLoader.exists(target_mecha_path):
		var mecha_scene = load(target_mecha_path)
		mecha_instance = mecha_scene.instantiate()
		
		# Validate mecha transform before adding
		if mecha_instance.scale == Vector2.ZERO:
			push_error("[MainGameScene] Mecha has zero scale! Setting to (1,1)")
			mecha_instance.scale = Vector2.ONE
		
		mecha_instance.add_to_group("player") # Explicit group mapping for dynamic tracking scripts
		gameplay_arena.add_child(mecha_instance)
		
		# Connect missile fired signal
		if mecha_instance.has_signal("missile_fired"):
			mecha_instance.missile_fired.connect(_on_missile_fired)
		
		await get_tree().process_frame
		if is_instance_valid(mecha_instance) and mecha_instance.has_method("change_base_emotion"):
			mecha_instance.change_base_emotion(18)
	else:
		push_error("[MainGameScene] Mecha scene not found at: ", target_mecha_path) 

func _update_ui() -> void:
	if alive_counter_label:
		alive_counter_label.text = "%d / 50" % alive_enemies_count

func _update_battery_ui() -> void:
	if battery_progress and is_instance_valid(mecha_instance) and mecha_instance.has_method("get_missile_cooldown_percent"):
		var cooldown_percent = mecha_instance.get_missile_cooldown_percent()
		battery_progress.value = cooldown_percent * 100.0

func _on_enemy_shot_fired(projectile_data: Dictionary) -> void:
	if not is_game_active: return
	
	var target_node = projectile_data.get("target_node", null)
	var target_position = projectile_data.get("target_position", Vector2.ZERO)
	var damage = projectile_data.get("damage", 10.0)
	var bullet_index = projectile_data.get("bullet_index", 0)
	var piercing_level = projectile_data.get("piercing_level", 0)
	
	# Spawn visual projectile
	_spawn_bullet_projectile(target_node, target_position, damage, bullet_index, piercing_level)

func _spawn_bullet_projectile(target_node: Node2D, target_position: Vector2, damage: float, bullet_index: int, piercing_level: int = 0) -> void:
	var bullet_scene = load("res://systems/bullet_projectile.tscn")
	if not bullet_scene:
		push_error("[MainGameScene] Failed to load bullet_projectile.tscn")
		return
	
	var bullet = bullet_scene.instantiate()
	# Runtime safeguard: some builds returned a plain Area2D without the script attached.
	# If `initialize` is missing, attempt to attach the script resource then continue.
	if not bullet.has_method("initialize"):
		var bullet_script = load("res://systems/bullet_projectile.gd")
		if bullet_script:
			bullet.set_script(bullet_script)
		else:
			push_error("[MainGameScene] Failed to load bullet script for runtime attach")

	if not bullet.has_method("initialize"):
		push_error("[MainGameScene] Bullet instance missing 'initialize' method; aborting spawn")
		return
	
	# Get spawn position from mecha
	var spawn_position = Vector2.ZERO
	if is_instance_valid(mecha_instance):
		spawn_position = mecha_instance.global_position
	else:
		# Fallback to center of arena
		spawn_position = gameplay_arena.global_position if gameplay_arena else Vector2(540, 960)
	
	# Use the target node passed from weapon system (already validated)
	bullet.initialize(spawn_position, target_node, damage)
	
	# Inject piercing level so the bullet handles pierce-through on impact
	if piercing_level > 0:
		bullet.piercing_level = piercing_level
	
	# Add to gameplay arena
	if gameplay_arena:
		gameplay_arena.add_child(bullet)
	else:
		add_child(bullet) 

func _on_missile_fired(targets: Array, damage_per_rocket: float) -> void:
	if not is_game_active: return
	print("🚀 [MISSILE IMPACT] ", targets.size(), " missiles dealing ", damage_per_rocket, " damage each")
	
	# Spawn visual missile projectiles for each target
	for target in targets:
		if is_instance_valid(target):
			_spawn_missile_projectile(target, damage_per_rocket)

func _spawn_missile_projectile(target_node: Node2D, damage: float) -> void:
	var bullet_scene = load("res://systems/bullet_projectile.tscn")
	if not bullet_scene:
		return
	
	var missile = bullet_scene.instantiate()
	if not missile.has_method("initialize"):
		var bullet_script = load("res://systems/bullet_projectile.gd")
		if bullet_script:
			missile.set_script(bullet_script)
		else:
			return
	
	if not missile.has_method("initialize"):
		return
	
	# Missile visual: larger, red-orange color
	var visual = missile.get_node_or_null("Visual")
	if visual and visual is ColorRect:
		visual.color = Color(1.0, 0.25, 0.1, 1.0)  # Red-orange for missiles
		visual.size = Vector2(12, 12)
		visual.position = Vector2(-6, -6)
	
	# Spawn from mecha position
	var spawn_position = Vector2.ZERO
	if is_instance_valid(mecha_instance):
		spawn_position = mecha_instance.global_position
	else:
		spawn_position = gameplay_arena.global_position if gameplay_arena else Vector2(540, 960)
	
	# Don't apply damage again - gundam.gd already does take_damage in _fire_homing_missiles
	missile.initialize(spawn_position, target_node, 0.0)
	
	if gameplay_arena:
		gameplay_arena.add_child(missile)
	else:
		add_child(missile)


func open_popup_view(menu_type: String) -> void:
	print("Instantiating overlay view container sector: ", menu_type.to_upper())

func trigger_system_overflow_failure(reason: String = "Stage Overflow") -> void:
	if not is_game_active:
		return  # Already triggered, prevent re-entry
	is_game_active = false
	
	# Stop weapon system
	if is_instance_valid(weapon_system) and weapon_system.fire_timer:
		weapon_system.fire_timer.stop()
	
	# Stop battery update timer
	if is_instance_valid(battery_update_timer):
		battery_update_timer.stop()
	
	# Stop mecha missile system
	if is_instance_valid(mecha_instance) and "missile_cooldown_timer" in mecha_instance:
		if mecha_instance.missile_cooldown_timer:
			mecha_instance.missile_cooldown_timer.stop()
	
	# Stop BattleManager timers
	var bm = get_node_or_null("/root/BattleManager")
	if bm:
		if bm.has_method("end_battle"):
			bm.end_battle(reason)
		else:
			# Manually stop timers if end_battle not available
			if "_spawn_timer" in bm and bm._spawn_timer:
				bm._spawn_timer.stop()
			if "_stage_timer" in bm and bm._stage_timer:
				bm._stage_timer.stop()
	
	print("💥 DEFEAT: ", reason)
	var mecha = gameplay_arena.get_child(0) if gameplay_arena.get_child_count() > 0 else null
	if mecha and mecha.has_method("change_base_emotion"):
		mecha.change_base_emotion(20)
	
	var overlay_text = "STAGE OVERFLOW FAILURE\n50/50 enemies reached — combat zone breached."
	if reason == "Time Expired":
		overlay_text = "TIME EXPIRED\nStage maximum time limit (5:00) reached without defeating the boss."
	
	# Show game over overlay
	_show_game_over_overlay(overlay_text)

func trigger_stage_clear_victory() -> void:
	is_game_active = false
	if is_instance_valid(weapon_system): weapon_system.fire_timer.stop()
	if is_instance_valid(battery_update_timer): battery_update_timer.stop()
	
	print("🏆 STAGE CLEAR VICTORY: Operational sector stabilized.")
	var mecha = gameplay_arena.get_child(0) if gameplay_arena.get_child_count() > 0 else null
	if mecha and mecha.has_method("change_base_emotion"):
		mecha.change_base_emotion(19)
	
	# Reset wave for next stage - keep active software effects!
	var save_sys = get_node_or_null("/root/SaveSystem")
	if save_sys and save_sys.has_method("set_current_wave"):
		save_sys.set_current_wave(1)
	
	# After a short delay, go back to main menu
	await get_tree().create_timer(2.0).timeout
	var game_state = get_node_or_null("/root/GameState")
	if game_state:
		game_state.transition_to_screen(game_state.Screen.MENU)

# --- BattleManager Signal Handlers ---
func _on_battle_state_changed(new_state: int) -> void:
	match new_state:
		0: is_game_active = false
		1: is_game_active = true
		2: is_game_active = false

func _on_wave_changed(wave: int) -> void:
	current_wave = wave
	if wave_label: wave_label.text = "[WAVE %d/100]" % wave
	if stage_label: stage_label.text = "STAGE %d" % current_stage
	_tick_upgrade_effects_for_wave()
	
	# Save current wave
	var save_sys = get_node_or_null("/root/SaveSystem")
	if save_sys and save_sys.has_method("set_current_wave"):
		save_sys.set_current_wave(wave)

func _on_enemy_count_changed(count: int) -> void:
	alive_enemies_count = count

func _on_stage_time_changed(time_remaining: float) -> void:
	match_remaining_time = time_remaining
	if clock_label:
		var bm = get_node_or_null("/root/BattleManager")
		var boss_spawned = false
		if bm and "boss_spawned" in bm:
			boss_spawned = bm.boss_spawned
		
		if not boss_spawned:
			clock_label.visible = false
			return
		
		clock_label.visible = true
		var minutes: int = int(match_remaining_time) / 60
		var seconds: int = int(match_remaining_time) % 60
		clock_label.text = "DEATH IN %02d:%02d" % [minutes, seconds]
		if match_remaining_time <= 30.0:
			clock_label.modulate = Color.RED
		else:
			clock_label.modulate = Color.WHITE

func _on_battle_victory() -> void:
	trigger_stage_clear_victory()

func _on_battle_defeat(reason: String) -> void:
	trigger_system_overflow_failure(reason)

func _on_upgrade_milestone_reached(wave: int) -> void:
	print("[MainGameScene] Upgrade milestone popup opening for wave %d" % wave)
	_show_upgrade_overlay(wave)

func _on_wave_skipped(target_wave: int, multiplier: float) -> void:
	print("🚀 [SYSTEM RAPID CLEANUP] Wave skip triggered! Jumped to wave ", target_wave)
	
	var notif = Label.new()
	notif.text = "[SYSTEM RAPID CLEANUP] +%d WAVES" % int(multiplier)
	notif.add_theme_color_override("font_color", Color(0.2, 1.0, 1.0))
	notif.add_theme_font_size_override("font_size", 28)
	
	# Center horizontally and position slightly above center
	notif.position = Vector2(100, 350)
	
	if gameplay_arena:
		gameplay_arena.add_child(notif)
	else:
		add_child(notif)
	
	var tween = create_tween()
	tween.tween_property(notif, "position", Vector2(100, 200), 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(notif, "modulate:a", 0.0, 2.0)
	tween.tween_callback(notif.queue_free)

func _setup_upgrade_effect_system() -> void:
	if not upgrade_effect_system:
		upgrade_effect_system = UPGRADE_EFFECT_SYSTEM.new()
		add_child(upgrade_effect_system)
	
	# Always set context and restore saved effects whenever setup is called!
	var save_sys = get_node_or_null("/root/SaveSystem")
	var battle_manager = get_node_or_null("/root/BattleManager")
	var effect_context = {
		"weapon_system": weapon_system,
		"mecha_instance": mecha_instance,
		"battle_manager": battle_manager
	}
	
	if save_sys and save_sys.has_method("get_active_software_effects"):
		var saved_effects = save_sys.get_active_software_effects()
		if saved_effects.size() > 0:
			print("[MainGameScene] Restoring ", saved_effects.size(), " saved software effects!")
			upgrade_effect_system.restore_effects_from_save(saved_effects, effect_context)
		else:
			upgrade_effect_system.set_context(effect_context)
	else:
		upgrade_effect_system.set_context(effect_context)

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
		
		var canvas = get_node_or_null("CanvasLayer")
		if canvas:
			canvas.add_child(current_upgrade_overlay)
		else:
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
		# Reload mecha stats from JSON to recalculate with new upgrade level
		if mecha_instance and mecha_instance.has_method("_load_mecha_stats"):
			mecha_instance._load_mecha_stats()

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

func _process(delta: float) -> void:
	if not is_game_active: 
		return

	# Explicit check to stop code execution if time expires out
	if match_remaining_time <= 0:
		return

	# If all enemies have been killed and spawner has completed its waves
	# But don't trigger victory if boss is still active!
	var bm = get_node_or_null("/root/BattleManager")
	var boss_active = false
	if bm and "boss_active" in bm:
		boss_active = bm.boss_active
	if alive_enemies_count <= 0 and _all_waves_spawned_completely() and not boss_active:
		trigger_stage_clear_victory()

# Helper validation if tracking total wave progress locally
func _all_waves_spawned_completely() -> bool:
	# Replace with your wave condition layout if applicable (e.g. current_wave >= total_waves)
	return current_wave >= 100

# --- Game Over Overlay ---
func _show_game_over_overlay(reason: String) -> void:
	# Prevent duplicate overlays
	if current_game_over_overlay and is_instance_valid(current_game_over_overlay):
		return
	
	var overlay_scene = load("res://scenes/overlays/game_over_overlay.tscn")
	if not overlay_scene:
		push_error("[MainGameScene] Failed to load game over overlay scene")
		return
	
	current_game_over_overlay = overlay_scene.instantiate()
	if current_game_over_overlay:
		# Connect signals before add_child so they're ready after _ready()
		current_game_over_overlay.retry_requested.connect(_on_game_over_retry)
		current_game_over_overlay.quit_requested.connect(_on_game_over_quit)
		# Store data before adding to tree - overlay will read in _ready()
		var time_elapsed = 300.0 - match_remaining_time
		current_game_over_overlay.defeat_reason = reason
		current_game_over_overlay.final_wave = current_wave
		current_game_over_overlay.final_enemy_count = alive_enemies_count
		current_game_over_overlay.elapsed_time = time_elapsed
		
		var canvas = get_node_or_null("CanvasLayer")
		if canvas:
			canvas.add_child(current_game_over_overlay)
		else:
			add_child(current_game_over_overlay)

func _close_game_over_overlay() -> void:
	if current_game_over_overlay and is_instance_valid(current_game_over_overlay):
		current_game_over_overlay.queue_free()
		current_game_over_overlay = null

func _on_game_over_retry() -> void:
	_close_game_over_overlay()
	get_tree().reload_current_scene()

func _on_game_over_quit() -> void:
	_close_game_over_overlay()
	# Return to main menu or quit
	var main_menu_path = "res://scenes/screens/main_menu.tscn"
	if ResourceLoader.exists(main_menu_path):
		get_tree().change_scene_to_file(main_menu_path)
	else:
		get_tree().reload_current_scene()

func _on_player_icon_pressed() -> void:
	var battle_manager = get_node_or_null("/root/BattleManager")
	if battle_manager:
		battle_manager.pause_battle()
	
	var overlay = player_info_scene.instantiate()
	overlay.resume_requested.connect(_on_settings_resume) # Re-use the resume logic
	
	var canvas = get_node_or_null("CanvasLayer")
	if canvas:
		canvas.add_child(overlay)
	else:
		add_child(overlay)

func _on_settings_pressed() -> void:
	var battle_manager = get_node_or_null("/root/BattleManager")
	if battle_manager:
		battle_manager.pause_battle()
	
	var overlay = settings_overlay_scene.instantiate()
	overlay.resume_requested.connect(_on_settings_resume)
	
	var canvas = get_node_or_null("CanvasLayer")
	if canvas:
		canvas.add_child(overlay)
	else:
		add_child(overlay)

func _on_settings_resume() -> void:
	var battle_manager = get_node_or_null("/root/BattleManager")
	if battle_manager:
		battle_manager.resume_battle()
