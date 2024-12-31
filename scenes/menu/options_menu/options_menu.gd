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

enum OptionsDisplayMode { WINDOWED, FULLSCREEN }

var display_mode: OptionsDisplayMode = OptionsDisplayMode.WINDOWED:
	set(value):
		_windowed_check.set_pressed(value == OptionsDisplayMode.WINDOWED)
		_full_screen_check.set_pressed(value == OptionsDisplayMode.FULLSCREEN)
	get():
		if _windowed_check.is_pressed():
			return OptionsDisplayMode.WINDOWED
		return OptionsDisplayMode.FULLSCREEN

@onready var ok_button: Button = $Buttons/Ok  ## Ok button
@onready var back_button: Button = $Buttons/Back  ## Back button
@onready var apply_button: Button = $Buttons/Apply  ## Apply button

@onready var _windowed_check: CheckButton = $Panel/VFlowContainer/DisplayModeRow/WindowedCheck
@onready var _full_screen_check: CheckButton = $Panel/VFlowContainer/DisplayModeRow/FullScreenCheck
