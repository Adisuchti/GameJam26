extends Node2D

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var alarm: AudioStreamPlayer2D = $alarm

# CONFIGURATION
const ALARM_MAX_DURATION := 3.0 # Alarm stops after 3 seconds

# STATE VARIABLES
var player_in_zone = null
var current_alarm_time := 0.0

func _ready():
	if not detection_area.body_entered.is_connected(_on_body_entered):
		detection_area.body_entered.connect(_on_body_entered)
	if not detection_area.body_exited.is_connected(_on_body_exited):
		detection_area.body_exited.connect(_on_body_exited)
	
	anim_sprite.play("idle")

func _process(delta):
	if player_in_zone:
		# Check mask status
		# Make sure 'has_mask' matches your player script variable
		var has_mask = player_in_zone.get("has_mask")
		
		# If CAUGHT (No mask or mask broken)
		if (has_mask == false) or ((has_mask == true) and Global.maskState < 50):
			trigger_alert(delta) # Pass delta to count time
		else:
			reset_alert()
	else:
		reset_alert()

func trigger_alert(delta: float):
	# 1. Always update the Global "Last Spotted" time while caught
	Global.lastCameraSpotted = Time.get_ticks_msec()
	
	# 2. visual alert (Always keeps blinking while caught)
	if anim_sprite.animation != "blinking":
		anim_sprite.play("blinking")

	# 3. AUDIO LOGIC (The new part)
	# Increment the timer
	current_alarm_time += delta
	
	# Only play sound if we haven't hit the time limit
	if current_alarm_time < ALARM_MAX_DURATION:
		if not alarm.playing:
			alarm.play()
	else:
		# Time is up! Silence the alarm (even if player is still there)
		if alarm.playing:
			alarm.stop()

func reset_alert():
	# Reset the timer so next time they get caught, it plays again
	current_alarm_time = 0.0
	
	if alarm.playing:
		alarm.stop()
		
	if anim_sprite.animation != "idle":
		anim_sprite.play("idle")

# --- SIGNALS ---
func _on_body_entered(body):
	if body.name == "mainCharacter":
		player_in_zone = body

func _on_body_exited(body):
	if body == player_in_zone:
		player_in_zone = null
		reset_alert()
