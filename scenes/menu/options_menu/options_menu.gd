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

var values: Config.ConfiguredValues = Config.ConfiguredValues.new():  ## The options values
	set(new):
		# set the display mode
		_windowed_check.set_pressed(new.display_mode == Config.DisplayMode.WINDOWED)
		_full_screen_check.set_pressed(new.display_mode == Config.DisplayMode.FULLSCREEN)

		# add the screens
		_screen_options_button.clear()
		for screen_name: String in new.screens:
			_screen_options_button.add_item(screen_name)

		# select the screen
		_screen_options_button.selected = new.screen

		# set the audio values
		_master_volume_slider.value = new.master_volume
		_master_volumen_check.set_pressed(new.master_muted)

		_sfx_volume_slider.value = new.sfx_volume
		_sfx_volume_check.set_pressed(new.sfx_muted)

		_music_volume_slider.value = new.music_volume
		_music_volume_check.set_pressed(new.music_muted)

		# set the crt values
		_crt_corners_check.set_pressed(new.crt_corners)
		_scanlines_check.set_pressed(new.scanlines)
		_color_bleed_check.set_pressed(new.color_bleed)

	get():
		# configuration that we going to return
		var new: Config.ConfiguredValues = Config.ConfiguredValues.new()

		# set the display mode
		new.display_mode = Config.DisplayMode.WINDOWED if _windowed_check.is_pressed() else Config.DisplayMode.FULLSCREEN
		new.screen = _screen_options_button.selected

		# set the audio values
		new.master_volume = _master_volume_slider.value as int
		new.master_muted = _master_volumen_check.is_pressed()

		new.music_volume = _music_volume_slider.value as int
		new.music_muted = _music_volume_check.is_pressed()

		new.sfx_volume = _sfx_volume_slider.value as int
		new.sfx_muted = _sfx_volume_check.is_pressed()

		# set the crt values
		new.crt_corners = _crt_corners_check.is_pressed()
		new.scanlines = _scanlines_check.is_pressed()
		new.color_bleed = _color_bleed_check.is_pressed()

		return new

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

@onready var _crt_corners_check: CheckButton = $Panel/VFlowContainer/CRTRow/CRTCornersCheck  ## Crt corners check
@onready var _scanlines_check: CheckButton = $Panel/VFlowContainer/CRTRow/ScanlinesCheck  ## Scanlines check
@onready var _color_bleed_check: CheckButton = $Panel/VFlowContainer/CRTRow/ColorBleedCheck  ## Color bleed check
