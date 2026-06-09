extends Control

signal close_requested()

@onready var close_button: Button = %CloseButton
@onready var fps_label: Label = %FpsLabel
@onready var mem_label: Label = %MemLabel
@onready var entities_label: Label = %EntitiesLabel
@onready var wave_phase_label: Label = %WavePhaseLabel
@onready var current_time_label: Label = %CurrentTimeLabel

func _ready() -> void:
	if close_button:
		close_button.pressed.connect(_on_close_pressed)

func _process(_delta: float) -> void:
	if not is_visible_in_tree():
		return
		
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
	mem_label.text = "Memory: " + str(OS.get_static_memory_usage() / 1024 / 1024) + " MB"
	
	var main_scene = get_tree().current_scene
	if main_scene:
		if "alive_enemies_count" in main_scene:
			entities_label.text = "Active Enemies: " + str(main_scene.alive_enemies_count)
		
		var bm = get_node_or_null("/root/BattleManager")
		if bm:
			wave_phase_label.text = "Wave Phase: " + str(bm.get("current_archetype_theme"))
			current_time_label.text = "Battle Time: " + str(round(bm.get("battle_timer") if bm.get("battle_timer") else 0)) + "s"

func _on_close_pressed() -> void:
	close_requested.emit()
	queue_free()
