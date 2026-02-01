extends ColorRect

@export var max_slant: float = 0.08 
@export var base_speed: float = 50.0
@export var wind_speed_boost: float = 40.0

func _process(_delta: float) -> void:
	var ws = globalwind.wind_strength 
	
	# --- TIER 1: UNDER 5 (Nothing) ---
	if ws < 5.0:
		visible = false
		modulate.a = 0.0
		return
	
	# If we are here, ws is at least 5.0
	visible = true
	
	# --- TIER 2: 5 TO 7 (Slowly appearing & Slow Speed) ---
	if ws >= 5.0 and ws < 7.0:
		# Use remap to turn 5.0-7.0 into 0.0-1.0 alpha
		var fade_t = remap(ws, 5.0, 7.0, 0.0, 1.0)
		modulate.a = fade_t
		
		# Keep it relatively slow and slightly slanted
		material.set_shader_parameter("slant", max_slant * 0.3)
		material.set_shader_parameter("speed", base_speed)
		
	# --- TIER 3: 7 TO 10 (High Intensity) ---
	else:
		modulate.a = 1.0 # Fully visible
		
		# Map 7.0-10.0 to a higher range of slant and speed
		var intensity_t = remap(ws, 7.0, 10.0, 0.3, 1.0)
		
		material.set_shader_parameter("slant", intensity_t * max_slant)
		material.set_shader_parameter("speed", base_speed + (intensity_t * wind_speed_boost))

# Helper function if you are on an older Godot 4 version that lacks remap
func _remap(value, istart, istop, ostart, ostop):
	return ostart + (ostop - ostart) * ((value - istart) / (istop - istart))
