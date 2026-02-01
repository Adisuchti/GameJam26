extends Node2D

@onready var video: VideoStreamPlayer = $Video

const VIDEOS := [
	"res://assets/intro1.ogv",
	"res://assets/intro2.ogv",
	"res://assets/intro3.ogv"
]

func _ready() -> void:
	video.visible = false
	video.loop = false
	video.autoplay = false

	# Pick random video
	var path: String = VIDEOS.pick_random()
	video.stream = load(path)

	# --- WARM-UP (prevents lag) ---
	video.volume_db = -80
	video.play()

	await get_tree().process_frame

	video.stop()
	video.volume_db = 0

	# --- ACTUAL PLAY ---
	video.visible = true
	video.play()


func _on_video_finished() -> void:
	get_tree().change_scene_to_file("res://scenes/start/mainpage.tscn")


func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/start/mainpage.tscn")


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/start/mainpage.tscn")
