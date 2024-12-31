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

class_name Config
extends Node
## Config Node
##
## This is the Config Global

enum DisplayMode { WINDOWED, FULLSCREEN } ## The display mode

var display_mode: DisplayMode: ## The current display mode
	set(mode):
		_display_mode_change(mode, DisplayServer.window_get_current_screen()) ## when we get call via options use current screen
	get():
		return _display_mode

var _default_window_size: Vector2i
var _screen: int
var _display_mode: DisplayMode

## Called when the config is added to the scene
func _ready() -> void:
	# Get the default window size
	var default_width: int = ProjectSettings.get_setting("window/size/window_width_override", 1728)
	var default_height: int = ProjectSettings.get_setting("window/size/window_height_override", 972)
	_default_window_size = Vector2(default_width, default_height)
	# Read the config and save
	_read_config()
	save()

## Called when the config is removed from the scene, so we exit the game
func _exit_tree() -> void:
	save()

## Read the config
func _read_config() -> void:
	# Read the config, is does not exist continue
	var config: ConfigFile = ConfigFile.new()
	if not config.load("user://config.cfg") == OK:
		pass
	# get the screen and display mode
	_screen = config.get_value("display", "screen", DisplayServer.get_primary_screen())
	var display_mode_str: String = config.get_value("display", "mode", "WINDOWED")
	_display_mode = DisplayMode.WINDOWED if display_mode_str == "WINDOWED" else DisplayMode.FULLSCREEN

	# Set the display mode
	_display_mode_change(_display_mode, _screen)


## Save the config
func save() -> void:
	# create the config
	var config: ConfigFile = ConfigFile.new()

	# get the screen since the user can move the window around
	_screen = DisplayServer.window_get_current_screen()

	# set the screen and display mode
	config.set_value("display", "screen", _screen)
	config.set_value("display", "mode", "WINDOWED" if _display_mode == DisplayMode.WINDOWED else "FULLSCREEN")

	# save the config
	if not config.save("user://config.cfg") == OK:
		assert(false, "Failed to save config")

## Change the display mode
func _display_mode_change(mode: DisplayMode, screen: int) -> void:
	# set display mode and screen
	_display_mode = mode
	_screen = screen
	# set the screen
	DisplayServer.window_set_current_screen(_screen)
	# if window or fullscreen
	if _display_mode == DisplayMode.WINDOWED:
		# set the mode, window size is the default, then center it
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(_default_window_size)
		DisplayServer.window_set_position(
			DisplayServer.screen_get_position(_screen) + (DisplayServer.screen_get_size(_screen) - DisplayServer.window_get_size()) / 2
		)
	else:
		# just set fullscreen
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	# save the config
	save()
