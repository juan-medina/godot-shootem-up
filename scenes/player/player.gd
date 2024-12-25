class_name Player extends CharacterBody2D


@export var speed: Vector2 = Vector2(400, 400)
@export var fire_rate: float = 0.20
@export var max_life: int = 10


@onready var ship = $Ship
@onready var exhaust_anim: AnimatedSprite2D = $Exhaust
@onready var shot_point: Marker2D = $ShotPoint
@onready var shot_sound: AudioStreamPlayer2D = $ShotSound
@onready var shot_out_effect: AnimatedSprite2D = $ShotOutEffect
@onready var ship_explosion: AnimatedSprite2D = $ShipExplosion
@onready var shot_scene: PackedScene = preload("res://scenes/player/shot/player_shot.tscn")
@onready var hit_material: ShaderMaterial = preload("res://resources/materials/hit.tres")

@onready var half_size: Vector2 = ship.region_rect.size * scale / 2
@onready var clamp_max: Vector2 = get_viewport_rect().size
@onready var limit: Vector2 = clamp_max - half_size


var previous_direction: Vector2 = Vector2.ZERO
var previous_exhaust: String = "normal"
var shot_on_cd: bool = false
var current_life: int = max_life


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
	shot_out_effect.visible = true
	shot_out_effect.play()
	shot_sound.play()
	var shot_instance: PlayerShot = shot_scene.instantiate()
	shot_instance.init(shot_point)
	get_parent().add_child(shot_instance)


func _on_shot_out_effect_animation_finished() -> void:
	shot_out_effect.visible = false


func damaged(amount: int) -> void:
	add_hit_effect()
	current_life -= amount

	if current_life <= 0:
		ship.visible = false
		exhaust_anim.visible = false
		ship_explosion.visible = true
		ship_explosion.play()
		await ship_explosion.animation_finished
		queue_free()

@export var hit_duration: float = 1.0

var remove_material_timer: Timer = null


func add_hit_effect() -> void:
	if remove_material_timer == null:
		remove_material_timer = Timer.new()
		remove_material_timer.one_shot = true
		remove_material_timer.timeout.connect(_on_remove_material_timer_timeout.bind())
		add_child(remove_material_timer)

	if remove_material_timer.is_stopped():
		self.material = hit_material
	else:
		remove_material_timer.stop()
	remove_material_timer.start(hit_duration)

func _on_remove_material_timer_timeout() -> void:
	self.material = null