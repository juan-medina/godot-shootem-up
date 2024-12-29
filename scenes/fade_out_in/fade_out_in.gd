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

class_name FadeOutIn
extends CanvasLayer
## Fade out and in scene
##
## This scene it means to be run as a global to transition between scenes

signal out_ended  ## Signal emitted when the fade out animation is finished
signal in_ended  ## Signal emitted when the fade in animation is finished

@onready var color_rect: ColorRect = $ColorRect  ## The color that we fade to
@onready var animation_player: AnimationPlayer = $AnimationPlayer  ## Animation player to control the fade


## Called when the global is add to the world
func _ready() -> void:
	color_rect.visible = false


## Called when an fade in/out animation finishes
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	# when the fade out animation finishes, play the fade in, and emmit the signal
	if anim_name == "fade_out":
		out_ended.emit()
		animation_player.play("fade_in")
	# when the fade in animation finishes, hide and emmit the signal
	elif anim_name == "fade_in":
		color_rect.visible = false
		in_ended.emit()

## Helper to do the fade in and out
func play() -> void:
	## make it visible and start the fade out
	color_rect.visible = true
	animation_player.play("fade_out")
