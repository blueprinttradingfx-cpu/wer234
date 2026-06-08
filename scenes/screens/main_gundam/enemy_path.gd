extends Line2D

func _ready() -> void:
	# Make the path line visible at runtime
	width = 6.0
	default_color = Color(0.2, 0.9, 1.0, 0.75)  # Cyan, 75% opacity

	# Get the parent Path2D node
	var path_node = get_parent() as Path2D
	if path_node:
		# Copy the baked points from the curve directly to the line
		points = path_node.curve.get_baked_points()
		# Close the visual loop
		closed = true

		# Add visual markers at each curve point
		_add_point_markers(path_node)

func _add_point_markers(path_node: Path2D) -> void:
	var point_count = path_node.curve.point_count
	for i in range(point_count):
		var point_pos = path_node.curve.get_point_position(i)

		# Red square marker
		var marker = ColorRect.new()
		marker.color = Color(1.0, 0.15, 0.15, 0.95)
		marker.size = Vector2(20, 20)
		marker.position = point_pos - Vector2(10, 10)  # Center on point
		add_child(marker)

		# Yellow label showing point index and coords
		var label = Label.new()
		label.text = "%d\n(%.0f,%.0f)" % [i, point_pos.x, point_pos.y]
		label.add_theme_font_size_override("font_size", 22)
		label.add_theme_color_override("font_color", Color(1.0, 1.0, 0.0, 1.0))
		label.position = point_pos + Vector2(12, -28)
		add_child(label)
