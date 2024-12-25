class_name Background extends ParallaxBackground

@export var scroll_speed: int = 150


func _process(delta: float) -> void:
	scroll_offset.x -= scroll_speed * delta
