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

class_name SubMenu
extends Control
## Main menu
##
## Sub Menu that all menu extends

signal button_click(button: Button)  ## Signal when the player clicks a button

const _DISABLE_SOUND_TIME: float = 0.15  ## How long the click sound is disable to avoid repetition
const _DISABLE_CLICK_TIME: float = 0.2  ## How long we can not make a click

var _previous_focus: Control = null  ## The previous focus
var _allow_sound: bool = true  ## Allow the click sound
var _allow_click: bool = true  ## Allow the click

@onready var _click_sound: AudioStreamPlayer2D = AudioStreamPlayer2D.new()  ## Click sound player
@onready var _click_stream: Resource = preload("res://resources/sounds/button_click.wav")  ## Click sound stream


# Called when the main menu is added to the scene
func _ready() -> void:
	# setup the click sound
	_click_sound.bus = "SFX"
	_click_sound.stream = _click_stream
	add_child(_click_sound)

	# setup all buttons
	_on_visibility_changed()
	_setup_controls()
	if not visibility_changed.connect(_on_visibility_changed) == OK:
		assert(false, "Failed to connect to visibility_changed signal")


## when the node is free from the scene, stop the click sound


func _exit_tree() -> void:
	if is_instance_valid(_click_sound) and not _click_sound.is_queued_for_deletion():
		if _click_sound.playing:
			_click_sound.stop()
		_click_sound.queue_free()


# if the escape key is pressed, exit
func _process(_delta: float) -> void:
	# if the menu is visible
	if visible:
		# if the escape key is pressed, press the cancel button
		if Input.is_action_just_pressed("ui_cancel"):
			_press_cancel_button()
		# keep updating the slider labels
		var sliders: Array[Node] = self.find_children("*", "Slider")
		for slider: Slider in sliders:
			_change_slider_label(slider)


# Setup all controls signals
func _setup_controls() -> void:
	var buttons: Array[Node] = self.find_children("*", "Button")
	for button: Button in buttons:
		if not button.pressed.connect(_on_button_pressed) == OK:
			assert(false, "Failed to connect to button pressed signal")
	var controls: Array[Node] = self.find_children("*", "Control")
	for control: Control in controls:
		if not control.focus_entered.connect(_change_focus) == OK:
			assert(false, "Failed to connect to button focus_entered signal")
	var sliders: Array[Node] = self.find_children("*", "Slider")
	for slider: Slider in sliders:
		if not slider.value_changed.connect(_slider_changed) == OK:
			assert(false, "Failed to connect to slider focus_entered signal")


## Called when a button is pressed
func _on_button_pressed() -> void:
	# get the current focus, if is a button and we can click
	var current_focus: Node = get_viewport().gui_get_focus_owner()
	if current_focus is Button and _allow_click:
		_allow_click = false
		# play the click sound and wait for it to finish
		await _play_click_sound()

		# emit the signal
		button_click.emit(current_focus as Button)

		# if the button needs to hide the menu
		if current_focus.get_meta("hide_menu", true) == true:
			hide()

		# wait for the click time
		await get_tree().create_timer(_DISABLE_CLICK_TIME).timeout
		_allow_click = true


## Called when the focus changes
func _change_focus() -> void:
	# get the current focus, if is a button and not the same that last focus
	var current_focus: Node = get_viewport().gui_get_focus_owner()
	if current_focus is Control and _previous_focus != current_focus:
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
	await get_tree().create_timer(_DISABLE_SOUND_TIME).timeout
	_allow_sound = true


## Called when the visibility changes
func _on_visibility_changed() -> void:
	# if the menu is visible
	if visible:
		# get first button and focus it
		_previous_focus = _focus_default_button()


## Find the default button and focus it
func _focus_default_button() -> Button:
	# find a button that has the focus_on_visible meta to true
	var children: Array[Node] = self.find_children("*", "Button")
	for button: Button in children:
		if button.get_meta("focus_on_visible", false) == true:
			_previous_focus = button
			button.grab_focus()
			return button

	# if no button was found
	assert(false, "No button with focus_on_visible = true meta found")
	return null


## Find if we have a cancel menu button and press it
func _press_cancel_button() -> void:
	# find a button that has the cancel_menu meta to true
	var children: Array[Node] = self.find_children("*", "Button")
	for button: Button in children:
		if button.get_meta("cancel_menu", false) == true:
			# focus and press the button
			_previous_focus = button
			button.grab_focus()
			button.pressed.emit()
			break


## Called when the a value changes
func _slider_changed(_value: float) -> void:
	# if the menu is visible
	if visible:
		# play the click sound and wait for it to finish
		await _play_click_sound()


## Change the label of a slider
func _change_slider_label(slider: Slider) -> void:
	# get from meta the value label and update it
	var meta: Variant = slider.get_meta("value_label")
	if meta and meta is NodePath:
		var path: NodePath = meta
		var label: Label = slider.get_node(path)
		if label:
			label.text = "%d %%" % (slider.value as int)
