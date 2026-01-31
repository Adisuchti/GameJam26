extends Node

# ========================
# ASSIGN IN INSPECTOR
# ========================

@export var player: Node2D
@export var player_cap: Node2D          # hat on player's head
@export var dropped_cap_scene: PackedScene
@export var newspaper_nodes: Array[Node2D] = []

@export var pickup_distance := 20.0     # how close player must be

# ========================
# INTERNAL STATE
# ========================

var dropped_cap: Node2D = null
var cap_lost := false


# ========================
# PUBLIC API
# ========================

func cap_fell_off() -> void:
	"""
	Call this when the hat flies off the player
	"""
	if cap_lost:
		return

	cap_lost = true
	player_cap.visible = false

	_spawn_dropped_cap()


# ========================
# PROCESS
# ========================

func _process(_delta: float) -> void:
	if cap_lost and dropped_cap:
		_check_pickup()


# ========================
# SPAWNING
# ========================

func _spawn_dropped_cap() -> void:
	if dropped_cap_scene == null:
		push_error("Dropped cap scene not assigned!")
		return

	dropped_cap = dropped_cap_scene.instantiate()
	add_child(dropped_cap)

	# Pick random newspaper (or fallback to player)
	var spawn_pos: Vector2
	if newspaper_nodes.size() > 0:
		var paper = newspaper_nodes.pick_random()
		spawn_pos = paper.global_position
	else:
		spawn_pos = player.global_position

	dropped_cap.global_position = spawn_pos


# ========================
# PICKUP CHECK
# ========================

func _check_pickup() -> void:
	var dist := player.global_position.distance_to(dropped_cap.global_position)

	if dist <= pickup_distance:
		_pickup_cap()


# ========================
# PICKUP LOGIC
# ========================

func _pickup_cap() -> void:
	cap_lost = false

	if dropped_cap:
		dropped_cap.queue_free()
		dropped_cap = null

	player_cap.visible = true
