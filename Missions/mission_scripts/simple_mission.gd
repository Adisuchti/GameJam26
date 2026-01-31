extends abstract_mission

func _ready() -> void:
	super._ready()
	print("I WAS SPAWNED!!!")

func on_interaction():
	on_completed()
