extends abstract_interact

#the correct frames for newspaper stands are 793 (blue) and 795 (black)
@onready
var newspaperstand = $NewspaperStand
@export
var paper: PackedScene

func _ready() -> void:
	is_active = true
	MissionControl.missions_available.connect(toggle_active)

func on_interaction():
	if is_active:
		spawn_paper()
	else:
		print("no new missions")

func toggle_active(val: bool):
	if val:
		newspaperstand.frame = 793
		is_active = true
	else:
		newspaperstand.frame = 795
		is_active = false

func spawn_paper():
	var m = paper.instantiate()
	self.add_child(m)
	m.global_position = self.global_position
	MissionControl.item_manager.newspaper_nodes.append(m)
