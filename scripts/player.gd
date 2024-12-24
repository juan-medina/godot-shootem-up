class_name Player extends CharacterBody2D


@export var speed: Vector2 = Vector2(400, 400)
@export var fire_rate: float = 0.15


@onready var exhaust_anim = $Exhaust
@onready var shot_point = $ShotPoint
@onready var shot_sound = $ShotSound
@onready var shot_scene = preload("res://scenes/player_shot.tscn")


var previous_direction: Vector2 = Vector2.ZERO
var previous_exhaust: String = "normal"
var shot_on_cd: bool = false


func _ready() -> void:
	exhaust_anim.play(previous_exhaust)


func _physics_process(_delta: float) -> void:
	var x_axis: float = Input.get_axis("left", "right")
	var y_axis: float = Input.get_axis("up", "down")

	var direction: Vector2 = Vector2(x_axis, y_axis)
	velocity = direction * speed

	if direction != previous_direction:
		direction_changed(direction)
		previous_direction = direction

	move_and_slide()
	clamp_position()

	if Input.is_action_pressed("fire") && !shot_on_cd:
		shot_on_cd = true
		shot_sound.play()
		var shot = shot_scene.instantiate()
		shot.init(global_position, shot_point)
		get_parent().add_child(shot)
		await get_tree().create_timer(fire_rate).timeout
		shot_on_cd = false


@onready var ship_sprite = $Ship
@onready var clamp_max: Vector2 = get_viewport_rect().size


func clamp_position() -> void:
	var half_size = ship_sprite.texture.get_size() / 2
	position = position.clamp(half_size, clamp_max - half_size)


func direction_changed(direction: Vector2) -> void:
	var exhaust: String = "normal"

	if direction.x > 0 || direction.y != 0:
		exhaust = "turbo"

	if previous_exhaust != exhaust:
		exhaust_anim.play(exhaust)
		previous_exhaust = exhaust
