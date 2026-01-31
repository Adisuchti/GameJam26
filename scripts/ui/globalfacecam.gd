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

func _ready() -> void:
	# Default visibility
	clean_mask.visible = false
	clean_cap.visible = true
	set_emotion(0)
	cap_original_pos = clean_cap.position

	# Ensure video is paused initially
	video_stream_player.visible = false

	# Connect input signals for cap
	clean_cap.set_process_input(true)


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


func _process(delta: float) -> void:
	_apply_wind_effects(delta)
	if cap_is_forever_gone:
		clean_cap.visible = false


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
	else:
		set_emotion(0)
		
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
		set_emotion(0)


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
	clean_mask.visible = true

func hide_mask() -> void:
	clean_mask.visible = false

func set_mask_visible(value: bool) -> void:
	clean_mask.visible = value


# ========================
# COMBINED CONTROL
# ========================

func set_appearance(frame_index: int, cap: bool, mask: bool) -> void:
	set_emotion(frame_index)
	set_cap_visible(cap)
	set_mask_visible(mask)
