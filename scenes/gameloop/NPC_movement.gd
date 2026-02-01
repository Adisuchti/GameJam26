extends CharacterBody2D

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

@export var speed = 70.0
@export var jitter_strength = 3.5
@export var waypoints: Array[Marker2D] = [] 
@export var active: bool = false 

var current_waypoint_index = 0
var animation_timer = 0.0
var use_alt_frame = false 
var frame_counter = 0

func _ready():
	# Randomized speed so every NPC has a unique walking pace
	speed = randf_range(60.0, 85.0)
	
	nav_agent.path_desired_distance = 10.0
	nav_agent.target_desired_distance = 10.0

func _physics_process(delta):
	if not active or waypoints.is_empty():
		_reset_to_idle()
		return

	var target_position = waypoints[current_waypoint_index].global_position
	nav_agent.target_position = target_position

	if nav_agent.is_navigation_finished():
		current_waypoint_index = (current_waypoint_index + 1) % waypoints.size()
		return

	var next_path_pos = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(next_path_pos)
	
	velocity = direction * speed
	
	# Jitter Logic
	frame_counter += 1
	if frame_counter >= 10:
		anim_sprite.position = Vector2(
			randf_range(-jitter_strength, jitter_strength),
			randf_range(-jitter_strength, jitter_strength)
		)
		frame_counter = 0
	
	# Animation Timing
	animation_timer += delta
	if animation_timer >= 0.2: 
		animation_timer = 0.0
		use_alt_frame = not use_alt_frame
			
	update_animation(direction)
	move_and_slide()

func _reset_to_idle():
	animation_timer = 0.0
	use_alt_frame = false
	anim_sprite.frame = 0 
	anim_sprite.position = Vector2.ZERO 
	frame_counter = 0
	velocity = Vector2.ZERO

func update_animation(direction: Vector2):
	var angle = direction.angle()
	var direction_index = int(round((angle + PI) / (PI / 4))) % 8
	
	if has_node("DetectionArea"):
		$DetectionArea.rotation = direction.angle() + deg_to_rad(-90) 

	var anim_name = "front"
	var should_flip = false

	# Fixed match block (No curly braces)
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
	anim_sprite.frame = 1 if use_alt_frame else 0
