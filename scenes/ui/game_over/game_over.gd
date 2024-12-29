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

class_name GameOver
extends Panel
## Game over UI
##
## This is the UI that appears when the player died

signal ok  ## Signal when the player clicks ok
signal cancel  ## Signal when the player clicks cancel

var previous_focus: Button = null  ## The previous focus
var last_sound_play_time: float = 0.0  ## The last time the click sound was played
var click_sound_delay: int = 100  ## The delay to avoid playing repeated click sound

@onready var click_sound: AudioStreamPlayer2D = $ClickSound  ## Click sound
@onready var ok_button: Button = $OK  ## Ok button
@onready var cancel_button: Button = $Cancel  ## Cancel button


## Called when the game over UI is added to the scene
func _ready() -> void:
	# connect the signals
	if not ok_button.focus_entered.connect(_change_focus.bind()) == OK:
		assert(false, "Failed to connect to ok focus entered signal")
	if not cancel_button.focus_entered.connect(_change_focus.bind()) == OK:
		assert(false, "Failed to connect to cancel focus entered signal")
	if not ok_button.pressed.connect(_on_button_pressed.bind()) == OK:
		assert(false, "Failed to connect to ok button pressed signal")
	if not cancel_button.pressed.connect(_on_button_pressed.bind()) == OK:
		assert(false, "Failed to connect to cancel button pressed signal")


## Called when the focus changes
func _change_focus() -> void:
	# if is visible
	if visible:
		# get the current focus, if is a button and not the same that last focus
		var current_focus: Node = get_viewport().gui_get_focus_owner()
		if current_focus is Button and previous_focus != current_focus:
			# set the previous focus
			previous_focus = current_focus
			# play the click sound and wait for it to finish
			await _play_click_sound()


## Called when a button is pressed
func _on_button_pressed() -> void:
	# get the current focus, if is a button
	var current_focus: Node = get_viewport().gui_get_focus_owner()
	if current_focus is Button:
		# get what signal we should emit
		var button_signal: Signal
		match current_focus:
			ok_button:
				button_signal = ok
			cancel_button:
				button_signal = cancel
			_:
				# should never happen
				return

		# play the click sound and wait for it to finish
		await _play_click_sound()

		# emit the signal and hide the Game Over UI
		button_signal.emit()
		hide()


## Handle the visibility change
func _on_visibility_changed() -> void:
	# if is visible
	if visible:
		# focus the ok button
		previous_focus = ok_button
		ok_button.grab_focus()
		# reset the last sound play time
		last_sound_play_time = Time.get_ticks_msec()

## Play the click sound, but only if enough time has passed to avoid repetition
func _play_click_sound() -> void:
	# play the click sound if enough time has passed, avoid playing often
	if Time.get_ticks_msec() - last_sound_play_time > click_sound_delay:
		click_sound.play()
		last_sound_play_time = Time.get_ticks_msec()
		await click_sound.finished
