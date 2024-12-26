class_name Game extends Node2D

@export var spawn_default_timer: float = 0.5


@onready var enemies_spawn_timer: Timer = $EnemiesSpawn
@onready var enemy: PackedScene = preload("res://scenes/enemies/basic_enemy.tscn")
@onready var ui: UI = $CanvasLayer/UI

func _ready() -> void:
	enemies_spawn_timer.start(spawn_default_timer)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	elif Input.is_action_just_pressed("toggle_fullscreen"):
		var current_mode: int = DisplayServer.window_get_mode()
		if current_mode == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_size(get_viewport_rect().size)


func _on_enemies_spawn_timeout() -> void:

	var enemy_instance: BasicEnemy = enemy.instantiate()
	var max_viewport: Vector2 = get_viewport_rect().size
	var y_range = (max_viewport.y / 2) * 0.7
	var spawn_position: Vector2 = Vector2(max_viewport.x + 50, max_viewport.y / 2 + randf_range(-y_range, y_range))
	enemy_instance.global_position = spawn_position
	enemy_instance.destroyed.connect(_on_enemy_died.bind())
	add_child(enemy_instance)
	enemies_spawn_timer.start(spawn_default_timer + randf_range(0, 0.5))

func _on_enemy_died(points: int) -> void:
	ui.points += points


func _on_player_shields_changed(current_shields: int) -> void:
	ui.shields = current_shields
