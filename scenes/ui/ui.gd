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

signal level_restart  ## Signal when the player clicks ok on the game over UI
signal back_to_menu  ## Signal when the player clicks cancel on the game over UI

@export var shield_depleted_duration: float = 0.5  ## How long the shield depleted animation will last

var points: int = 0:  ## How many points the player has
	set(value):
		# Update the points
		points_label.text = str(value)

var shields: int = 0:  ## How many shields the player has
	set(value):
		# Update the shields
		shields = value
		# we need to use value, not shields, since a player can get two hits consecutively
		# and since the animation last some time we need to make sure that display in the right shield
		_deplete_shield(shields_sprites[value])

var shields_energy: Game.EnergyType = Game.EnergyType.BLUE:  ## The energy type of the shields
	set(value):
		# set the energy type of the shields
		for shield: Sprite2D in shields_sprites:
			if shield.modulate != Game.ENERGY_TYPE_COLOR[Game.EnergyType.DEPLETED]:
				shield.modulate = Game.ENERGY_TYPE_COLOR[value]

@onready var shields_sprites: Array[Sprite2D] = [$ShieldBar/Shield1, $ShieldBar/Shield2, $ShieldBar/Shield3]  ## Shields sprites
@onready var game_over_ui: GameOver = $GameOver  ## Game over UI
@onready var pause_ui: Pause = $Pause  ## Pause UI
@onready var game_win_ui: GameWin = $GameWin  ## Game win UI
@onready var points_label: Label = $Points  ## Points label
@onready var hit_material: ShaderMaterial = preload("res://resources/materials/hit.tres")  ## Hit material


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if not game_over_ui.visible and not pause_ui.visible:
			get_viewport().set_input_as_handled()
			var game: Game = get_tree().current_scene
			game.get_tree().paused = true
			pause_ui.visible = true


## Add the depleted animation to a shield
func _deplete_shield(shield: Sprite2D) -> void:
	# use the hit material, blinking red
	shield.material = hit_material

	# wait a the depleted time, remove it and make it red
	await get_tree().create_timer(shield_depleted_duration).timeout
	shield.material = null
	shield.modulate = Game.ENERGY_TYPE_COLOR[Game.EnergyType.DEPLETED]


## Show the game over UI
func game_over() -> void:
	# make the game over UI visible
	if not pause_ui.visible:
		game_over_ui.visible = true


## Called when a button is clicked in the game over UI
func _on_game_over_button_click(button: Button) -> void:
	match button:
		game_over_ui.restart_button:
			level_restart.emit()
		game_over_ui.exit_button:
			back_to_menu.emit()


## Called when a button is clicked in the pause UI
func _on_pause_button_click(button: Button) -> void:
	var game: Game = get_tree().current_scene
	game.get_tree().paused = false

	if button == pause_ui.exit_button:
		back_to_menu.emit()


## Show the game win UI
func game_win(high_score: int, score: int) -> void:
	# make the game over UI visible
	if not pause_ui.visible:
		game_win_ui.high_score = high_score
		game_win_ui.score = score
		game_win_ui.visible = true
		game_win_ui.blink = score >= high_score


## Called when a button is click in the game win UI
func _on_game_win_button_click(button: Button) -> void:
	match button:
		game_win_ui.restart_button:
			level_restart.emit()
		game_win_ui.exit_button:
			back_to_menu.emit()
