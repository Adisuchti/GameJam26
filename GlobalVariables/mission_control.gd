extends Node

signal missions_available
var possible_missions

func _ready() -> void:
	possible_missions = ResourceLoader.load("res://Missions/available_missions/mission_list.tres")

func mission_activated():
	missions_available.emit(false)

func mission_finished():
	missions_available.emit(true)

func get_random_mission() -> PackedScene:
	return possible_missions.list[randi_range(0, possible_missions.list.size() - 1)]

func spawn_mission() -> void:
	var spawn_locations : Array[Node] = get_tree().get_nodes_in_group("MissionSpawner")
	if spawn_locations.size() < 1: 
		print("MISSION_CONTROL ERROR: No available mission spawn locations!")
		return
	
	var mission = get_random_mission().instantiate()
	var loc = spawn_locations[randi_range(0, spawn_locations.size() - 1)]
	loc.add_child(mission)
	mission.global_position = loc.global_position
	mission_activated()
