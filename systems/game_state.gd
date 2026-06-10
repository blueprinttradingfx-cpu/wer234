extends Node

enum Screen {
	BOOT,
	SPLASH,
	TAP_TO_START,
	MENU,
	BATTLE,
	HANGAR,
	UPGRADES,
	SHOP,
	SETTINGS,
	BATTLE_PASS,
	LEADERBOARD,
}

signal screen_changed(new_screen: Screen, extra: Dictionary)

var current_screen: Screen = Screen.BOOT
var session_rewards: Dictionary = {}

var _current_scene_node: Node = null
var _transition_tween: Tween = null

func _ready() -> void:
	screen_changed.connect(_on_screen_changed)

func go_to(screen: Screen, extra: Dictionary = {}) -> void:
	current_screen = screen
	screen_changed.emit(screen, extra)

func transition_to_screen(screen: Screen) -> void:
	go_to(screen)

func _on_screen_changed(new_screen: Screen, extra: Dictionary) -> void:
	var scene_path = get_scene_path(new_screen)
	_load_scene_with_transition(scene_path)

func _load_scene_with_transition(scene_path: String) -> void:
	var tree = get_tree()
	if not tree or scene_path.is_empty():
		return
	
	var scene_resource = load(scene_path)
	if not scene_resource:
		push_error("Failed to load scene at path: " + scene_path)
		return
		
	var new_scene = scene_resource.instantiate()
	
	if _current_scene_node:
		if _transition_tween and _transition_tween.is_valid():
			_transition_tween.kill()
		_transition_tween = create_tween()
		_transition_tween.tween_property(new_scene, "modulate:a", 1.0, 0.2)
		_transition_tween.tween_callback(_remove_current_scene)
		_transition_tween.tween_callback(_add_new_scene.bind(new_scene))
		_transition_tween.tween_property(new_scene, "modulate:a", 1.0, 0.2)
	else:
		new_scene.modulate = Color(1, 1, 1, 0)
		var root = tree.root
		root.call_deferred("add_child", new_scene)
		_current_scene_node = new_scene
		
		_transition_tween = create_tween()
		_transition_tween.tween_property(new_scene, "modulate:a", 1.0, 0.2)

func _remove_current_scene() -> void:
	if _current_scene_node:
		_current_scene_node.queue_free()
		_current_scene_node = null

func _add_new_scene(new_scene: Node) -> void:
	var tree = get_tree()
	if tree:
		tree.root.add_child(new_scene)
		_current_scene_node = new_scene

func get_scene_path(screen: Screen) -> String:
	match screen:
		Screen.MENU:
			return "res://scenes/screens/main_menu.tscn"
		Screen.BATTLE:
			return "res://scenes/screens/main_gundam/main_gundam_scene.tscn"
		Screen.HANGAR:
			return "res://scenes/screens/hangar_screen.tscn"
		Screen.UPGRADES:
			return "res://scenes/screens/upgrades_screen.tscn"
		Screen.SHOP:
			return "res://scenes/screens/shop_screen.tscn"
		Screen.BATTLE_PASS:
			return "res://scenes/screens/battle_pass_screen.tscn"
		Screen.LEADERBOARD:
			return "res://scenes/screens/leaderboard_screen.tscn"
		Screen.SETTINGS:
			return ""
		_:
			return ""
