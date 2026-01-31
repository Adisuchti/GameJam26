extends Node2D

@onready var label = $PanelContainer/label
@onready var container = $PanelContainer

func _ready():
	hide() # Start invisible

func display_text(text_to_display: String):
	label.text = text_to_display
	
	# Center the bubble above the character
	container.position.x = -container.size.x / 2
	container.position.y = -container.size.y - 20 # 20px offset
	
	show()
	
	# Optional: Auto-hide after 3 seconds
	await get_tree().create_timer(3.0).timeout
	hide()
