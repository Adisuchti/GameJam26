extends CharacterBody2D

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var speed = 200
@export var waypoints: Array[Marker2D] = [] # Assign Marker2D nodes in the inspector
@export var active: bool = false # Toggle this to start/stop movement

var current_waypoint_index = 0
var animation_timer = 0.0
var use_alt_frame = false 

func _physics_process(delta):
	if not active or waypoints.is_empty():
		# Reset to idle [cite: 1, 3]
		animation_timer = 0.0
		use_alt_frame = false
		anim_sprite.frame = 0 
		return

	# Logic must stay inside this function!
	var target_position = waypoints[current_waypoint_index].global_position
	var direction = global_position.direction_to(target_position)
	
	if global_position.distance_to(target_position) < 5:
		current_waypoint_index = (current_waypoint_index + 1) % waypoints.size()
	
	velocity = direction * speed
	
	# Animation timing [cite: 1]
	animation_timer += delta
	if animation_timer >= 0.2: 
		animation_timer = 0.0
		use_alt_frame = not use_alt_frame
			
	update_animation(direction)
	move_and_slide()

func update_animation(direction: Vector2):
	var angle = direction.angle()
	# Convert angle to 0-7 index for 8 directions
	var direction_index = int(round((angle + PI) / (PI / 4))) % 8
	
	var anim_name = "front"
	var should_flip = false

	# Map direction index to animation names in your SpriteFrames
	match direction_index:
		0: # Left
			anim_name = "walk_left"
			should_flip = false
		1: # Up-Left
			anim_name = "walk_up"
			should_flip = false
		2: # Up
			anim_name = "walk_up"
			should_flip = false
		3: # Up-Right
			anim_name = "walk_up"
			should_flip = true
		4: # Right
			anim_name = "walk_right"
			should_flip = false
		5: # Down-Right
			anim_name = "walk_down"
			should_flip = true
		6: # Down
			anim_name = "walk_down"
			should_flip = false
		7: # Down-Left
			anim_name = "walk_down"
			should_flip = false

	anim_sprite.flip_h = should_flip
	anim_sprite.animation = anim_name
	
	# Manually control which 'step' is shown based on your timer
	anim_sprite.frame = 1 if use_alt_frame else 0
