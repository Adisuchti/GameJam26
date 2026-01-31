extends Node2D

@onready var frame: Sprite2D = $Frame
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animated_sprite_2d_2: AnimatedSprite2D = $AnimatedSprite2D2
@onready var clean_mask: Sprite2D = $CleanMask
@onready var clean_cap: Sprite2D = $CleanCap


func _ready() -> void:
	# Default visibility
	clean_mask.visible = false
	clean_cap.visible = false
	set_emotion(0)


# ========================
# EMOTION CONTROL
# ========================

func set_emotion(frame_index: int) -> void:
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


# ========================
# CAP CONTROL
# ========================

func show_cap() -> void:
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
