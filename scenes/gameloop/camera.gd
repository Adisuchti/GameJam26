extends Node2D

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea

var player_in_zone = null

func _ready():
	# Connect signals if not done in editor
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)
	
	# Default state
	anim_sprite.play("idle")

func _process(delta):
	if player_in_zone:
		# Check the player's mask status continuously while they are inside
		# "get" is safe to use even if the property doesn't exist (returns null)
		var has_mask = player_in_zone.get("has_mask")
		
		if (has_mask == false) or ((has_mask == true) and global.maskState < 50):
			trigger_alert()
		else:
			# If they put the mask ON while inside, the camera relaxes
			anim_sprite.play("idle")
	else:
		# Optional: If you want it to stay idle when empty
		if anim_sprite.animation != "idle":
			anim_sprite.play("idle")

func trigger_alert():
	# 1. Update the Global variable with current system time (milliseconds)
	Global.lastCameraSpotted = Time.get_ticks_msec()
	
	# 2. Change visual to blinking
	if anim_sprite.animation != "blinking":
		anim_sprite.play("blinking")
		print("CAMERA ALERT! Time updated: ", Global.lastCameraSpotted)

# --- SIGNALS ---
func _on_body_entered(body):
	# Check if it is the player (ensure your player node is named "mainCharacter" or use groups)
	if body.name == "mainCharacter":
		player_in_zone = body

func _on_body_exited(body):
	if body == player_in_zone:
		player_in_zone = null
		# Reset animation immediately when they leave
		anim_sprite.play("idle")
