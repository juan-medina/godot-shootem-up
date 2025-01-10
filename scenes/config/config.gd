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

var current_values: ConfiguredValues:
	set(values):
		_change_current_values(values)
	get:
		return _get_current_values()

var _default_window_size: Vector2i = Vector2i(1728, 972)  ## The default window size defined in the project


## The definition of configured values
class ConfiguredValues:
	var display_mode: DisplayMode  ## The current display mode
	var screen: int  ## The current screen
	var screens: PackedStringArray  ## The list of screens
	var master_volume: int = 50  ## The master volume
	var master_muted: bool = false  ## Is the master volume muted
	var music_volume: int = 50  ## The music volume
	var music_muted: bool = false  ## Is the music volume muted
	var sfx_volume: int = 50  ## The sfx volume
	var sfx_muted: bool = false  ## Is the sfx volume muted
	var crt_corners: bool = true  ## Is the crt corners enabled
	var scanlines: bool = true  ## Is the scanlines enabled
	var color_bleed: bool = true  ## Is the color bleed enabled
	var test_level: bool = false  ## Is the test level enabled


## The configured values
@onready var _configured_values: ConfiguredValues = ConfiguredValues.new()


## Change the current values
func _change_current_values(new: ConfiguredValues) -> void:
	_display_mode_change(new)
	_audio_change(new)
	_crt_config_change(new)

	save()


## Get the current values
func _get_current_values() -> ConfiguredValues:
	_configured_values.screen = DisplayServer.window_get_current_screen()  # because the user can move the window
	_configured_values.screens = _get_screens()  # get the screens
	return _configured_values


## Called when the config is added to the scene
func _ready() -> void:
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

	# Read the crt config
	_read_crt_config(config)

	# Read the debug config
	_read_debug_config(config)


## Read the display config
func _read_display_config(config: ConfigFile) -> void:
	# since we just read the config we are windowed and in the current window screen
	_configured_values.display_mode = DisplayMode.WINDOWED
	_configured_values.screen = DisplayServer.window_get_current_screen()

	# preparing new values
	var new: ConfiguredValues = ConfiguredValues.new()

	# Get the display mode and screen from the config
	new.screen = config.get_value("display", "screen", _configured_values.screen)
	var display_mode_str: String = config.get_value("display", "mode", "FULLSCREEN")
	new.display_mode = DisplayMode.WINDOWED if display_mode_str == "WINDOWED" else DisplayMode.FULLSCREEN

	# Safe guard, check that the screen actually exist
	if new.screen >= DisplayServer.get_screen_count():
		new.screen = _configured_values.screen

	# Set the display mode, we force it to change since we just read the config
	_display_mode_change(new, true)


## Save the config
func save() -> void:
	# create the config
	var config: ConfigFile = ConfigFile.new()

	# get the screen since the user can move the window around
	_configured_values.screen = DisplayServer.window_get_current_screen()

	# save the display config
	_save_display_config(config)

	# save the audio config
	_audio_config_save(config)

	# save the crt config
	_crt_config_save(config)

	# save the debug config
	_save_debug_config(config)

	# save the config
	if not config.save("user://config.cfg") == OK:
		assert(false, "Failed to save config")


## Save the display config
func _save_display_config(config: ConfigFile) -> void:
	# set the screen and display mode
	config.set_value("display", "screen", _configured_values.screen)
	config.set_value("display", "mode", "WINDOWED" if _configured_values.display_mode == DisplayMode.WINDOWED else "FULLSCREEN")


## Change the display mode, we can force to change the display mode even if not changed
func _display_mode_change(new: ConfiguredValues, forced: bool = false) -> void:
	# nothing to do
	if new.display_mode == _configured_values.display_mode and new.screen == _configured_values.screen and not forced:
		return

	# set display mode and screen
	_configured_values.display_mode = new.display_mode
	_configured_values.screen = new.screen

	# set the screen
	DisplayServer.window_set_current_screen(_configured_values.screen)

	# set not borderless
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, false)

	# if window or fullscreen
	if _configured_values.display_mode == DisplayMode.WINDOWED:
		# set the mode, window size is the default, then center it
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(_default_window_size)
		DisplayServer.window_set_position(
			(
				DisplayServer.screen_get_position(_configured_values.screen)
				+ (DisplayServer.screen_get_size(_configured_values.screen) - DisplayServer.window_get_size()) / 2
			)
		)
	else:
		# just set fullscreen
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

	# wring window to the foreground
	DisplayServer.window_move_to_foreground()


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
		if screen_names.append(screen_name):
			assert(false, "Failed to add screen name")

	return screen_names


