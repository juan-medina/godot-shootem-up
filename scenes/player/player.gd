class_name Player extends CharacterBody2D


@export var speed: Vector2 = Vector2(400, 400)
@export var fire_rate: float = 0.15


@onready var exhaust_anim = $Exhaust
@onready var shot_point = $ShotPoint
@onready var shot_sound = $ShotSound
@onready var shot_scene = preload("res://scenes/player/shot/player_shot.tscn")

@onready var half_size: Vector2 = $Ship.region_rect.size * scale / 2
@onready var clamp_max: Vector2 = get_viewport_rect().size
@onready var limit: Vector2 = clamp_max - half_size


var previous_direction: Vector2 = Vector2.ZERO
var previous_exhaust: String = "normal"
var shot_on_cd: bool = false


func _ready() -> void:
	exhaust_anim.play(previous_exhaust)


func _physics_process(_delta: float) -> void:
	move_logic()
	shot_logic()


func move_logic() -> void:
	var x_axis: float = Input.get_axis("left", "right")
	var y_axis: float = Input.get_axis("up", "down")

	var direction: Vector2 = Vector2(x_axis, y_axis)
	velocity = direction * speed

	if direction != previous_direction:
		direction_changed(direction)
		previous_direction = direction

	if direction != Vector2.ZERO:
		move_and_slide()
		position = position.clamp(half_size, limit)


func direction_changed(direction: Vector2) -> void:
	var exhaust: String = "normal"

	if direction.x > 0 || direction.y != 0:
		exhaust = "turbo"

	if previous_exhaust != exhaust:
		exhaust_anim.play(exhaust)
		previous_exhaust = exhaust

func shot_logic() -> void:
	if Input.is_action_pressed("fire") && !shot_on_cd:
		shot_on_cd = true
		shot()
		await get_tree().create_timer(fire_rate).timeout
		shot_on_cd = false


func shot() -> void:
	shot_sound.play()
	var shot_instance: PlayerShot = shot_scene.instantiate()
	shot_instance.init(shot_point)
	get_parent().add_child(shot_instance)
