extends Node2D

@onready var melt_rect: ColorRect = $CanvasLayer3/doom_effect

var melting := false
var timer := 0.0
var melt_speed := 0.5
var target_scene_path := ""

func _ready() -> void:
	melt_rect.hide()

func _process(delta: float) -> void:
	if melting:
		timer += delta * melt_speed
		melt_rect.material.set_shader_parameter("timer", timer)
		
		# Once the screen is fully melted (timer > max offset)
		if timer > 1:
			get_tree().change_scene_to_file(target_scene_path)

func start_doom_melt(next_scene: String) -> void:
	target_scene_path = next_scene
	
	# 1. Capture the current screen to "freeze" it
	var img = get_viewport().get_texture().get_image()
	var tex = ImageTexture.create_from_image(img)
	melt_rect.material.set_shader_parameter("melt_tex", tex)
	
	# 2. Generate random offsets for the strips
	var offsets = []
	for i in 64:
		offsets.append(randf_range(1.0, 2.0))
	melt_rect.material.set_shader_parameter("y_offsets", offsets)
	
	# 3. Start the animation
	timer = 0.0
	melt_rect.material.set_shader_parameter("melting", true)
	melt_rect.show()
	melting = true

# --- Button Connections ---

func _on_play_pressed() -> void:
	start_doom_melt("res://scenes/gameloop/game.tscn")

func _on_tutorial_pressed() -> void:
	start_doom_melt("res://scenes/start/tutorial.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
