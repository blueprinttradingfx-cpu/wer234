extends Control

signal resume_requested()

@onready var resume_button: Button = %ResumeButton
@onready var reset_button: Button = %ResetButton
@onready var telemetry_button: Button = %TelemetryButton

var telemetry_scene: PackedScene = preload("res://scenes/overlays/telemetry_overlay.tscn")

func _ready() -> void:
	if resume_button:
		resume_button.pressed.connect(_on_resume_pressed)
	if reset_button:
		reset_button.pressed.connect(_on_reset_pressed)
	if telemetry_button:
		telemetry_button.pressed.connect(_on_telemetry_pressed)

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
