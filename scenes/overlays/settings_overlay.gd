extends Control

signal resume_requested()

@onready var resume_button: Button = %ResumeButton
@onready var reset_button: Button = %ResetButton
@onready var telemetry_button: Button = %TelemetryButton
@onready var target_option_button: OptionButton = %TargetOptionButton

var telemetry_scene: PackedScene = preload("res://scenes/overlays/telemetry_overlay.tscn")

const TARGET_PRIORITY_KEY = "settings_target_priority"

enum TargetPriority { NEAREST = 0, LOWEST_HP = 1, STRONGEST = 2 }

func _ready() -> void:
	if resume_button:
		resume_button.pressed.connect(_on_resume_pressed)
	if reset_button:
		reset_button.pressed.connect(_on_reset_pressed)
	if telemetry_button:
		telemetry_button.pressed.connect(_on_telemetry_pressed)
	if target_option_button:
		target_option_button.item_selected.connect(_on_target_priority_changed)
		_load_target_priority()

func _on_resume_pressed() -> void:
	resume_requested.emit()
	queue_free()

func _on_telemetry_pressed() -> void:
	var overlay = telemetry_scene.instantiate()
	var canvas = get_node_or_null("/root").get_child(get_node_or_null("/root").get_child_count()-1).get_node_or_null("CanvasLayer")
	if canvas:
		canvas.add_child(overlay)
	else:
		add_child(overlay)

func _on_reset_pressed() -> void:
	var save_system = get_node_or_null("/root/SaveSystem")
	if save_system and save_system.has_method("reset_progress"):
		save_system.reset_progress()
	
	# Reload the main scene to apply the reset
	get_tree().reload_current_scene()

func _on_target_priority_changed(index: int) -> void:
	var save_system = get_node_or_null("/root/SaveSystem")
	if save_system:
		save_system.set_value(TARGET_PRIORITY_KEY, index)
	print("[SettingsOverlay] Target priority changed to: ", index)

func _load_target_priority() -> void:
	var save_system = get_node_or_null("/root/SaveSystem")
	if save_system and save_system.has_method("get_value"):
		var saved_index = save_system.get_value(TARGET_PRIORITY_KEY, 0)
		if target_option_button and saved_index >= 0 and saved_index < target_option_button.item_count:
			target_option_button.selected = saved_index
			print("[SettingsOverlay] Loaded target priority: ", saved_index)
