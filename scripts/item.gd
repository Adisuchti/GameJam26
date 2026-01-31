# Example usage:
# var item_node = $ItemNode
# item_node.throw_item(Vector2(500, -300))  # throw right & up
# item_node.hide_item()

extends Node2D

@export var item_sprite: Sprite2D  # assign any Sprite2D in the Inspector

# Hover parameters
@export var hover_amplitude: float = 16.0   # pixels up/down
@export var hover_speed: float = 2.0        # how fast it hovers

# Throw physics
@export var gravity: float = 50.0          # pixels/sec^2
@export var land_offset_x: float = 60.0    # horizontal distance to land

var original_pos: Vector2
var hover_timer: float = 0.0

# Throw state
var is_thrown := false
var velocity: Vector2 = Vector2.ZERO
var target_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	if item_sprite == null:
		push_error("Item sprite not assigned!")
		return
	original_pos = item_sprite.position
	item_sprite.visible = false  # start hidden
	throw_item()

func _process(delta: float) -> void:
	if item_sprite == null:
		return

	if is_thrown:
		# Update physics
		velocity.y += gravity * delta
		item_sprite.position += velocity * delta

		# Check landing
		if item_sprite.position.y >= target_pos.y:
			item_sprite.position = target_pos
			velocity = Vector2.ZERO
			is_thrown = false
	else:
		# Idle hover
		if item_sprite.visible:
			hover_timer += delta * hover_speed
			var y_offset = sin(hover_timer) * hover_amplitude
			item_sprite.position.y = original_pos.y + y_offset


# ========================
# VISIBILITY API
# ========================

func show_item() -> void:
	if item_sprite == null:
		return
	item_sprite.visible = true
	item_sprite.position = original_pos
	hover_timer = 0.0
	is_thrown = false

func hide_item() -> void:
	if item_sprite == null:
		return
	item_sprite.visible = false
	is_thrown = false


# ========================
# THROW FUNCTION
# ========================

func throw_item(force: Vector2 = Vector2(50, -30)) -> void:
	if item_sprite == null:
		return
	item_sprite.visible = true
	item_sprite.position = original_pos
	is_thrown = true
	velocity = force
	target_pos = original_pos + Vector2(land_offset_x, 0)
