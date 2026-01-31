@abstract
class_name abstract_interact
extends Node2D

@onready
var interaction_marker = $InteractionMarker

@export
var interaction_distance = 200
var is_active = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("MouseButton"):
		if interaction_marker.get_rect().has_point(to_local(get_global_mouse_position())):
			on_interaction()

@abstract
func on_interaction()
