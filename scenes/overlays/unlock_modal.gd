extends Control

# --- SIGNALS ---
signal equip_requested(mecha_id: String)
signal close_requested()

# --- NODES ---
@onready var title_label: Label = %TitleLabel
@onready var mecha_name_label: Label = %MechaNameLabel
@onready var attack_damage_label: Label = %AttackDamageLabel
@onready var attack_speed_label: Label = %AttackSpeedLabel
@onready var equip_button: Button = %EquipButton
@onready var close_button: Button = %CloseButton

var current_mecha_id: String = ""
var current_mecha_data: Dictionary = {}

func _ready() -> void:
	_connect_signals()
	hide()

func _connect_signals() -> void:
	if equip_button:
		equip_button.pressed.connect(_on_equip_pressed)
	if close_button:
		close_button.pressed.connect(_on_close_pressed)

func show_unlock(mecha_id: String, mecha_data: Dictionary) -> void:
	current_mecha_id = mecha_id
	current_mecha_data = mecha_data
	
	# Update UI with mecha info
	if mecha_name_label:
		mecha_name_label.text = mecha_data.get("display_name", "Unknown Mecha")
	
	if attack_damage_label:
		var damage = mecha_data.get("base_attack_damage", 10)
		attack_damage_label.text = "ATK: %d" % damage
	
	if attack_speed_label:
		var speed = mecha_data.get("base_attack_speed", 2.5)
		attack_speed_label.text = "SPD: %.1f" % speed
	
	show()

func _on_equip_pressed() -> void:
	if not current_mecha_id.is_empty():
		equip_requested.emit(current_mecha_id)
		hide()

func _on_close_pressed() -> void:
	close_requested.emit()
	hide()
