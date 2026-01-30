extends CharacterBody2D

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var speed = 400

# Variables to track animation timing
var animation_timer = 0.0
var use_alt_frame = false 
var last_direction_name = "down" # Default idle direction

func _physics_process(delta):
	# 1. Handle Movement
	var input_direction = Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown")
	velocity = input_direction * speed
	
	# 2. Handle Animation Logic
	if input_direction != Vector2.ZERO:
		animation_timer += delta
		
		# Per your request: Change frame every 2 seconds
		if animation_timer >= 0.2: 
			animation_timer = 0.0
			use_alt_frame = not use_alt_frame
			
		update_animation(input_direction)
	else:
		# Reset to frame 0 (idle) when stopped
		animation_timer = 0.0
		use_alt_frame = false
		anim_sprite.frame = 0 # Ensure it stays on the base frame when still

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
