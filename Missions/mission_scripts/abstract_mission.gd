class_name abstract_mission
extends abstract_interact

var location: Vector2

var on_screen_offset: Vector2 = Vector2(0.0, -50.0)
var screen_margin = 100.0
var camera : Camera2D

@onready
var marker = $MarkerObject

func _ready() -> void:
	camera  = get_viewport().get_camera_2d()
	global_position = location

## makes sure the Arrow is always visible, even if the camera does not show the interact object
func _process(_delta: float) -> void:
	
	if camera == null: 
		print("ERROR: NO CAMERA FOUND")
		return
	
	var viewport_dimensions: Vector2 = get_viewport().get_visible_rect().size - Vector2(256, 0)
	var screen_coordinates = (global_position - camera.global_position) * camera.zoom + viewport_dimensions * 0.5
	var screen_inset_rectangle = Rect2(Vector2.ZERO, viewport_dimensions).grow(-screen_margin)
	
	var target_display_position
	var target_display_rotation
	
	if screen_inset_rectangle.has_point(screen_coordinates):
		target_display_position = global_position + on_screen_offset
		target_display_rotation = 0.0
	else:
		var clamped_x = clamp(screen_coordinates.x, screen_margin, viewport_dimensions.x - screen_margin)
		var clamped_Y = clamp(screen_coordinates.y, screen_margin, viewport_dimensions.y - screen_margin)
		var clamped_screen_coords = Vector2(clamped_x, clamped_Y)
		
		target_display_position = camera.global_position + (clamped_screen_coords - viewport_dimensions * 0.5) / camera.zoom

		var vector_to_target = global_position - target_display_position
		target_display_rotation = vector_to_target.angle() - PI * 0.5

	marker.global_position = target_display_position
	marker.rotation = target_display_rotation

func hide_markers():
	marker.visible = false
	interaction_marker.visible = false

func on_interaction():
	print("interaction started")


func on_completed(val: bool):
	MissionControl.mission_finished(val)
	self.queue_free()
