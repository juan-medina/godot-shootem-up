class_name Game extends Node2D

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	elif Input.is_action_just_pressed("toggle_fullscreen"):
		var currrent_mode: int = DisplayServer.window_get_mode()
		if currrent_mode == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_size(get_viewport_rect().size)
	move_background(delta)


@onready var bg = $BG
@export var scroll_speed : int = 300

func move_background(delta):
	bg.scroll_offset.x -= scroll_speed * delta
