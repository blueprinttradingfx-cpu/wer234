extends Control

@onready var back_button: Button = %BackButton
@onready var close_button: Button = %CloseButton
@onready var level_label: Label = %LevelLabel
@onready var xp_progress_bar: ProgressBar = %XpProgressBar
@onready var rewards_list: VBoxContainer = %RewardsList

var current_level: int = 4
var current_xp: int = 450
var xp_per_level: int = 1000
# Add a variable to track if this menu was opened from inside a running game
var is_overlay: bool = false

var pass_timeline: Array = [
	{"level": 1, "free_reward": "500 Credits", "premium_reward": "Alloy Plate Frame", "claimed": true},
	{"level": 2, "free_reward": "10 Diamonds", "premium_reward": "Laser Sight Blueprint", "claimed": true},
	{"level": 3, "free_reward": "Common Crate", "premium_reward": "50 Diamonds", "claimed": true},
	{"level": 4, "free_reward": "750 Credits", "premium_reward": "Plasma Saber Skin", "claimed": false},
	{"level": 5, "free_reward": "15 Diamonds", "premium_reward": "Heavy Thruster Core", "claimed": false},
	{"level": 6, "free_reward": "Gacha Ticket", "premium_reward": "150 Diamonds", "claimed": false}
]

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	close_button.pressed.connect(_on_back_pressed)
	
	_render_progression_state()
	_populate_rewards_timeline()

func _render_progression_state() -> void:
	level_label.text = "BATTLE PASS LEVEL: %d" % current_level
	xp_progress_bar.max_value = xp_per_level
	xp_progress_bar.value = current_xp

func _populate_rewards_timeline() -> void:
	for child in rewards_list.get_children():
		child.queue_free()
		
	for tier in pass_timeline:
		var tier_row = PanelContainer.new()
		tier_row.custom_minimum_size.y = 130
		rewards_list.add_child(tier_row)
		
		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 20)
		margin.add_theme_constant_override("margin_right", 20)
		tier_row.add_child(margin)
		
		var h_layout = HBoxContainer.new()
		h_layout.add_theme_constant_override("separation", 25)
		margin.add_child(h_layout)
		
		var lvl_badge = Label.new()
		lvl_badge.text = "LVL\n%d" % tier["level"]
		lvl_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lvl_badge.add_theme_font_size_override("font_size", 28)
		h_layout.add_child(lvl_badge)
		
		var items_vbox = VBoxContainer.new()
		items_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		items_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		h_layout.add_child(items_vbox)
		
		var free_lbl = Label.new()
		free_lbl.text = "🆓 Free: " + tier["free_reward"]
		free_lbl.add_theme_font_size_override("font_size", 22)
		items_vbox.add_child(free_lbl)
		
		var prem_lbl = Label.new()
		prem_lbl.text = "👑 Premium: " + tier["premium_reward"]
		prem_lbl.add_theme_font_size_override("font_size", 22)
		prem_lbl.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
		items_vbox.add_child(prem_lbl)
		
		var claim_btn = Button.new()
		claim_btn.custom_minimum_size = Vector2(160, 70)
		claim_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		claim_btn.add_theme_font_size_override("font_size", 24)
		
		if tier["claimed"]:
			claim_btn.text = "CLAIMED"
			claim_btn.disabled = true
		elif current_level >= tier["level"]:
			claim_btn.text = "CLAIM"
			claim_btn.pressed.connect(_on_claim_triggered.bind(tier["level"]))
		else:
			claim_btn.text = "LOCKED"
			claim_btn.disabled = true
			
		h_layout.add_child(claim_btn)

func _on_claim_triggered(level_id: int) -> void:
	for tier in pass_timeline:
		if tier["level"] == level_id:
			tier["claimed"] = true
			print("🎁 Claimed rewards sequence for Pass Level: ", level_id)
			break
	_populate_rewards_timeline()

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