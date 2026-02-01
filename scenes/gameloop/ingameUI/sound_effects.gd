extends Node2D

@export var wind_strength: float = 0.0

# --- Audio References ---
@onready var rain: AudioStreamPlayer2D = $rain
@onready var wind: AudioStreamPlayer2D = $wind

# --- Configuration ---
const WIND_MAX := 10.0
const WIND_START_THRESHOLD := 1.0  # <--- Audio starts here

const RAMP_TIME := 20.0        
const PEAK_TIME := 10.0        

const MIN_INTERVAL := 20.0     
const MAX_INTERVAL := 70.0    

# --- State Variables ---
var target := 0.0
var timer := 0.0
var next_event_time := 0.0
var peak_timer := 0.0
var in_peak := false

func _ready() -> void:
	randomize()
	_schedule_next_event()
	
	# Start silent
	rain.volume_db = -80
	wind.volume_db = -80

func _process(delta: float) -> void:
	timer += delta
	
	# 1. Check for start of wind event
	# We use a small epsilon (0.01) to ensure floating point comparison works
	if timer >= next_event_time and target == 0.0 and wind_strength <= 0.01:
		target = WIND_MAX
		timer = 0.0

	# 2. Smoothly ramp wind strength
	if wind_strength != target:
		var speed = WIND_MAX / RAMP_TIME
		wind_strength = move_toward(wind_strength, target, speed * delta)

		# Reached peak
		if wind_strength == WIND_MAX:
			in_peak = true
			peak_timer = 0.0

		# Fully back to zero
		if wind_strength == 0.0 and target == 0.0:
			_schedule_next_event()

	# 3. Handle Peak Duration
	if in_peak:
		peak_timer += delta
		if peak_timer >= PEAK_TIME:
			in_peak = false
			target = 0.0
	
	# 4. --- AUDIO LOGIC ---
	_update_audio()

func _update_audio() -> void:
	# Only play sound if wind is stronger than our threshold (4.0)
	if wind_strength > WIND_START_THRESHOLD:
		
		# Ensure playing if not already
		if not rain.playing: rain.play()
		if not wind.playing: wind.play()
		
		# --- THE MAGIC PART ---
		# This converts the range 4->10 into 0.0->1.0
		# If wind is 4, result is 0.0 (Silent)
		# If wind is 7, result is 0.5 (Half volume)
		# If wind is 10, result is 1.0 (Max volume)
		var volume_linear = inverse_lerp(WIND_START_THRESHOLD, WIND_MAX, wind_strength)
		
		rain.volume_db = linear_to_db(volume_linear)
		wind.volume_db = linear_to_db(volume_linear)
		
	else:
		# If wind drops below 4, silence the audio
		if rain.playing: rain.stop()
		if wind.playing: wind.stop()

func _schedule_next_event() -> void:
	timer = 0.0
	# Uncomment this line below for random timings in the actual game!
	# next_event_time = randf_range(MIN_INTERVAL, MAX_INTERVAL)
	next_event_time = 1.0
