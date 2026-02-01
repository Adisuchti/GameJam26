extends ColorRect

# How long the eye opening animation takes
@export var animation_duration: float = 2.5 
# Optional: Delay before it starts opening
@export var start_delay: float = 0.5

func _ready() -> void:
	# 1. Make sure we cover the full screen
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# 2. Set initial state: Eye Closed (0.0)
	material.set_shader_parameter("open_amount", 0.0)
	material.set_shader_parameter("color", Color.BLACK) # Ensure the eyelid is black
	
	# 3. Create the animation
	var tween = create_tween()
	
	# Wait a tiny bit (optional)
	tween.tween_interval(start_delay)
	
	# Animate 'open_amount' to 1.0 (Fully Open)
	# TRANS_CUBIC makes it start slow and speed up, like a real eye opening
	tween.tween_property(material, "shader_parameter/open_amount", 1.0, animation_duration)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	
	# 4. Clean up
	# Once finished, hide the Rect so it doesn't block mouse clicks or waste GPU
	tween.tween_callback(self.hide)

func _process(delta: float) -> void:
	pass
