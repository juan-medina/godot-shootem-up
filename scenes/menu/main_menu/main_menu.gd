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

class_name MainMenu
extends Control
## Main menu
##
## The menu main menu

signal button_click(button: Button)  ## Signal when the player clicks a button

var _previous_focus: Button = null  ## The previous focus
var _disable_sound_time: float = 0.2  ## How long the click sound is disable to avoid repetition
var _allow_sound: bool = true  ## Allow the click sound
var _disable_click_time: float = 0.2  ## How long we can not make a click
var _allow_click: bool = true  ## Allow the click

@onready var play_button: Button = $VFlowContainer/Play  ## Play button
@onready var exit_button: Button = $VFlowContainer/Exit  ## Exit button
@onready var options_button: Button = $VFlowContainer/HFlowContainer/Options  ## Options button
@onready var about_button: Button = $VFlowContainer/HFlowContainer/About  ## About button
@onready var _click_sound: AudioStreamPlayer2D = $ClickSound  ## Click sound


# Called when the main menu is added to the scene
func _ready() -> void:
	# setup all buttons
	_on_visibility_changed()
	_setup_button(self)
	if not visibility_changed.connect(_change_focus) == OK:
		assert(false, "Failed to connect to visibility_changed signal")


# Setup all buttons signals recursively
func _setup_button(node: Node) -> void:
	for child: Node in node.get_children():
		if child is Button:
			var button: Button = child
			if not button.pressed.connect(_on_button_pressed.bind()) == OK:
				assert(false, "Failed to connect to button pressed signal")
			if not button.focus_entered.connect(_change_focus.bind()) == OK:
				assert(false, "Failed to connect to button focus_entered signal")
		else:
			_setup_button(child)


## Called when a button is pressed
func _on_button_pressed() -> void:
	# get the current focus, if is a button and we can click
	var current_focus: Node = get_viewport().gui_get_focus_owner()
	if current_focus is Button and _allow_click:
		_allow_click = false
		# play the click sound and wait for it to finish
		await _play_click_sound()

		# emit the signal
		button_click.emit(current_focus)
		hide()
		# wait for the click time
		await get_tree().create_timer(_disable_click_time).timeout
		_allow_click = true


## Called when the focus changes
func _change_focus() -> void:
	# get the current focus, if is a button and not the same that last focus
	var current_focus: Node = get_viewport().gui_get_focus_owner()
	if current_focus is Button and _previous_focus != current_focus:
		# set the previous focus
		_previous_focus = current_focus
		# play the click sound and wait for it to finish
		await _play_click_sound()


## Play the click sound, but only if enough time has passed to avoid repetition
func _play_click_sound() -> void:
	# if the sound is not allowed, return
	if not _allow_sound:
		return
	# play the sound
	_allow_sound = false
	_click_sound.play()
	await get_tree().create_timer(_disable_sound_time).timeout
	_allow_sound = true


## Called when the visibility changes
func _on_visibility_changed() -> void:
	# if the menu is visible
	if visible:
		# get first button and focus it
		var button: Button = _find_first_button(self)
		assert(button != null, "Could not find first button")
		_previous_focus = button
		button.grab_focus()


## Find the first button
func _find_first_button(node: Node) -> Button:
	for child: Node in node.get_children():
		if child is Button:
			return child
		return _find_first_button(child)
	return null
