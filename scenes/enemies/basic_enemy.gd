class_name BasicEnemy extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var exhaust: AnimatedSprite2D = $Exhaust
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var ship_explosion: AnimatedSprite2D = $ShipExplosion
@onready var explosion_sound: AudioStreamPlayer2D = $ExplosionSound


@export var max_life: int = 1
@export var damage: int = 1
@export var speed: float = 250

var life: int = max_life

func _ready() -> void:
	exhaust.play()

func _on_area_entered(object: Area2D) -> void:
	if object is PlayerShot:
		object.destroy()
		damaged(object.damage)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		damaged(max_life)
		body.damaged(damage)

func damaged(amount: int) -> void:
	life -= amount
	add_hit_effect()
	if life <= 0:
		sprite.visible = false
		exhaust.visible = false
		collision_shape.set_deferred("disabled", true)
		ship_explosion.visible = true
		ship_explosion.play()
		explosion_sound.play()
		await ship_explosion.animation_finished
		queue_free()


@export var hit_duration: float = 1.0


@onready var hit_material: ShaderMaterial = preload("res://resources/materials/hit.tres")


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


func _physics_process(delta: float) -> void:
	position += Vector2.LEFT * speed * delta


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
