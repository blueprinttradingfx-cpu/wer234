extends Node

func _ready():
	await get_tree().process_frame
	
	# Run critical epics test suite
	var test_scene = load("res://tests/test_critical_epics.tscn")
	if test_scene:
		var test_instance = test_scene.instantiate()
		get_tree().root.add_child(test_instance)
	else:
		print("Failed to load test scene")
		get_tree().quit()
