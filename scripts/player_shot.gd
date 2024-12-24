class_name PlayerShot extends Area2D


@export var speed: int = 600


@onready var anim = $AnimatedSprite2D


var direction: Vector2 = Vector2.ZERO
var firing_from: Node2D = null


func init(new_position: Vector2, from: Node2D) -> void:
	firing_from = from
	global_position = new_position


func _ready() -> void:
	anim.play()


func _process(delta: float) -> void:
	if direction == Vector2.ZERO:
		global_position.y = firing_from.global_position.y
		global_position.x = firing_from.global_position.x
	else:
		global_position += direction * speed * delta


func _on_animated_sprite_2d_animation_finished() -> void:
	direction = Vector2(1, 0)


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
