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

enum DisplayMode { WINDOWED, FULLSCREEN }  ## The display mode

var display_mode: DisplayMode:  ## The current display mode
	set(mode):
		_display_mode_change(mode, DisplayServer.window_get_current_screen())  # because the user can move the window
	get():
		return _display_mode

var screen: int:  ## The current screen
	set(screen):
		_display_mode_change(_display_mode, screen)
	get():
		_screen = DisplayServer.window_get_current_screen()  # because the user can move the window
		return _screen

var screens: PackedStringArray:  ## The list of screens
	get = _get_screens

var master_volume: int:  ## The master volume
	set(value):
		_audio_change(value, _is_master_volume_muted, _music_volume, _is_music_volume_muted, _sfx_volume, _is_sfx_volume_muted)
	get:
		return _master_volume

var master_volume_muted: bool:  ## Is the master volume muted
	set(value):
		_audio_change(_master_volume, value, _music_volume, _is_music_volume_muted, _sfx_volume, _is_sfx_volume_muted)
	get:
		return _is_master_volume_muted

var music_volume: int:  ## The music volume
	set(value):
		_audio_change(_master_volume, _is_master_volume_muted, value, _is_music_volume_muted, _sfx_volume, _is_sfx_volume_muted)
	get:
		return _music_volume

var music_volume_muted: bool:  ## Is the music volume muted
	set(value):
		_audio_change(_master_volume, _is_master_volume_muted, _music_volume, value, _sfx_volume, _is_sfx_volume_muted)
	get:
		return _is_music_volume_muted

var sfx_volume: int:  ## The sfx volume
	set(value):
		_audio_change(_master_volume, _is_master_volume_muted, _music_volume, _is_music_volume_muted, value, _is_sfx_volume_muted)
	get:
		return _sfx_volume

var sfx_volume_muted: bool:  ## Is the sfx volume muted
	set(value):
		_audio_change(_master_volume, _is_master_volume_muted, _music_volume, _is_music_volume_muted, _sfx_volume, value)
	get:
		return _is_sfx_volume_muted

var _default_window_size: Vector2i  ## The default window size defined in the project
var _screen: int  ## The current screen
var _display_mode: DisplayMode  ## The current display mode

var _master_volume: int = 50  ## The master volume
var _is_master_volume_muted: bool = false  ## Is the master volume muted
var _music_volume: int = 50  ## The music volume
var _is_music_volume_muted: bool = false  ## Is the music volume muted
var _sfx_volume: int = 50  ## The sfx volume
var _is_sfx_volume_muted: bool = false  ## Is the sfx volume muted


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

	# Read the display config
	_read_display_config(config)

	# Read the audio config
	_read_audio_config(config)


## Read the display config
func _read_display_config(config: ConfigFile) -> void:
	# since we just read the config we are windowed and in the current window screen
	_display_mode = DisplayMode.WINDOWED
	_screen = DisplayServer.window_get_current_screen()

	# Get the display mode and screen from the config
	var new_screen: int = config.get_value("display", "screen", _screen)
	var display_mode_str: String = config.get_value("display", "mode", "WINDOWED")
	var new_display_mode: DisplayMode = DisplayMode.WINDOWED if display_mode_str == "WINDOWED" else DisplayMode.FULLSCREEN

	# Safe guard, check that the screen actually exist
	if new_screen >= DisplayServer.get_screen_count():
		new_screen = _screen

	# Set the display mode
	_display_mode_change(new_display_mode, new_screen)


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

	# save the display config
	_save_display_config(config)

	# save the audio config
	_audio_config_save(config)

	# save the config
	if not config.save("user://config.cfg") == OK:
		assert(false, "Failed to save config")


## Save the display config
func _save_display_config(config: ConfigFile) -> void:
	# get the screen since the user can move the window around
	_screen = DisplayServer.window_get_current_screen()

	# set the screen and display mode
	config.set_value("display", "screen", _screen)
	config.set_value("display", "mode", "WINDOWED" if _display_mode == DisplayMode.WINDOWED else "FULLSCREEN")


## Change the display mode
func _display_mode_change(new_mode: DisplayMode, new_screen: int) -> void:
	# nothing to do
	if new_mode == _display_mode and new_screen == _screen:
		return

	# set display mode and screen
	_display_mode = new_mode
	_screen = new_screen

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

	# wring window to the foreground
	DisplayServer.window_move_to_foreground()

	# save the config
	save()


