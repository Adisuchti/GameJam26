extends "res://scenes/gameloop/NPC_movement.gd"

@export var chase_speed = 105.0      # Much slower (Player is 150)
@export var attack_range = 60.0
@export var attack_damage = 10
@export var attack_cooldown = 0.5
@export var chase_jitter_strength = 4.0

var bubble_scene = load("res://scenes/speech_bubble.tscn")

var target_player = null 
var attack_timer = 0.0
var is_aggroed = false 

# Reuse the frame counter from the base script if possible, 
# or define it here if the base doesn't expose it.
var chase_frame_counter = 0

func _ready():
	super._ready()
	if has_node("DetectionArea"):
		var area = $DetectionArea
		area.body_entered.connect(_on_body_entered)
		area.body_exited.connect(_on_body_exited)

func _physics_process(delta):
	attack_timer += delta

	if target_player != null and not is_aggroed:
		if target_player.get("has_hat") != true:
			is_aggroed = true
			var bubble = bubble_scene.instantiate()
			add_child(bubble)
			bubble.display_text("I'LL GET YOU!")

	if is_aggroed and target_player != null:
		perform_chase_and_attack_logic(delta)
	else:
		# Reset jitter when returning to patrol or idle
		super._physics_process(delta)

func perform_chase_and_attack_logic(delta):
	var distance_to_player = global_position.distance_to(target_player.global_position)

	# --- JITTER LOGIC (Every 10 frames) ---
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
		anim_sprite.position = Vector2.ZERO # Stop jittering while attacking
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
			
			# Animation Logic (reusing timing from your movement style)
			animation_timer += delta
			if animation_timer >= 0.2:
				animation_timer = 0.0
				use_alt_frame = not use_alt_frame
				
			update_animation(direction)
	
	move_and_slide()

func attack_player():
	if target_player.has_method("take_damage"):
		target_player.take_damage(attack_damage)

# --- VISION SIGNALS ---
func _on_body_entered(body):
	if body.name == "mainCharacter": 
		target_player = body

func _on_body_exited(body):
	if body == target_player:
		# If the player escapes the detection area, the police calms down
		target_player = null
		is_aggroed = false # Reset anger so he goes back to patrol
		print("Player escaped! Police returning to patrol.")
