extends CharacterBody2D

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var speed = 150
@export var jitter_strength = 4.0    # Max pixels to "twitch" per frame

@export var max_health = 1
var current_health = 1
var is_dead = false

# Equipment toggles
@export var has_mask: bool = false
@export var has_hat: bool = false

# Variables to track animation timing
var animation_timer = 0.0
var use_alt_frame = false
var frame_counter = 0

# Initializing with Vector2.DOWN (0, 1) so the character faces the screen by default
var last_direction = Vector2.DOWN

func _ready():
	current_health = max_health # Initialize health
	
func _process(delta: float) -> void:
	#global.mask_lost_forever.connect(_on_mask_lost_forever)
	#global.mask_restored.connect(_on_mask_restored)
	if global.cap_lost:
		has_hat = false
	if global.mask_down:
		has_mask = false
	update_animation(last_direction)

#func _on_mask_restored() -> void:
	#mask_gone = true
	#update_animation(last_direction)
	#
#func _on_mask_lost_forever() -> void:
	#mask_gone = false
	#update_animation(last_direction)

func _physics_process(delta):
	if is_dead:
		return
	
	var input_direction = Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown")
	velocity = input_direction * speed
	
	if input_direction != Vector2.ZERO:
		# --- RHYTHMIC JITTER LOGIC ---
		frame_counter += 1
		
		# Only change the offset every 10 frames
		if frame_counter >= 10:
			var displacement = Vector2(
				randf_range(-jitter_strength, jitter_strength),
				randf_range(-jitter_strength, jitter_strength)
			)
			anim_sprite.position = displacement
			frame_counter = 0 # Reset counter
		
		# Animation Timing
		animation_timer += delta
		if animation_timer >= 0.2: 
			animation_timer = 0.0
			use_alt_frame = not use_alt_frame
			
		update_animation(input_direction)
		last_direction = input_direction
	else:
		# Reset when standing still
		anim_sprite.position = Vector2.ZERO 
		frame_counter = 0
		animation_timer = 0.0
		use_alt_frame = false
		anim_sprite.frame = 0 
		
	move_and_slide()

	# Navigation Snapping
	var map = get_world_2d().get_navigation_map()
	var valid_pos = NavigationServer2D.map_get_closest_point(map, global_position)
	if valid_pos != Vector2.ZERO:
		global_position = valid_pos
	
# New helper function for your test toggles
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			if !global.mask_down:
				has_mask = !has_mask
				if has_mask:
					global.mask_show.emit()
				else:
					global.mask_hide.emit()
				print("Mask toggled: ", has_mask)
			else:
				print("Mask not on hand anymore")
		if event.keycode == KEY_2:
			if !global.cap_lost:
				has_hat = !has_hat
				if has_hat:
					global.cap_show.emit()
				else:
					global.cap_hide.emit()
				print("Hat toggled: ", has_hat)
			else:
				print("Hat not on hand anymore")
	update_animation(last_direction)
	
func take_damage(amount):
	current_health -= amount
	print("Ouch! Took ", amount, " damage. Health remaining: ", current_health)
	
	if current_health <= 0:
		die()

func die():
	if is_dead: return # Prevent die() from running multiple times
	is_dead = true
	
	print("Player has died!")
	
	# 1. Turn the sprite 90 degrees (falling over)
	anim_sprite.rotation_degrees = 90 
	
	# 2. Apply a red tint (Minecraft style)
	# modulate affects the color of the sprite; (1, 0, 0) is pure red
	anim_sprite.modulate = Color(1, 0.4, 0.4) 
	
	# 3. Wait a moment before switching scenes (optional but feels better)
	await get_tree().create_timer(1.0).timeout
	
	# 4. Switch to the Game Over scene
	# Replace "res://GameOver.tscn" with the actual path to your scene
	get_tree().change_scene_to_file("res://scenes/gameloop/game_over.tscn")

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

	var prefix = ""
	if has_mask and has_hat:
		prefix = "both_"
	elif has_mask:
		prefix = "mask_"
	elif has_hat:
		prefix = "hat_"
	
	anim_sprite.flip_h = should_flip
	anim_sprite.animation = prefix + anim_name
	
	# Manually control which 'step' is shown based on your timer
	anim_sprite.frame = 1 if use_alt_frame else 0
