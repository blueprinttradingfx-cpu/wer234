extends Control
class_name HangarScreen

signal mecha_selected(mecha_id: String)

@onready var back_button: Button = %BackButton
@onready var mecha_grid: GridContainer = %MechaGrid

var progression_manager = null
var game_state = null
var save_system = null
var available_mechas: Array = []
var active_mecha_id: String = ""

func _ready() -> void:
	progression_manager = get_node_or_null("/root/ProgressionManager")
	game_state = get_node_or_null("/root/GameState")
	save_system = get_node_or_null("/root/SaveSystem")
	
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
		
	_load_mechas()

func _load_mechas() -> void:
	if not progression_manager:
		return
	
	available_mechas = progression_manager.get_available_mechas()
	active_mecha_id = progression_manager.get_active_mecha_id()
	
	for child in mecha_grid.get_children():
		child.queue_free()
	
	for mecha_data in available_mechas:
		_create_mecha_card(mecha_data)

func _create_mecha_card(mecha_data: Dictionary) -> void:
	var card_panel = PanelContainer.new()
	card_panel.custom_minimum_size = Vector2(240, 320)
	
	var vbox = VBoxContainer.new()
	card_panel.add_child(vbox)
	
	# Name display
	var name_label = Label.new()
	name_label.text = str(mecha_data.get("name", "Unknown Unit"))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)
	
	# Select / Equip Button Logic
	var mecha_id = mecha_data.get("mecha_id", "")
	var is_unlocked = progression_manager.is_mecha_unlocked(mecha_id)
	var is_active = (mecha_id == active_mecha_id)
	
	var select_button = Button.new()
	if is_active:
		select_button.text = "✓ ACTIVE"
		select_button.disabled = true
	elif is_unlocked:
		select_button.text = "SELECT"
		select_button.pressed.connect(_on_mecha_selected.bind(mecha_id))
	else:
		var unlock_req = mecha_data.get("unlock_requirement", {})
		select_button.text = "LOCKED (Stage %d)" % unlock_req.get("value", 0)
		select_button.disabled = true
		
	vbox.add_child(select_button)
	mecha_grid.add_child(card_panel)

func _on_mecha_selected(mecha_id: String) -> void:
	if progression_manager:
		progression_manager.set_active_mecha(mecha_id)
	if save_system and save_system.has_method("set_active_mecha"):
		save_system.set_active_mecha(mecha_id)
		
	mecha_selected.emit(mecha_id)
	_load_mechas() # Refresh display states instantly

func _on_back_pressed() -> void:
	if game_state:
		game_state.transition_to_screen(game_state.Screen.MENU)