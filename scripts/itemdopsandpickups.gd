extends Node

# ========================
# ASSIGN IN INSPECTOR
# ========================

@export var player: Node2D
@export var dropped_cap_scene: PackedScene
@export var newspaper_nodes: Array[Node2D] = []

@export var pickup_distance := 50.0     # how close player must be

# ========================
# INTERNAL STATE
# ========================

var cap: Node2D = null


# ========================
# PROCESS
# ========================

func _process(_delta: float) -> void:
	if cap:
		_check_pickup()

func _ready():
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
	var dist = player.global_position.distance_to(cap.global_position + Vector2(150.0, 0))
	#print(dist)

	if dist <= pickup_distance:
		_pickup_cap()


# ========================
# PICKUP LOGIC
# ========================

func _pickup_cap() -> void:
	if cap:
		cap.queue_free()
		cap = null
		global.cap_picked_up.emit()
