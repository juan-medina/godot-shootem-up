class_name BasicEnemy extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var exhaust: AnimatedSprite2D = $Exhaust
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var ship_explosion: AnimatedSprite2D = $ShipExplosion
@onready var explosion_sound: AudioStreamPlayer2D = $ExplosionSound
@onready var hit_material: ShaderMaterial = preload("res://resources/materials/hit.tres")
@onready var points_label: Label = $Points


@export var max_life: int = 1
@export var damage: int = 1
@export var speed: float = 250
@export var points: int = 150
@export var hit_duration: float = 1.0


signal destroyed(points: int)


var life: int = max_life
var direction: Vector2 = Vector2.LEFT
var player: Player = null
var on_screen: bool = false
var initial_speed: float = speed


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	exhaust.play("normal")
	life = max_life
	points_label.text = str(points)
	initial_speed = speed


func _on_area_entered(object: Area2D) -> void:
	if not on_screen: return
	if object is PlayerShot:
		object.destroy()
		damaged(object.damage)

func _on_body_entered(body: Node2D) -> void:
	if not on_screen: return
	if body is Player:
		damaged(max_life)
		body.damaged(damage)

func damaged(amount: int) -> void:
	life -= amount
	add_hit_effect()
	if life <= 0:
		sprite.visible = false
		exhaust.visible = false
		points_label.visible = true
		collision_shape.set_deferred("disabled", true)
		ship_explosion.visible = true
		ship_explosion.play()
		explosion_sound.play()
		destroyed.emit(points)
		await ship_explosion.animation_finished
		queue_free()


func add_hit_effect() -> void:
	self.material = hit_material
	await get_tree().create_timer(hit_duration).timeout
	self.material = null


func _physics_process(delta: float) -> void:
	position += direction * (speed if sprite.visible else initial_speed) * delta


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	on_screen = true


var turbo: bool = false:
	set(value):
		turbo = value
		exhaust.play("turbo" if turbo else "normal")


func is_player_on_line_of_sight() -> bool:
	if not is_instance_valid(player): return false
	var player_half_height: float = player.ship.texture.get_height() / 2.0

	var player_top_y: float = player.global_position.y - player_half_height
	var player_bottom_y: float = player.global_position.y + player_half_height

	return (global_position.y >= player_top_y) and (global_position.y <= player_bottom_y)
