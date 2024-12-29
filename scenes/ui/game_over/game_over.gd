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

var accept_clicks: bool = true  ## If the player can click

@onready var click_sound: AudioStreamPlayer2D = $ClickSound  ## Click sound
@onready var ok_button: Button = $OK ## Ok button


## Called when ok button is pressed
func _on_ok_pressed() -> void:
	# handle the click
	_handle_click(ok)


## Called when cancel button is pressed
func _on_cancel_pressed() -> void:
	# handle the click
	_handle_click(cancel)


## Handle a button click
func _handle_click(button_signal: Signal) -> void:
	# if the player can not click return
	if not accept_clicks:
		return
	# we can not click anymore
	accept_clicks = false

	# play the click sound, wait for it to finish, emit the signal and hide
	click_sound.play()
	await click_sound.finished
	button_signal.emit()
	hide()


# Handle the focus change on the ok button
func _on_ok_focus_exited() -> void:
	# handle the focus change
	_handle_change_focus()


# Handle the focus change on the cancel button
func _on_cancel_focus_exited() -> void:
	# handle the focus change
	_handle_change_focus()


## Handle the focus change
func _handle_change_focus() -> void:
	# if is visible play the click sound
	if visible:
		click_sound.play()


## Handle the visibility change
func _on_visibility_changed() -> void:
	# if is visible accept clicks
	if visible:
		accept_clicks = true
		# focus the ok button
		ok_button.grab_focus()
