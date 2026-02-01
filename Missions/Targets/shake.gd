extends Node2D

signal target_hit

@onready
var anim_player : AnimationPlayer = $AnimationPlayer

@export
var lifetime = 2.0
@export
var speed = 400
var direction: Vector2 = Vector2(1, 1)
var moving = false

func _ready() -> void:
	$Shake.visible = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("MouseButton"):
		throw(get_global_mouse_position() - global_position)

func throw(_direction: Vector2):
	moving = true
	direction = _direction
	anim_player.play("spin")
	$Explosion.visible = true

func _process(delta: float) -> void:
	if not moving: return
	lifetime -= delta
	if lifetime < 0: anim_player.play("Despawn")
	global_position = global_position + (direction.normalized() * delta * speed)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not moving: return
	if body.is_in_group("Enemies"):
		success()
	elif body.is_in_group("Player"):
		return
	else: 
		fail()

func success():
	target_hit.emit(true)
	anim_player.play("Despawn")

func fail():
	target_hit.emit(false)
	anim_player.play("Despawn")
