extends abstract_mission
@export
var mission: PackedScene

func on_interaction():
	if is_active or global_position.distance_to(camera.global_position) > interaction_distance:
		print("can't interact: " + str(global_position.distance_to(camera.global_position)))
		return
	else:
		is_active = true
		hide_markers()
		spawn_goal()

func spawn_goal():
	var spawn_locations : Array[Node] = get_tree().get_nodes_in_group("MissionSpawner")
	if spawn_locations.size() < 1: 
		print("TARGET ERROR: No available target spawn locations!")
		return
	var loc = spawn_locations[randi_range(0, spawn_locations.size() - 1)]
	#TODO: reroll if the target is also the mission area
	var m = mission.instantiate()
	get_parent().add_child(m)
	m.global_position = loc.global_position
	m.goal_achieved.connect(on_completed)
