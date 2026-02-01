extends Node

signal missions_available
signal victory

var paper : newspaper
var possible_missions
var score = 0
var target_score = 20

func _ready() -> void:
	possible_missions = ResourceLoader.load("res://Missions/available_missions/mission_list.tres")

func mission_activated():
	print("mission_activated")
	missions_available.emit(false)

func mission_finished(success: bool):
	if success: score += 1
	else: score -= 1
	if score >= target_score: victory.emit()
	missions_available.emit(true)
	update_paper()

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


func update_paper():
	if paper == null: return
	paper.set_title("Score: " + str(score))

func set_paper(val: newspaper):
	paper = val
