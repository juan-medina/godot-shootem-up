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
##
## This is the main game scene, here we will play the game

@export var spawn_default_timer: float = 0.5  ## how often the enemies will spawn

@onready var enemies_spawn_timer: Timer = $EnemiesSpawn  ## Timer to spawn enemies
@onready var ui: UI = $CanvasLayer/UI  ## the in-game UI
@onready var music: AudioStreamPlayer2D = $Music  ## the game music
@onready var game_over_sound: AudioStreamPlayer2D = $GameOver  ## sound for game over
@onready var enemy1: PackedScene = preload("res://scenes/enemies/basic_enemy/basic_enemy.tscn")  ## the basic enemy
@onready var enemy2: PackedScene = preload("res://scenes/enemies/kamikaze/kamikaze.tscn")  ## the kamikaze enemy


## Called when the game is added
func _ready() -> void:
	## start the timer to spawn enemies
	enemies_spawn_timer.start(spawn_default_timer)


## Called every frame, delta is the elapsed time since the previous frame
func _process(_delta: float) -> void:
	# if the escape key is pressed, quit
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

	# if the fullscreen key is pressed, toggle fullscreen
	elif Input.is_action_just_pressed("toggle_fullscreen"):
		var current_mode: int = DisplayServer.window_get_mode()
		if current_mode == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			# if we are restoring windowed we need to restore the size
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_size(get_viewport_rect().size)


## Called when we need to spawn an enemy
func _on_enemies_spawn_timeout() -> void:
	# spawn a random enemy, 70% basic, 30% kamikaze
	var enemy_instance: BasicEnemy = enemy1.instantiate() if randf() < 0.7 else enemy2.instantiate()

	# spawn the enemy at a random position, 70% on the viewport height and outside of the viewport width
	var max_viewport: Vector2 = get_viewport_rect().size
	var y_range: float = (max_viewport.y / 2) * 0.7
	var spawn_position: Vector2 = Vector2(max_viewport.x + 50, max_viewport.y / 2 + randf_range(-y_range, y_range))
	enemy_instance.global_position = spawn_position

	# connect the enemy destroyed signal
	if not enemy_instance.destroyed.connect(_on_enemy_died.bind()) == OK:
		assert(false, "Failed to connect to enemy destroyed signal")

	# add the enemy to the scene
	add_child(enemy_instance)

	# start the timer to spawn the next enemy, with a random delay
	enemies_spawn_timer.start(spawn_default_timer + randf_range(0, 0.5))


## Called when an enemy is destroyed
func _on_enemy_died(points: int) -> void:
	# update the points in the UI
	ui.points += points


## Called when the player's shields have changed
func _on_player_shields_changed(current_shields: int) -> void:
	# update the shields in the UI
	ui.shields = current_shields

	# if the player has no shields, wait 1 second and then game over
	if current_shields == 0:
		await get_tree().create_timer(1).timeout
		game_over()

## Called when the game is over
func game_over() -> void:
	# stop the music, play the game over sound and show the game over screen
	music.stop()
	game_over_sound.play()
	ui.game_over()

## Called when the game over screen ok button is pressed
func _on_ui_game_over_ok() -> void:
	# fade out and reload the scene
	FadeOutInGlobal.play()
	await FadeOutInGlobal.out_ended
	var reload: int = get_tree().reload_current_scene()
	if not reload == OK:
		assert(false, "Failed to reload scene")

## Called when the game over screen cancel button is pressed
func _on_ui_game_over_cancel() -> void:
	# quit the game
	get_tree().quit()