## Read the audio config
func _read_audio_config(config: ConfigFile) -> void:
	var new: ConfiguredValues = ConfiguredValues.new()

	new.master_volume = config.get_value("audio", "master_volume", _configured_values.master_volume)
	new.master_muted = config.get_value("audio", "master_muted", _configured_values.master_muted)
	new.music_volume = config.get_value("audio", "music_volume", _configured_values.music_volume)
	new.music_muted = config.get_value("audio", "music_muted", _configured_values.music_muted)
	new.sfx_volume = config.get_value("audio", "sfx_volume", _configured_values.sfx_volume)
	new.sfx_muted = config.get_value("audio", "sfx_muted", _configured_values.sfx_muted)

	_audio_change(new)


## Save the audio config
func _audio_config_save(config: ConfigFile) -> void:
	config.set_value("audio", "master_volume", _configured_values.master_volume)
	config.set_value("audio", "master_muted", _configured_values.master_muted)
	config.set_value("audio", "music_volume", _configured_values.music_volume)
	config.set_value("audio", "music_muted", _configured_values.music_muted)
	config.set_value("audio", "sfx_volume", _configured_values.sfx_volume)
	config.set_value("audio", "sfx_muted", _configured_values.sfx_muted)


# Change the audio
func _audio_change(new: ConfiguredValues) -> void:
	if new.master_volume != _configured_values.master_volume:
		_configured_values.master_volume = new.master_volume
		_change_bus_volume("Master", _configured_values.master_volume)

	if new.master_muted != _configured_values.master_muted:
		_configured_values.master_muted = new.master_muted
		_mute_bus("Master", _configured_values.master_muted)

	if new.music_volume != _configured_values.music_volume:
		_configured_values.music_volume = new.music_volume
		_change_bus_volume("Music", _configured_values.music_volume)

	if new.music_muted != _configured_values.music_muted:
		_configured_values.music_muted = new.music_muted
		_mute_bus("Music", _configured_values.music_muted)

	if new.sfx_volume != _configured_values.sfx_volume:
		_configured_values.sfx_volume = new.sfx_volume
		_change_bus_volume("SFX", _configured_values.sfx_volume)

	if new.sfx_muted != _configured_values.sfx_muted:
		_configured_values.sfx_muted = new.sfx_muted
		_mute_bus("SFX", _configured_values.sfx_muted)


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

## Read the crt config
func _read_crt_config(config: ConfigFile) -> void:
	_configured_values.crt_corners = config.get_value("crt", "corners", _configured_values.crt_corners)
	_configured_values.scanlines = config.get_value("crt", "scanlines", _configured_values.scanlines)
	_configured_values.color_bleed = config.get_value("crt", "color_bleed", _configured_values.color_bleed)

	_crt_config_change(_configured_values)


## Save the crt config
func _crt_config_save(config: ConfigFile) -> void:
	config.set_value("crt", "corners", _configured_values.crt_corners)
	config.set_value("crt", "scanlines", _configured_values.scanlines)
	config.set_value("crt", "color_bleed", _configured_values.color_bleed)

## Change the crt effect
func _crt_config_change(new: ConfiguredValues) -> void:
	_configured_values.crt_corners = new.crt_corners
	_configured_values.scanlines = new.scanlines
	_configured_values.color_bleed = new.color_bleed

	EffectsGlobal.crt(_configured_values.crt_corners, _configured_values.scanlines, _configured_values.color_bleed)


## Called for reading the debug config
func _read_debug_config(config: ConfigFile) -> void:
	_configured_values.test_level = config.get_value("debug", "test_level", _configured_values.test_level)


## Called for saving the debug config
func _save_debug_config(config: ConfigFile) -> void:
	config.set_value("debug", "test_level", _configured_values.test_level)