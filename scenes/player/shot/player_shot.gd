class_name PlayerShot extends Area2D


@export var speed: Vector2 = Vector2(700, 0)


var firing_from: Node2D = null


func init(from: Node2D) -> void:
	firing_from = from
	global_position = from.global_position


func _process(delta: float) -> void:
	global_position += speed * delta


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