## Get the list of screens that the user has
func _get_screens() -> PackedStringArray:
	# Create a PackedStringArray to store the screen display names
	var screen_names: PackedStringArray = PackedStringArray()

	# Get the primary screen
	var primary: int = DisplayServer.get_primary_screen()

	# Get the screen display names, since godot does not support it we do "number. resolution" e.g. "0. 1920x1080"
	for screen_number: int in range(DisplayServer.get_screen_count()):
		var resolution: Vector2i = DisplayServer.screen_get_size(screen_number)
		var screen_name: String = "%d. %dx%d" % [screen_number, resolution.x, resolution.y]
		# if the screen is the primary screen add (primary) e.g. "0. 1920x1080 (primary)"
		if screen_number == primary:
			screen_name += " (primary)"
		assert(not screen_names.append(screen_name), "Failed to add screen name")

	return screen_names


func _read_audio_config(config: ConfigFile) -> void:
	var new_master_volume: int = config.get_value("audio", "master_volume", _master_volume)
	var new_is_master_volume_muted: bool = config.get_value("audio", "is_master_volume_muted", _is_master_volume_muted)
	var new_music_volume: int = config.get_value("audio", "music_volume", _music_volume)
	var new_is_music_volume_muted: bool = config.get_value("audio", "is_music_volume_muted", _is_music_volume_muted)
	var new_sfx_volume: int = config.get_value("audio", "sfx_volume", _sfx_volume)
	var new_is_sfx_volume_muted: bool = config.get_value("audio", "is_sfx_volume_muted", _is_sfx_volume_muted)

	_audio_change(new_master_volume, new_is_master_volume_muted, new_music_volume, new_is_music_volume_muted, new_sfx_volume, new_is_sfx_volume_muted)


func _audio_config_save(config: ConfigFile) -> void:
	config.set_value("audio", "master_volume", _master_volume)
	config.set_value("audio", "is_master_volume_muted", _is_master_volume_muted)
	config.set_value("audio", "music_volume", _music_volume)
	config.set_value("audio", "is_music_volume_muted", _is_music_volume_muted)
	config.set_value("audio", "sfx_volume", _sfx_volume)
	config.set_value("audio", "is_sfx_volume_muted", _is_sfx_volume_muted)


func _audio_change(
	new_master_volume: int,
	new_is_master_volume_muted: bool,
	new_music_volume: int,
	new_is_music_volume_muted: bool,
	new_sfx_volume: int,
	new_is_sfx_volume_muted: bool
) -> void:
	if new_master_volume != _master_volume:
		_master_volume = new_master_volume
		_change_bus_volume("Master", _master_volume)

	if new_is_master_volume_muted != _is_master_volume_muted:
		_is_master_volume_muted = new_is_master_volume_muted
		_mute_bus("Master", _is_master_volume_muted)

	if new_music_volume != _music_volume:
		_music_volume = new_music_volume
		_change_bus_volume("Music", _music_volume)

	if new_is_music_volume_muted != _is_music_volume_muted:
		_is_music_volume_muted = new_is_music_volume_muted
		_mute_bus("Music", _is_music_volume_muted)

	if new_sfx_volume != _sfx_volume:
		_sfx_volume = new_sfx_volume
		_change_bus_volume("SFX", _sfx_volume)

	if new_is_sfx_volume_muted != _is_sfx_volume_muted:
		_is_sfx_volume_muted = new_is_sfx_volume_muted
		_mute_bus("SFX", _is_sfx_volume_muted)


## Change the volume of a bus
func _change_bus_volume(_bus: String, _volume: int) -> void:
	# calculate the db
	#   0 to 50  = -30db to -5db
	#  50 to 100 = -5db to  15db
	var db: float = 0.0
	if _volume <= 50:
		db = lerp(-30, -5, _volume / 50.0)
	else:
		db = lerp(-5, 15, (_volume - 50) / 50.0)

	# Set the volume of the specified bus
	var bus_index: int = AudioServer.get_bus_index(_bus)
	AudioServer.set_bus_volume_db(bus_index, db)


## Mute/un-mute a bus
func _mute_bus(_bus: String, _muted: bool) -> void:
	var bus_index: int = AudioServer.get_bus_index(_bus)
	AudioServer.set_bus_mute(bus_index, _muted)
