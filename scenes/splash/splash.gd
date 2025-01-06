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

class_name Splash
extends ColorRect
## Splash screen
##
## This is the game splash screen

@export var duration: float = 2.0  ## How long the splash screen will be displayed
@onready var menu_scene: PackedScene = preload("res://scenes/menu/menu.tscn")


## Called when the splash screen is added
func _ready() -> void:
	# wait for the duration and fade out to the menu
	await get_tree().create_timer(duration).timeout
	EffectsGlobal.fade_out_in()
	await EffectsGlobal.out_ended
	if not get_tree().change_scene_to_packed(menu_scene) == OK:
		assert(false, "Could not change to menu scene")
