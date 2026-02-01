extends Node2D

@onready var video: VideoStreamPlayer = $Video
@onready var icon: Sprite2D = $Icon

const VIDEOS := [
	"res://assets/intro1.ogv",
	"res://assets/intro2.ogv",
    "res://assets/intro3.ogv"
]

func _ready() -> void:
	# 1. Store the original position
	var target_pos = icon.position

	# 2. Teleport icon
	icon.position.y += 300 
	
	# 3. Create the smooth animation
	var tween = create_tween()
	tween.tween_property(icon, "position", target_pos, 3.0).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	icon.modulate.a = 0.0 
	tween.parallel().tween_property(icon, "modulate:a", 1.0, 1.5) 

	# --- Rest of your video logic ---
	video.visible = false
	video.loop = false
	video.autoplay = false

	# Pick random video
	var path: String = VIDEOS.pick_random()
	video.stream = load(path)

	# --- WARM-UP ---
	video.volume_db = -80
	video.play()

	await get_tree().process_frame

	video.stop()
	# CHANGE IS HERE: We keep it at -80 instead of setting it to 0
	video.volume_db = -80 

	# --- ACTUAL PLAY ---
	video.visible = true
	video.play()


func _on_video_finished() -> void:
	get_tree().change_scene_to_file("res://scenes/start/mainpage.tscn")


func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/start/mainpage.tscn")


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/start/mainpage.tscn")
