extends Control

@onready var gold_label: Label = %GoldLabel
@onready var diamond_label: Label = %DiamondLabel
@onready var back_button: Button = %BackButton
@onready var close_button: Button = %CloseButton

@onready var gacha_grid: HFlowContainer = %GachaGrid
@onready var diamonds_grid: HFlowContainer = %DiamondsGrid

const CARD_ITEM_SCENE = preload("res://scenes/common/shop_item_card.tscn")

# Add a variable to track if this menu was opened from inside a running game
var is_overlay: bool = false

# Store Inventory Database
var diamond_packages: Dictionary = {
	"gems_small": {"title": "Diamond Cache", "val": "+100 Gems", "cost_text": "$0.99", "amount": 100},
	"gems_medium": {"title": "Diamond Cargo", "val": "+550 Gems", "cost_text": "$4.99", "amount": 550},
	"gems_large": {"title": "Diamond Vault", "val": "+1200 Gems", "cost_text": "$9.99", "amount": 1200}
}

var gacha_packages: Dictionary = {
	"crate_single": {"title": "Standard Drop", "val": "1x Random Part", "cost_diamonds": 100},
	"crate_multi": {"title": "Elite Supply x10", "val": "Guaranteed Rare", "cost_diamonds": 900}
}

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	close_button.pressed.connect(_on_back_pressed)
	
	_update_currency_display()
	_build_shop_front()

func _update_currency_display() -> void:
	var ss = get_node_or_null("/root/SaveSystem")
	if ss:
		if ss.has_method("get_tech_credits"):
			gold_label.text = "💰 " + str(ss.get_tech_credits())
		if ss.has_method("get_diamonds"):
			diamond_label.text = "💎 " + str(ss.get_diamonds())

func _build_shop_front() -> void:
	# Clear out existing instances safely
	for c in gacha_grid.get_children(): c.queue_free()
	for c in diamonds_grid.get_children(): c.queue_free()
	
	# Populate Real Money Diamond Packs
	for id in diamond_packages:
		var item = diamond_packages[id]
		var card = CARD_ITEM_SCENE.instantiate()
		diamonds_grid.add_child(card)
		
		card.get_node("%TitleLabel").text = item["title"]
		card.get_node("%ValueLabel").text = item["val"]
		
		var btn: Button = card.get_node("%BuyButton")
		btn.text = item["cost_text"]
		btn.pressed.connect(_on_real_money_purchase.bind(id, item["amount"]))
		
	# Populate Gacha Supply Chests
	for id in gacha_packages:
		var item = gacha_packages[id]
		var card = CARD_ITEM_SCENE.instantiate()
		gacha_grid.add_child(card)
		
		card.get_node("%TitleLabel").text = item["title"]
		card.get_node("%ValueLabel").text = item["val"]
		
		var btn: Button = card.get_node("%BuyButton")
		btn.text = "💎 %d" % item["cost_diamonds"]
		btn.pressed.connect(_on_gacha_purchase.bind(id, item["cost_diamonds"]))

func _on_real_money_purchase(pack_id: String, amount: int) -> void:
	print("🛒 Processing storefront transaction for: ", pack_id)
	var ss = get_node_or_null("/root/SaveSystem")
	if ss:
		if ss.has_method("change_diamonds"):
			ss.change_diamonds(amount)
		elif ss.has_method("set_diamonds") and ss.has_method("get_diamonds"):
			ss.set_diamonds(ss.get_diamonds() + amount)
		_update_currency_display()

func _on_gacha_purchase(crate_id: String, cost: int) -> void:
	var ss = get_node_or_null("/root/SaveSystem")
	if not ss: return
	
	var current_diamonds = ss.get_diamonds() if ss.has_method("get_diamonds") else 0
	if current_diamonds < cost:
		print("❌ Not enough diamonds for crate!")
		return
		
	if ss.has_method("change_diamonds"):
		ss.change_diamonds(-cost)
	elif ss.has_method("set_diamonds"):
		ss.set_diamonds(current_diamonds - cost)
		
	print("📦 Crate successfully purchased: ", crate_id)
	_update_currency_display()

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
