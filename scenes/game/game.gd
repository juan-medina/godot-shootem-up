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

enum EnergyType { BLUE, GREEN, DEPLETED }  ## Energy type
## Energy type color
const ENERGY_TYPE_COLOR: Dictionary = {
	EnergyType.BLUE: Color(0, 1, 1, 1), EnergyType.GREEN: Color(0, 1, 0, 1), EnergyType.DEPLETED: Color(1, 0, 0, 1.0)
}

var _total_waves: int = 0  ## total waves in the level
var _points: int = 0  ## points in the game

@onready var ui: UI = $CanvasLayer/UI  ## the in-game UI
@onready var music: AudioStreamPlayer2D = $Music  ## the game music
@onready var game_over_sound: AudioStreamPlayer2D = $GameOver  ## sound for game over
@onready var game_win_sound: AudioStreamPlayer2D = $GameWin  ## sound for game win
@onready var menu_scene: PackedScene = load("res://scenes/menu/menu.tscn")  ## the menu scene
@onready var level_scene: PackedScene = preload("res://scenes/level/level.tscn")  ## the level scene
@onready var test_level_scene: PackedScene = preload("res://scenes/level/test_level.tscn")  ## the test level scene
@onready var player: Player = $Player  ## the player


## When the game is added to the scene
func _ready() -> void:
	# instantiate the level scene
	var scene_to_create: PackedScene = test_level_scene if GlobalConfig.current_values.test_level else level_scene
	var level: Node2D = scene_to_create.instantiate()
	add_child(level)
	level.position.x += 1500

	## get all the waves and connect the enemy_die signal
	var waves: Array[Node] = level.find_children("*", "Wave")
	for wave: Wave in waves:
		_total_waves += 1
		if wave.enemy_die.connect(_on_enemy_died) != OK:
			assert(false, "Error connecting enemy_die signal")

		if wave.wave_destroyed.connect(_on_wave_destroyed) != OK:
			assert(false, "Error connecting wave_destroyed signal")


## Called when an enemy is destroyed
func _on_enemy_died(points: int) -> void:
	# update the points in the UI
	_points += points
	ui.points = _points


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


## Called when we need to reload the level
func _reload_level() -> void:
	# fade out and reload the scene
	EffectsGlobal.fade_out_in()
	await EffectsGlobal.out_ended
	var reload: int = get_tree().reload_current_scene()
	if not reload == OK:
		assert(false, "Failed to reload scene")


## Called when the we need to go to the menu
func _go_to_menu() -> void:
	# stop the music, fade out and go to the menu
	music.stop()
	EffectsGlobal.fade_out_in()
	await EffectsGlobal.out_ended
	if not get_tree().change_scene_to_packed(menu_scene) == OK:
		assert(false, "Could not change to menu scene")


## Called when the player energy type changes
func _on_player_energy_type_changed(energy_type: Game.EnergyType) -> void:
	# update the shields energy type in the UI
	ui.shields_energy = energy_type


## Called when a wave is destroyed
func _on_wave_destroyed() -> void:
	# reduce the total waves and if there are no more waves, wait 5 seconds and go to the menu
	_total_waves -= 1
	if _total_waves == 0:
		game_win()


## Called when the player win the game
func game_win() -> void:
	# stop the music, play the game win sound and show the game win screen
	player.won = true
	music.stop()
	game_win_sound.play()

	# get the high score from the scores file

	var config: ConfigFile = ConfigFile.new()
	if not config.load("user://score.cfg") == OK:
		pass

	var high_score: int = config.get_value("score", "high_score", 0)
	if _points > high_score:
		high_score = _points
		config.set_value("score", "high_score", high_score)
		if not config.save("user://score.cfg") == OK:
			pass

	ui.game_win(high_score, _points)
