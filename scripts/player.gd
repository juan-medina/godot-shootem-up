class_name Player extends CharacterBody2D

@export var speed: int = 650

signal direction_changed(direction: Vector2)
var previous_direction: Vector2 = Vector2.ZERO


func _process(delta: float) -> void:
	calculate_anim(delta)


func _physics_process(_delta: float) -> void:
	var x_axis: float = Input.get_axis("left", "right")
	var y_axis: float = Input.get_axis("up", "down")

	var direction: Vector2 = Vector2(x_axis, y_axis)
	velocity = direction * speed

	if direction != previous_direction:
		direction_changed.emit(direction)
		previous_direction = direction

	move_and_slide()
	clamp_position()


const idle_frame: int = 0
const up_frame: int = 6
const down_frame: int = 6

var current_frame: float = idle_frame
var desired_frame: float = idle_frame

@onready var ship_anim = $Ship


func calculate_anim(delta: float) -> void:
	var frame_dir: float = desired_frame - current_frame

	if frame_dir != 0:
		frame_dir = frame_dir / abs(frame_dir)

	current_frame += frame_dir * delta * 10

	ship_anim.frame = roundi(current_frame)


@onready var clamp_max: Vector2 = get_viewport_rect().size


func clamp_position() -> void:
	var current_animation: String = ship_anim.animation
	var sprite_texture = ship_anim.sprite_frames.get_frame_texture(current_animation, ship_anim.frame)
	var half_size = sprite_texture.get_size() / 2 * ship_anim.scale
	position = position.clamp(half_size, clamp_max - half_size)


var previous_exhaust: String = "low"
@onready var exhaust_anim = $exhaust


func _on_direction_changed(direction: Vector2) -> void:
	if direction.y > 0:
		desired_frame = up_frame
	elif direction.y < 0:
		desired_frame = down_frame
	else:
		desired_frame = idle_frame

	var exhaust: String = "low"

	if direction.x > 0 || direction.y != 0:
		exhaust = "high"

	if previous_exhaust != exhaust:
		exhaust_anim.play(exhaust)
		previous_exhaust = exhaust

