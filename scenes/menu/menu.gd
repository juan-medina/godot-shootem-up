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
@onready var about_menu: AboutMenu = $AboutMenu  ## About menu
@onready var options_menu: OptionsMenu = $OptionsMenu  ## Options menu
@onready var background: Background = $Background  ## Background
@onready var music: AudioStreamPlayer2D = $Music  ## Music


# Called when the main menu is added to the scene
func _ready() -> void:
	main_menu.visible = true


## Called when a button is clicked in the main menu
func _on_main_menu_button_click(button: Button) -> void:
	match button:
		main_menu.play_button:
			_play_game()
		main_menu.exit_button:
			_exit()
		main_menu.about_button:
			_about()
		main_menu.options_button:
			_options()


## Call to Play the game
func _play_game() -> void:
	# fade out, stop the music and go to game scene
	FadeOutInGlobal.play()
	await FadeOutInGlobal.out_ended
	music.stop()
	if not get_tree().change_scene_to_packed(game_scene) == OK:
		assert(false, "Could not change to game scene")


## Call to exit the game
func _exit() -> void:
	get_tree().quit()


## Open the about menu
func _about() -> void:
	about_menu.visible = true


## Open the about menu
func _options() -> void:
	options_menu.display_mode = GlobalConfig.display_mode
	options_menu.visible = true


## When a button is pressed in the about menu
func _on_about_menu_button_click(button: Button) -> void:
	match button:
		about_menu.back_button:
			main_menu.visible = true


## When a button is pressed in the options menu
func _on_options_menu_button_click(button: Button) -> void:
	## if the button is ok or apply, apply the options
	if button == options_menu.ok_button or button == options_menu.apply_button:
		_apply_options()

	## if the button is ok or back, show the main menu
	main_menu.visible = button == options_menu.ok_button or button == options_menu.back_button


## Apply the options
func _apply_options() -> void:
	GlobalConfig.display_mode = options_menu.display_mode
