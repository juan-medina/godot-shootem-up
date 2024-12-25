class_name PlayerShot extends Area2D


@export var speed: Vector2 = Vector2(700, 0)
@export var damage: int = 1


@onready var shot_explosion: AnimatedSprite2D = $ShotExplosion
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var shot_hit: AudioStreamPlayer2D = $ShotHit


var direction: Vector2 = Vector2(1, 0)


func init(from: Node2D) -> void:
	global_position = from.global_position


func _process(delta: float) -> void:
	global_position += direction * speed * delta


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func destroy() -> void:
	direction = Vector2.ZERO
	collision_shape.set_deferred("disabled", true)
	sprite.visible = false
	shot_explosion.visible = true
	shot_explosion.play()
	shot_hit.play()


func _on_shot_explosion_animation_finished() -> void:
	queue_free()
