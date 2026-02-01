extends ProgressBar

@onready var alert_label: Label = $"../alert_label" # Adjust path to your Label node
const COOLDOWN_MS: float = 30000.0

func _process(_delta: float) -> void:
	var current_time = Time.get_ticks_msec()
	var elapsed = current_time - Global.lastCameraSpotted
	
	if elapsed < COOLDOWN_MS:
		# Show the UI elements
		self.show()
		alert_label.show()
		global.wanted_level.emit(true)
		
		# Calculate and set the progress
		var ratio = 1.0 - (elapsed / COOLDOWN_MS)
		self.value = ratio * 100
	else:
		# Hide everything once the 30 seconds are up
		self.hide()
		alert_label.hide()
		self.value = 0
		global.wanted_level.emit(false)
