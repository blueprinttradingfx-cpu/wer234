extends Node2D

# --- Combat Stats Parameters ---
var movement_speed: float = 140.0       # Pixels per second advancing towards center
var core_health: float = 10.0           # Total health capacity points
var center_target: Vector2 = Vector2(540, 960) # Absolute center matching 1080x1920 layout

# --- Rendering Properties ---
var visual_hull: ColorRect
var flash_timer: float = 0.0

func _ready() -> void:
	# Add the group tag so the automated weapon loop can detect it instantly
	add_to_group("enemies")
	
	# Generate a lightweight visual placeholder block for testing
	visual_hull = ColorRect.new()
	visual_hull.size = Vector2(40, 40)
	visual_hull.position = -visual_hull.size / 2 # Center pivot point offset conversion
	visual_hull.color = Color.MEDIUM_PURPLE
	add_child(visual_hull)

func _process(delta: float) -> void:
	# Continuous tracking trajectory calculation pointing to the central arena target coordinates
	position = position.move_toward(center_target, movement_speed * delta)
	
	# Reset flashing overlay damage indication
	if flash_timer > 0.0:
		flash_timer -= delta
		if flash_timer <= 0.0 and is_instance_valid(visual_hull):
			visual_hull.color = Color.MEDIUM_PURPLE

## Handles incoming damage points passed down from weapon system arrays
func take_damage(amount: float) -> void:
	core_health -= amount
	
	# Provide quick structural visual feedback feedback
	if is_instance_valid(visual_hull):
		visual_hull.color = Color.WHITE
		flash_timer = 0.08
		
	print("🤖 Mock Enemy Struck! Remaining HP: ", core_health)
	
	# Safe clean up disposal evaluation loops
	if core_health <= 0.0:
		execute_destruction_sequence()

## Handles entity tracking clearance updates
func execute_destruction_sequence() -> void:
	# Safe self deletion framework execution
	queue_free()