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

class_name GameWin
extends SubMenu
## Game Win UI
##
## This is the UI when the player wins the game

var high_score: int = 0:
	set(value):
		# Update the high score
		high_score_label.text = "High Score: %d" % value

var score: int = 0:
	set(value):
		# Update the score
		score_label.text = "Score: %d" % value

var blink: bool = false:
	set(value):
		var shader_material: ShaderMaterial = hit_material if value else null
		score_label.material = shader_material
		high_score_label.material = shader_material

@onready var restart_button: Button = $Panel/Restart  ## Restart button
@onready var exit_button: Button = $Panel/Exit  ## Exit button
@onready var high_score_label: Label = $Panel/HighScore  ## High score label
@onready var score_label: Label = $Panel/Score  ## Score label
@onready var hit_material: ShaderMaterial = preload("res://resources/materials/hit.tres")  ## Hit material
