# Copyright (c) 2024 Juan Medina
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

class_name Game
extends Node2D
## Game scene

@export var spawn_default_timer: float = 0.5

@onready var enemies_spawn_timer: Timer = $EnemiesSpawn
@onready var ui: UI = $CanvasLayer/UI
@onready var enemy1: PackedScene = preload("res://scenes/enemies/basic_enemy/basic_enemy.tscn")
@onready var enemy2: PackedScene = preload("res://scenes/enemies/kamikaze/kamikaze.tscn")


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
	var enemy_instance: BasicEnemy = enemy1.instantiate() if randf() < 0.7 else enemy2.instantiate()

	var max_viewport: Vector2 = get_viewport_rect().size
	var y_range: float = (max_viewport.y / 2) * 0.7
	var spawn_position: Vector2 = Vector2(
		max_viewport.x + 50, max_viewport.y / 2 + randf_range(-y_range, y_range)
	)
	enemy_instance.global_position = spawn_position
	if not enemy_instance.destroyed.connect(_on_enemy_died.bind()) == OK:
		assert(false, "Failed to connect to enemy destroyed signal")
	add_child(enemy_instance)
	enemies_spawn_timer.start(spawn_default_timer + randf_range(0, 0.5))


func _on_enemy_died(points: int) -> void:
	ui.points += points


func _on_player_shields_changed(current_shields: int) -> void:
	ui.shields = current_shields
