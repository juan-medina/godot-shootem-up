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

class_name UI
extends Control
## UI
##
## In-game UI

signal game_over_ok  ## Signal when the player clicks ok on the game over UI
signal game_over_cancel  ## Signal when the player clicks cancel on the game over UI

@export var shield_depleted_duration: float = 0.25  ## How long the shield depleted animation will last

var points: int = 0:  ## How many points the player has
	set(value):
		# Update the points
		points = value
		points_label.text = str(points)

var shields: int = 0:  ## How many shields the player has
	set(value):
		# Update the shields
		shields = value
		# we need to use value, not shields, since a player can get two hits consecutively
		# and since the animation last some time we need to make sure that display in the right shield
		_deplete_shield(shields_sprites[value])

@onready var shields_sprites: Array[Sprite2D] = [$ShieldBar/Shield1, $ShieldBar/Shield2, $ShieldBar/Shield3]  ## Shields sprites
@onready var game_over_ui: GameOver = $GameOver  ## Game over UI
@onready var points_label: Label = $Points  ## Points label
@onready var hit_material: ShaderMaterial = preload("res://resources/materials/hit.tres")  ## Hit material


## Add the depleted animation to a shield
func _deplete_shield(shield: Sprite2D) -> void:
	# use the hit material, blinking red
	shield.material = hit_material

	# wait a the depleted time, remove it and hide the shield
	await get_tree().create_timer(shield_depleted_duration).timeout
	shield.material = null
	shield.visible = false


## Show the game over UI
func game_over() -> void:
	# make the game over UI visible
	game_over_ui.visible = true

func _on_game_over_button_click(button: Button) -> void:
	match button:
		game_over_ui.ok_button:
			game_over_ok.emit()
		game_over_ui.cancel_button:
			game_over_cancel.emit()
