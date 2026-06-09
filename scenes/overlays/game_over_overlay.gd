extends Control
class_name GameOverOverlay

signal retry_requested()
signal quit_requested()

@onready var title_label: Label = $PanelContainer/VBoxContainer/TitleLabel
@onready var subtitle_label: Label = $PanelContainer/VBoxContainer/SubtitleLabel
@onready var stats_label: Label = $PanelContainer/VBoxContainer/StatsLabel
@onready var retry_button: Button = $PanelContainer/VBoxContainer/ButtonContainer/RetryButton
@onready var quit_button: Button = $PanelContainer/VBoxContainer/ButtonContainer/QuitButton

var defeat_reason: String = "STAGE OVERFLOW FAILURE"
var final_wave: int = 0
var final_enemy_count: int = 0
var elapsed_time: float = 0.0

# Countdown
var countdown_seconds: int = 5
var countdown_timer: Timer = null

func _ready() -> void:
	_connect_signals()
	_update_display()
	_animate_entrance()
	_start_retry_countdown()

func _connect_signals() -> void:
	if retry_button:
		retry_button.pressed.connect(_on_retry_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)

func _update_display() -> void:
	if title_label:
		title_label.text = "⚠ SYSTEM FAILURE"
	if subtitle_label:
		subtitle_label.text = defeat_reason
	if stats_label:
		var minutes: int = int(elapsed_time) / 60
		var seconds: int = int(elapsed_time) % 60
		stats_label.text = "Wave Reached: %d\nEnemies On Field: %d / 50\nTime Survived: %02d:%02d" % [final_wave, final_enemy_count, minutes, seconds]

func _start_retry_countdown() -> void:
	countdown_seconds = 5
	_update_retry_button_text()
	
	countdown_timer = Timer.new()
	countdown_timer.wait_time = 1.0
	countdown_timer.timeout.connect(_on_countdown_tick)
	add_child(countdown_timer)
	countdown_timer.start()

func _on_countdown_tick() -> void:
	countdown_seconds -= 1
	_update_retry_button_text()
	
	if countdown_seconds <= 0:
		countdown_timer.stop()
		_on_retry_pressed()

func _update_retry_button_text() -> void:
	if retry_button:
		retry_button.text = "🔄 RETRY (%d)" % countdown_seconds

func _animate_entrance() -> void:
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5).set_ease(Tween.EASE_OUT)
	
	var panel = get_node_or_null("PanelContainer")
	if panel:
		panel.scale = Vector2(0.8, 0.8)
		panel.pivot_offset = panel.size / 2.0
		var panel_tween = create_tween()
		panel_tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _on_retry_pressed() -> void:
	# Stop countdown to prevent double-fire
	if countdown_timer and countdown_timer.is_inside_tree():
		countdown_timer.stop()
	retry_requested.emit()

func _on_quit_pressed() -> void:
	if countdown_timer and countdown_timer.is_inside_tree():
		countdown_timer.stop()
	quit_requested.emit()
