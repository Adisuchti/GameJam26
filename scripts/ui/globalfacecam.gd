extends Node2D

@onready var frame: Sprite2D = $Frame
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animated_sprite_2d_2: AnimatedSprite2D = $AnimatedSprite2D2
@onready var clean_mask: Sprite2D = $CleanMask
@onready var clean_cap: Sprite2D = $CleanCap
@onready var video_stream_player: VideoStreamPlayer = $Control/VideoStreamPlayer

var cap_original_pos: Vector2
var is_cap_held := false
var cap_is_forever_gone = false
var emotion_frame = 0

# ========================
# MASK FALL EVENT
# ========================

@export var mask_fall_min_time := 20.0
@export var mask_fall_max_time := 60.0

var mask_original_pos: Vector2
var mask_timer := 0.0
var mask_trigger_time := 0.0

var mask_falling := false
var mask_lost_forever := false
var is_mask_held := false

func _ready() -> void:
	# Default visibility
	clean_mask.visible = true
	clean_cap.visible = true
	set_emotion(0)
	cap_original_pos = clean_cap.position

	# Ensure video is paused initially
	video_stream_player.visible = false

	# Connect input signals for cap
	clean_cap.set_process_input(true)
		
	mask_original_pos = clean_mask.position
	_schedule_mask_fall()



func _input(event: InputEvent) -> void:
	# Detect click/hold on the cap
	if cap_is_forever_gone:
		pass
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if clean_cap.get_rect().has_point(clean_cap.to_local(event.position)):
				if event.pressed:
					is_cap_held = true
				else:
					is_cap_held = false
					
			if clean_mask.get_rect().has_point(clean_mask.to_local(event.position)):
				if event.pressed:
					is_mask_held = true
				else:
					is_mask_held = false


func _process(delta: float) -> void:
	_apply_wind_effects(delta)
	if cap_is_forever_gone:
		clean_cap.visible = false
	if mask_lost_forever:
		clean_mask.visible = false
		
	_process_mask_fall(delta)


# ========================
# WIND EFFECTS
# ========================

func _apply_wind_effects(delta: float) -> void:
	var ws = globalwind.wind_strength

	# --- VIDEO PLAYBACK ---
	if ws >= 5.0:
		video_stream_player.speed_scale = 1.0 + (ws - 5.0) * 0.5
	else:
		video_stream_player.speed_scale = 1.0
		
	if ws > 5.0 && ws < 7.0:
		set_emotion(3)
	elif ws >= 7.0 && ws < 8.5:
		set_emotion(6)
	elif ws >= 8.5:
		set_emotion(1)
		
	# --- VIDEO VISIBILITY ---
	if ws > 5.0:
		video_stream_player.visible = true
		# optional: start playing if not already
		if not video_stream_player.is_playing():
			video_stream_player.play()
	else:
		video_stream_player.visible = false
		# optional: pause/reset video
		if video_stream_player.is_playing():
			video_stream_player.stop()

	# --- CAP SHAKING ---
	if cap_is_forever_gone:
		pass
	if not is_cap_held:
		if ws >= 5.0 and ws < 10.0:
			var shake_amount = 1.0 + (ws - 5.0) * 2.0  # stronger wind = bigger shake
			clean_cap.position = cap_original_pos + Vector2(randf_range(-shake_amount, shake_amount), randf_range(-shake_amount, shake_amount))
			clean_cap.visible = true
		elif ws >= 10.0:
			clean_cap.position = cap_original_pos + Vector2(100, 0)
			clean_cap.visible = false
			cap_is_forever_gone = true
		else:
			clean_cap.position = cap_original_pos
			clean_cap.visible = true
	else:
		clean_cap.position = cap_original_pos
		pass


# ========================
# EMOTION CONTROL
# ========================

func set_emotion(frame_index: int) -> void:
	emotion_frame = frame_index
	if frame_index >= 0 and frame_index <= 2:
		animated_sprite_2d.visible = true
		animated_sprite_2d_2.visible = false
		animated_sprite_2d.set_frame(frame_index)
	elif frame_index >= 3 and frame_index <= 10:
		animated_sprite_2d.visible = false
		animated_sprite_2d_2.visible = true
		animated_sprite_2d_2.set_frame(frame_index - 3)
	else:
		push_warning("Invalid emotion frame: " + str(frame_index))
		animated_sprite_2d.visible = true
		animated_sprite_2d_2.visible = false
		animated_sprite_2d.set_frame(0)


# ========================
# CAP CONTROL
# ========================

func show_cap() -> void:
	if cap_is_forever_gone:
		pass
	else:
		clean_cap.visible = true

func hide_cap() -> void:
	clean_cap.visible = false

func set_cap_visible(value: bool) -> void:
	clean_cap.visible = value


# ========================
# MASK CONTROL
# ========================

func show_mask() -> void:
	if mask_lost_forever:
		pass
	clean_mask.visible = true

func hide_mask() -> void:
	clean_mask.visible = false

func set_mask_visible(value: bool) -> void:
	if mask_lost_forever:
		pass
	clean_mask.visible = value


func _process_mask_fall(delta: float) -> void:
	if mask_lost_forever:
		return

	mask_timer += delta

	# Trigger fall
	if not mask_falling and mask_timer >= mask_trigger_time:
		mask_falling = true
		clean_mask.visible = true

	# Slow fall: 1px per frame
	if mask_falling && !is_mask_held:
		clean_mask.position.y += 0.01
		print(clean_mask.position)
		var ws = globalwind.wind_strength
		if ws < 5:
			if clean_mask.position.y > 25.0:
				set_emotion(1)
			if clean_mask.position.y > 30.0:
				set_emotion(5)
			if clean_mask.position.y > 40.0:
				set_emotion(11)
			if clean_mask.position.y > 45.0:
				set_emotion(3)

		# Out of screen
		if clean_mask.position.y >= mask_original_pos.y + 50.0:
			clean_mask.visible = false
			mask_lost_forever = true
			mask_falling = false
			
	if is_mask_held && clean_mask.position.y >= mask_original_pos.y:
		clean_mask.position.y -= 0.03
		if clean_mask.position.y < 21:
			mask_falling = false
			_schedule_mask_fall()
		
		

func _schedule_mask_fall() -> void:
	mask_timer = 0.0
	mask_trigger_time = randf_range(mask_fall_min_time, mask_fall_max_time)


# ========================
# COMBINED CONTROL
# ========================

func set_appearance(frame_index: int, cap: bool, mask: bool) -> void:
	set_emotion(frame_index)
	set_cap_visible(cap)
	set_mask_visible(mask)
