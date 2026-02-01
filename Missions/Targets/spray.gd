class_name abstract_goal
extends abstract_mission

signal goal_achieved

@onready
var anim_player : AnimationPlayer = $AnimationPlayer

func on_interaction():
	if is_active or global_position.distance_to(camera.global_position) > interaction_distance:
		print("can't interact: " + str(global_position.distance_to(camera.global_position)))
		return
	else:
		is_active = true
		goal_achieved.emit(true)
		on_completed(true)


func on_completed(val: bool):
	anim_player.play("Despawn")
