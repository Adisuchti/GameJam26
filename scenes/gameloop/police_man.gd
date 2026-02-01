extends "res://scenes/gameloop/NPC_movement.gd"

@export var chase_speed = 115.0      # Slower than player (150)
@export var attack_range = 60.0
@export var attack_damage = 10
@export var attack_cooldown = 0.5
@export var chase_jitter_strength = 4.0

const COOLDOWN_MS = 30000.0

var bubble_scene = load("res://scenes/speech_bubble.tscn")

var target_player = null
var attack_timer = 0.0
var is_aggroed = false
var chase_frame_counter = 0 # Track frames for jitter

func _ready():
	super._ready()
	if has_node("DetectionArea"):
		var area = $DetectionArea
		# Connecting signals to the functions defined at the bottom
		area.body_entered.connect(_on_body_entered)
		area.body_exited.connect(_on_body_exited)

func _physics_process(delta):
	attack_timer += delta
	
	var current_time = Time.get_ticks_msec()
	var elapsed = current_time - Global.lastCameraSpotted
	
	# 1. DECIDE: Check for Mask Trigger
	if target_player != null and not is_aggroed:
		if (target_player.get("has_mask") == true) or (elapsed < COOLDOWN_MS):
			is_aggroed = true
			Global.lastCameraSpotted = Time.get_ticks_msec()
			print("Police spotted mask! AGGRO STARTED.")
			var bubble = bubble_scene.instantiate()
			add_child(bubble)
			bubble.display_text("STOP!")

	# 2. ACT: Chase if aggroed, otherwise Patrol
	if is_aggroed and target_player != null:
		perform_chase_and_attack_logic(delta)
	else:
		# Reset jitter if we stop chasing
		if anim_sprite.position != Vector2.ZERO:
			anim_sprite.position = Vector2.ZERO
		super._physics_process(delta)

func perform_chase_and_attack_logic(delta):
	var distance_to_player = global_position.distance_to(target_player.global_position)
	
	# --- JITTER LOGIC ---
	chase_frame_counter += 1
	if chase_frame_counter >= 10:
		anim_sprite.position = Vector2(
			randf_range(-chase_jitter_strength, chase_jitter_strength),
			randf_range(-chase_jitter_strength, chase_jitter_strength)
		)
		chase_frame_counter = 0

	# --- ATTACK ---
	if distance_to_player <= attack_range:
		velocity = Vector2.ZERO
		anim_sprite.position = Vector2.ZERO # Stay still while hitting
		if attack_timer >= attack_cooldown:
			attack_timer = 0.0
			attack_player()
	
	# --- CHASE ---
	else:
		nav_agent.target_position = target_player.global_position
		
		if not nav_agent.is_navigation_finished():
			var next_pos = nav_agent.get_next_path_position()
			var direction = global_position.direction_to(next_pos)
			velocity = direction * chase_speed
			
			# Animation Timing
			animation_timer += delta
			if animation_timer >= 0.2:
				animation_timer = 0.0
				use_alt_frame = not use_alt_frame
				
			update_animation(direction)
	
	move_and_slide()

func attack_player():
	if target_player and target_player.has_method("take_damage"):
		target_player.take_damage(attack_damage)

# --- VISION SIGNALS ---
# These must exist to satisfy the .connect() calls in _ready()
func _on_body_entered(body):
	if body.name == "mainCharacter": 
		target_player = body

func _on_body_exited(body):
	if body == target_player:
		target_player = null
		is_aggroed = false 
		anim_sprite.position = Vector2.ZERO # Reset displacement
		print("Player escaped! Police returning to patrol.")
