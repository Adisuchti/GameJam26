extends Control

# --- CONFIGURATION ---
# Drag your tutorial images here in the Inspector
@export var tutorial_images: Array[Texture2D] 

# Select the scene to load after the tutorial ends
@export_file("*.tscn") var next_scene_path: String 

# --- INTERNAL VARIABLES ---
var current_index: int = 0

# --- NODE REFERENCES ---
# Make sure the name matches your node structure, or assign via Inspector
@onready var texture_rect: TextureRect = $TextureRect 

func _ready() -> void:
	# specific check to prevent errors if you forgot to add images
	if tutorial_images.is_empty():
		push_error("No tutorial images assigned in the Inspector!")
		return
	
	# Load the very first image immediately
	update_image()

func _on_next_button_pressed() -> void:
	# Increment the index
	current_index += 1
	
	# Check if we still have images left to show
	if current_index < tutorial_images.size():
		update_image()
	else:
		# If we have run out of images, change the scene
		change_to_next_scene()

func update_image() -> void:
	texture_rect.texture = tutorial_images[current_index]

func change_to_next_scene() -> void:
	if next_scene_path != "":
		get_tree().change_scene_to_file(next_scene_path)
	else:
		print("Tutorial finished, but no 'Next Scene' path was assigned.")
