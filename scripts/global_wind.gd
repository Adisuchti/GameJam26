extends Node

@export var wind_strength: float = 0.0

const WIND_MAX := 10.0
const RAMP_TIME := 20.0        # seconds to go 0 → 10 or 10 → 0
const PEAK_TIME := 10.0        # seconds staying at 10

const MIN_INTERVAL := 20.0     # ~1.5 minutes = 90
const MAX_INTERVAL := 70.0    # ~2.5 minutes = 150

var target := 0.0
var timer := 0.0
var next_event_time := 0.0
var peak_timer := 0.0
var in_peak := false

func _ready() -> void:
	randomize()
	_schedule_next_event()

func _process(delta: float) -> void:
	print(wind_strength)
	timer += delta

	# Wait for next wind event
	if timer >= next_event_time and target == 0.0 and wind_strength == 0.0:
		target = WIND_MAX
		timer = 0.0

	# Smoothly move wind toward target
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

	# Hold at peak
	if in_peak:
		peak_timer += delta
		if peak_timer >= PEAK_TIME:
			in_peak = false
			target = 0.0


func _schedule_next_event() -> void:
	timer = 0.0
	next_event_time = randf_range(MIN_INTERVAL, MAX_INTERVAL)
