extends ColorRect

var melting := false
var timer := 0.0

# 0.5 was normal, so 0.15 is roughly 3x slower
var melt_speed := 0.01
var target_scene := ""

func _ready():
	self.hide()
	self.color = Color.BLACK 
	self.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _process(delta):
	if melting:
		# Increase timer based on our slow speed
		timer += delta * melt_speed
		self.material.set_shader_parameter("timer", timer)
		
		# We dynamically calculate when to finish based on speed
		# (We need the timer to reach roughly 2.5 to clear the screen)
		if timer > 2.5: 
			finish_and_change_scene()

func start_transition(next_scene_path: String):
	target_scene = next_scene_path
	
	# 1. Capture screen
	var img = get_viewport().get_texture().get_image()
	var tex = ImageTexture.create_from_image(img)
	self.material.set_shader_parameter("melt_tex", tex)
	
	# 2. Randomize strips
	var offsets = []
	for i in 64:
		offsets.append(randf_range(1.0, 2.5)) # Slightly higher variance
	self.material.set_shader_parameter("y_offsets", offsets)
	
	# 3. Reset and Start
	timer = 0.0
	self.material.set_shader_parameter("timer", 0.0)
	self.material.set_shader_parameter("melting", true)
	
	self.show()
	melting = true

func finish_and_change_scene():
	melting = false
	get_tree().change_scene_to_file(target_scene)
