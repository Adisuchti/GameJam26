extends CharacterBody2D

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
# 1. Add a NavigationAgent2D node to your NPC scene and link it here
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

@export var speed = 200
@export var waypoints: Array[Marker2D] = [] 
@export var active: bool = false 

var current_waypoint_index = 0
var animation_timer = 0.0
var use_alt_frame = false 

func _ready():
	# Optional: Tune agent parameters
	nav_agent.path_desired_distance = 10.0
	nav_agent.target_desired_distance = 10.0

func _physics_process(delta):
	if not active or waypoints.is_empty():
		animation_timer = 0.0
		use_alt_frame = false
		anim_sprite.frame = 0 
		velocity = Vector2.ZERO # Ensure they stop moving
		return

	# 2. Pathfinding Logic [cite: 1, 2]
	var target_position = waypoints[current_waypoint_index].global_position
	nav_agent.target_position = target_position

	# Check if we reached the current waypoint to cycle to the next one 
	if nav_agent.is_navigation_finished():
		current_waypoint_index = (current_waypoint_index + 1) % waypoints.size()
		return

	# Calculate the next position in the path (this avoids the walls) 
	var next_path_pos = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(next_path_pos)
	
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
	# Convert angle to 0-7 index for 8 directions [cite: 1]
	var direction_index = int(round((angle + PI) / (PI / 4))) % 8
	
	var anim_name = "front"
	var should_flip = false

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
		4: # Right [cite: 3]
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
	anim_sprite.frame = 1 if use_alt_frame else 0
