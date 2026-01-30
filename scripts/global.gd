extends Node


# DEFINE SIGNALS HERE
#signal respawn_marble(instance_id)
#signal released_value(team_id, value)

var teams = [] # [COLOR_NAME, AMOUNT_OF_MARBLES]
const marble_start_value = 1

# RUNS EVERY FRAME
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	pass

# ON STARTUP
func _ready() -> void:
	pass

# DEFINE FUNCTIONS HERE
