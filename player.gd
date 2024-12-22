extends CharacterBody2D

@export var speed = 650

func _physics_process(delta: float) -> void:
	var x_axis = Input.get_axis("left", "right")
	var y_axis = Input.get_axis("up", "down")

	var direction = Vector2(x_axis, y_axis)
	velocity = direction * speed

	calculate_anim(direction, delta)

	move_and_slide()

	clamp_position()


const idle_frame = 0
const up_frame = 6
const down_frame = 6

var current_frame = idle_frame
var desired_frame = idle_frame

@onready var ship_anim = $Ship
@onready var exhaust_anim = $exhaust


func calculate_anim(direction, delta):
	if direction.y > 0:
		desired_frame = up_frame
	elif direction.y < 0:
		desired_frame = down_frame
	else:
		desired_frame = idle_frame

	var frame_dir = desired_frame - current_frame

	if frame_dir != 0:
		frame_dir = frame_dir / abs(frame_dir)

	current_frame += frame_dir * delta * 10

	ship_anim.frame = roundi(current_frame)

	if direction.x > 0 || direction.y != 0:
		exhaust_anim.play("high")
	else:
		exhaust_anim.play("low")


const clamp_max = Vector2(1920, 1080)


func clamp_position():
	var current_animation: String = ship_anim.animation
	if current_animation != "":
		var sprite_texture = ship_anim.sprite_frames.get_frame_texture(current_animation, ship_anim.frame)
		var half_size = sprite_texture.get_size() / 2 * ship_anim.scale
		position = position.clamp(half_size, clamp_max - half_size)
