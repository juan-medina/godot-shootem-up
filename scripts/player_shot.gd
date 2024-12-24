class_name PlayerShot extends Area2D


@export var speed: Vector2 = Vector2(600, 0)


@onready var anim = $AnimatedSprite2D


var direction: Vector2 = Vector2.ZERO
var firing_from: Node2D = null


func init(from: Node2D) -> void:
	firing_from = from
	global_position = from.global_position


func _ready() -> void:
	anim.play()


func _process(delta: float) -> void:
	global_position = (
		firing_from.global_position if direction == Vector2.ZERO
		else global_position + direction * speed * delta
	)


func _on_animated_sprite_2d_animation_finished() -> void:
	direction = speed.normalized()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
