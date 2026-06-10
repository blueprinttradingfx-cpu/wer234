extends Control

@onready var back_button: Button = %BackButton
@onready var close_button: Button = %CloseButton
@onready var leaderboard_list: VBoxContainer = %LeaderboardList

@onready var my_rank_label: Label = %MyRankLabel
@onready var my_name_label: Label = %MyNameLabel
@onready var my_score_label: Label = %MyScoreLabel

# Mock database of global mock server ranking scores
var global_rankings: Array = [
	{"rank": 1, "name": "Rx-78_Amuro", "score": "Stage 45", "is_top": true},
	{"rank": 2, "name": "Char_Custom", "score": "Stage 42", "is_top": true},
	{"rank": 3, "name": "Zaku_Master", "score": "Stage 39", "is_top": true},
	{"rank": 4, "name": "GundamWing_99", "score": "Stage 31", "is_top": false},
	{"rank": 5, "name": "MechaPilot_X", "score": "Stage 28", "is_top": false},
	{"rank": 6, "name": "Aegis_Striker", "score": "Stage 22", "is_top": false}
]
# Add a variable to track if this menu was opened from inside a running game
var is_overlay: bool = false

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	close_button.pressed.connect(_on_back_pressed)
	
	_update_local_player_rank()
	_populate_leaderboard_rows()

func _update_local_player_rank() -> void:
	# Safely update local user placement score cards from SaveSystem cache info
	var ss = get_node_or_null("/root/SaveSystem")
	if ss:
		var stage_num = ss.get_current_stage() if ss.has_method("get_current_stage") else 1
		my_score_label.text = "Stage %d" % stage_num
		my_rank_label.text = "#7"
	else:
		my_score_label.text = "Stage 1"
		my_rank_label.text = "#7"

func _populate_leaderboard_rows() -> void:
	for child in leaderboard_list.get_children():
		child.queue_free()
		
	for entry in global_rankings:
		var row_panel = PanelContainer.new()
		row_panel.custom_minimum_size.y = 90
		leaderboard_list.add_child(row_panel)
		
		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 20)
		margin.add_theme_constant_override("margin_right", 20)
		row_panel.add_child(margin)
		
		var h_layout = HBoxContainer.new()
		h_layout.add_theme_constant_override("separation", 20)
		margin.add_child(h_layout)
		
		# Rank Position Badge
		var r_lbl = Label.new()
		r_lbl.text = "#%d" % entry["rank"]
		r_lbl.custom_minimum_size.x = 80
		r_lbl.add_theme_font_size_override("font_size", 28)
		if entry["is_top"]:
			r_lbl.add_theme_color_override("font_color", Color(1, 0.84, 0)) # Gold text accent
		else:
			r_lbl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
		h_layout.add_child(r_lbl)
		
		# Username Text String
		var n_lbl = Label.new()
		n_lbl.text = entry["name"]
		n_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		n_lbl.add_theme_font_size_override("font_size", 28)
		h_layout.add_child(n_lbl)
		
		# High Score Achievement Total
		var s_lbl = Label.new()
		s_lbl.text = entry["score"]
		s_lbl.add_theme_font_size_override("font_size", 28)
		if entry["is_top"]:
			s_lbl.add_theme_color_override("font_color", Color(1, 0.84, 0))
		else:
			s_lbl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
		h_layout.add_child(s_lbl)

func set_overlay_mode(value: bool) -> void:
	is_overlay = value
	# If running as an overlay, change the footer button text to read "RESUME" or "BACK"
	if is_overlay and has_node("%CloseButton"):
		%CloseButton.text = "RESUME RUN"

func _on_back_pressed() -> void:
	if is_overlay:
		# Unpause your battle engine safely
		var battle_manager = get_node_or_null("/root/BattleManager")
		if battle_manager:
			battle_manager.resume_battle()
		else:
			get_tree().paused = false
			
		# Remove this menu layer completely, revealing the underlying main scene perfectly intact!
		queue_free()
	else:
		# Fallback fallback if opened cleanly from a static Main Menu asset frame
		get_tree().change_scene_to_file("res://scenes/screens/main_gundam/main_gundam_scene.tscn")