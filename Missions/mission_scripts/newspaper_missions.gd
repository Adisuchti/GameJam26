extends abstract_interact

#the correct frames for newspaper stands are 793 (blue) and 795 (black)
@onready
var newspaperstand = $NewspaperStand


func _ready() -> void:
	is_active = true
	MissionControl.missions_available.connect(toggle_active)

func on_interaction():
	if is_active:
		MissionControl.spawn_mission()
		var news = global.get_random_headline()
		global.changeNewspaper.emit(news)
	else:
		print("no new missions")

func toggle_active(val: bool):
	if val:
		newspaperstand.frame = 793
		is_active = true
	else:
		newspaperstand.frame = 795
		is_active = false
