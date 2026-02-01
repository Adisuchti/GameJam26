extends Node
class_name item_manager

# ========================
# ASSIGN IN INSPECTOR
# ========================

@export var player: Node2D
@export var dropped_cap_scene: PackedScene
@export var newspaper_nodes: Array[Node2D] = []

@export var pickup_distance := 25.0     # how close player must be

# ========================
# INTERNAL STATE
# ========================

var cap: Node2D = null


# ========================
# PROCESS
# ========================

func _process(_delta: float) -> void:
	_check_pickup()

func _ready():
	MissionControl.item_man = self
	global.cap_fell_off.connect(_on_cap_fell_off)
	#await get_tree().process_frame
	#_spawn_dropped_cap()
	
func _on_cap_fell_off():
	_spawn_dropped_cap()


# ========================
# SPAWNING
# ========================

func _spawn_dropped_cap() -> void:
	if cap:
		return
	if dropped_cap_scene == null:
		push_error("Dropped cap scene not assigned!")
		return

	#Instantiate
	cap = dropped_cap_scene.instantiate()

	# Add to scene
	get_tree().current_scene.add_child(cap)
	cap.z_index = 1000
	
	# Set position
	if player:
		cap.global_position = player.global_position + Vector2(0, -32)
	else:
		cap.global_position = Vector2(1991.0, 739.0)


# ========================
# PICKUP CHECK
# ========================

func _check_pickup() -> void:
	if cap:
		var dist = player.global_position.distance_to(cap.global_position + Vector2(52, 0))
		if dist <= pickup_distance:
			_pickup_cap()
# Use a back-to-front loop when removing items from an array while iterating
	for i in range(newspaper_nodes.size() - 1, -1, -1):
		var newspaper_node = newspaper_nodes[i]
		
		# 1. Check if the node is still valid (not freed)
		if is_instance_valid(newspaper_node):
			var newspaper_dist = player.global_position.distance_to(newspaper_node.global_position + Vector2(52, 0))
			#print(newspaper_dist-pickup_distance)
			# 2. Only pick up if within distance (you were missing the distance check!)
			if newspaper_dist <= pickup_distance:
				_pickup_newsletter(newspaper_node)
				newspaper_nodes.remove_at(i) # Remove from array so we stop checking it
		else:
			# Clean up the array if the node was deleted elsewhere
			newspaper_nodes.remove_at(i)


# ========================
# PICKUP LOGIC
# ========================

func _pickup_cap() -> void:
	if cap:
		cap.queue_free()
		cap = null
		global.cap_picked_up.emit()
		

func _pickup_newsletter(newspaper_node: Node2D) -> void:
	if is_instance_valid(newspaper_node):
		MissionControl.spawn_mission()
		newspaper_node.queue_free()
		var news = global.get_random_headline()
		global.changeNewspaper.emit(news)
