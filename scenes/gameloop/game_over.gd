extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_pressed() -> void:

	global.lastCameraSpotted = -1000000;

global.mask_down = true
global.cap_lost = false
global.mask_hidden = true
global.cap_hide.emit()
global.cap_picked_up.emit()
global.mask_restored.emit()
global.mask_hide.emit()

get_tree().change_scene_to_file("res://scenes/gameloop/game.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
