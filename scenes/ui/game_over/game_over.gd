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

signal ok
signal cancel

var accept_clicks: bool = true

@onready var click_sound: AudioStreamPlayer2D = $ClickSound


func _on_ok_pressed() -> void:
	_handle_click(ok)


func _on_cancel_pressed() -> void:
	_handle_click(cancel)


func _handle_click(button_signal: Signal) -> void:
	if not accept_clicks:
		return
	accept_clicks = false
	click_sound.play()
	await click_sound.finished
	button_signal.emit()
	hide()


func _on_ok_focus_exited() -> void:
	_handle_change_focus()


func _on_cancel_focus_exited() -> void:
	_handle_change_focus()


func _handle_change_focus() -> void:
	if visible:
		click_sound.play()


func _on_visibility_changed() -> void:
	if visible:
		accept_clicks = true