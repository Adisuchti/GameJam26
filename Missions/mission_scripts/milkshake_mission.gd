extends abstract_mission
@export
var target: PackedScene


func on_interaction():
	if is_active or global_position.distance_to(camera.global_position) > interaction_distance:
		print("can't interact: " + str(global_position.distance_to(camera.global_position)))
		return
	else:
		is_active = true
		hide_markers()
		spawn_goal()

func spawn_goal():
	var player : Node = get_tree().get_first_node_in_group("Player")
	if player: print("FOUND PLAYER")
	var m = target.instantiate()
	player.add_child(m)
	m.global_position = player.global_position
	m.target_hit.connect(on_completed)
