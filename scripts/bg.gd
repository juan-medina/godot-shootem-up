class_name Background extends ParallaxBackground

@export var scroll_speed: int = 300


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	scroll_offset.x -= scroll_speed * delta
