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

class_name OptionsMenu
extends SubMenu
## Options menu
##
## The menu that allows the player to change the game settings

var display_mode: Config.DisplayMode = Config.DisplayMode.WINDOWED:  ## The display mode in the options
	set(value):
		# set the check depending on the display mode
		_windowed_check.set_pressed(value == Config.DisplayMode.WINDOWED)
		_full_screen_check.set_pressed(value == Config.DisplayMode.FULLSCREEN)
	get():
		# if windowed is pressed return windowed if not fullscreen
		if _windowed_check.is_pressed():
			return Config.DisplayMode.WINDOWED
		return Config.DisplayMode.FULLSCREEN

var screen_options: PackedStringArray = PackedStringArray():  ## The list of screens
	set(value):
		_screen_options_button.clear()
		for screen_name: String in value:
			_screen_options_button.add_item(screen_name)

var screen: int:  ## The current screen
	set(value):
		_screen_options_button.selected = value
	get:
		return _screen_options_button.selected

var master_volume: int:  ## The current master volume
	set(value):
		_master_volume_slider.value = value
		super._change_slider_label(_master_volume_slider, value)
	get:
		return _master_volume_slider.value as int

var master_muted: bool:  ## Is the master volume muted
	set(value):
		_master_volumen_check.set_pressed(value)
	get:
		return _master_volumen_check.is_pressed()

var sfx_volume: int:  ## The current sfx volume
	set(value):
		_sfx_volume_slider.value = value
		super._change_slider_label(_sfx_volume_slider, value)
	get:
		return _sfx_volume_slider.value as int

var sfx_muted: bool:  ## Is the sfx volume muted
	set(value):
		_sfx_volume_check.set_pressed(value)
	get:
		return _sfx_volume_check.is_pressed()

var music_volume: int:  ## The current music volume
	set(value):
		_music_volume_slider.value = value
		super._change_slider_label(_music_volume_slider, value)
	get:
		return _music_volume_slider.value as int

var music_muted: bool:  ## Is the music volume muted
	set(value):
		_music_volume_check.set_pressed(value)
	get:
		return _music_volume_check.is_pressed()

@onready var ok_button: Button = $Buttons/Ok  ## Ok button
@onready var back_button: Button = $Buttons/Back  ## Back button
@onready var apply_button: Button = $Buttons/Apply  ## Apply button

@onready var _windowed_check: CheckButton = $Panel/VFlowContainer/DisplayModeRow/WindowedCheck  ## Windowed check
@onready var _full_screen_check: CheckButton = $Panel/VFlowContainer/DisplayModeRow/FullScreenCheck  ## Fullscreen check
@onready var _screen_options_button: OptionButton = $Panel/VFlowContainer/ScreenRow/ScreenOptionButton  ## Screen option button

@onready var _master_volume_slider: HSlider = $Panel/VFlowContainer/MasterVolumeRow/MasterVolumeSlider  ## Master volume slider
@onready var _master_volumen_check: CheckButton = $Panel/VFlowContainer/MasterVolumeMuted  ## Master volume check

@onready var _sfx_volume_slider: HSlider = $Panel/VFlowContainer/SfxVolumeRow/SfxVolumeSlider  ## Sfx volume slider
@onready var _sfx_volume_check: CheckButton = $Panel/VFlowContainer/SfxVolumeMuted  ## Sfx volume check

@onready var _music_volume_slider: HSlider = $Panel/VFlowContainer/MusicVolumeRow/MusicVolumeSlider  ## Music volume slider
@onready var _music_volume_check: CheckButton = $Panel/VFlowContainer/MusicVolumeMuted  ## Music volume check
