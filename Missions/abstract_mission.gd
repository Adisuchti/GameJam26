extends Node2D

var on_screen_offset: Vector2 = Vector2(0.0, -50.0)
var screen_margin = 100.0
var camera : Camera2D

@onready
var marker = $MarkerObject
@onready
var interact = $InteractMarker

func _ready() -> void:
    camera  = get_viewport().get_camera_2d()

## makes sure the Arrow is always visible, even if the camera does not show the interact object
func _process(_delta: float) -> void:
    
    if camera == null: return
    
    var viewport_dimensions: Vector2 = get_viewport().get_visible_rect().size
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


func _input(event: InputEvent) -> void:
    if event.is_action_pressed("MouseButton"):
        if interact.get_rect().has_point(to_local(get_global_mouse_position())):
            print("event_pressed")
