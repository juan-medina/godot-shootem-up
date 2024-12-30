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

class_name Menu
extends Control
## Menu scene
##
## This is the main menu scene

@onready var game_scene: PackedScene = preload("res://scenes/game/game.tscn")  ## Game scene
@onready var main_menu: MainMenu = $MainMenu  ## Main menu
@onready var background: Background = $Background  ## Background
@onready var music: AudioStreamPlayer2D = $Music  ## Music


# Called when the main menu is added to the scene
func _ready() -> void:
	main_menu.visible = true


## Called every frame, delta is the elapsed time since the previous frame
func _process(_delta: float) -> void:
	# if the escape key is pressed, exit
	if Input.is_action_just_pressed("ui_cancel"):
		exit()


## Called when a button is clicked in the main menu
func _on_main_menu_button_click(button: Button) -> void:
	match button:
		main_menu.play_button:
			play_game()
		main_menu.exit_button:
			exit()


## Call to Play the game
func play_game() -> void:
	# fade out, stop the music and go to game scene
	FadeOutInGlobal.play()
	await FadeOutInGlobal.out_ended
	music.stop()
	if not get_tree().change_scene_to_packed(game_scene) == OK:
		assert(false, "Could not change to game scene")


## Call to exit the game
func exit() -> void:
	get_tree().quit()
