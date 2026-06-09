extends Control

signal resume_requested()

@onready var resume_button: Button = %ResumeButton
@onready var reset_button: Button = %ResetButton

func _ready() -> void:
	if resume_button:
		resume_button.pressed.connect(_on_resume_pressed)
	if reset_button:
		reset_button.pressed.connect(_on_reset_pressed)

func _on_resume_pressed() -> void:
	resume_requested.emit()
	queue_free()

func _on_reset_pressed() -> void:
	var save_system = get_node_or_null("/root/SaveSystem")
	if save_system and save_system.has_method("reset_progress"):
		save_system.reset_progress()
	
	# Reload the main scene to apply the reset
	get_tree().reload_current_scene()
