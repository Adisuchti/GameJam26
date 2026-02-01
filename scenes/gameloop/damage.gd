extends ColorRect

var tween: Tween

func _ready() -> void:
	# Ensure the intensity starts at 0
	material.set_shader_parameter("intensity", 0.0)
	
	global.wanted_level.connect(_on_enemy_detected)

func _on_enemy_detected(is_detected: bool) -> void:
	# Kill any existing tween to prevent overlapping animations
	if tween:
		tween.kill()
	
	tween = create_tween()
	if is_detected:
		tween.tween_property(material, "shader_parameter/intensity", 1.0, 0.4)
		tween.tween_property(material, "shader_parameter/intensity", 0.6, 0.4)
		tween.set_loops() # This will make the red border "throb" while detected
	else:
		# Fade OUT to 0.0
		tween.tween_property(material, "shader_parameter/intensity", 0.0, 0.5).set_trans(Tween.TRANS_SINE)
