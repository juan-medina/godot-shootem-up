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

signal game_over_ok
signal game_over_cancel

const _VERSION_KEY: String = "application/config/version"

@export var shield_depleted_duration: float = 0.25

var points: int = 0:
	set(value):
		points = value
		points_label.text = str(points)

var shields: int = 0:
	set(value):
		shields = value
		_deplete_shield(shields_sprites[value])

@onready
var shields_sprites: Array[Sprite2D] = [$ShieldBar/Shield1, $ShieldBar/Shield2, $ShieldBar/Shield3]
@onready
var version_labels: Array[Label] = [$Version/Major, $Version/Minor, $Version/Patch, $Version/Build]
@onready var game_over_panel: Panel = $GameOver
@onready var game_over_ok_button: Button = $GameOver/OK
@onready var points_label: Label = $Points
@onready var hit_material: ShaderMaterial = preload("res://resources/materials/hit.tres")


func _ready() -> void:
	var version_string: String = ProjectSettings.get_setting(_VERSION_KEY)
	var version: PackedStringArray = version_string.split(".")

	for i: int in range(version.size()):
		version_labels[i].text = version[i]


func _deplete_shield(shield: Sprite2D) -> void:
	shield.material = hit_material
	await get_tree().create_timer(shield_depleted_duration).timeout
	shield.material = null
	shield.visible = false


func game_over() -> void:
	game_over_panel.visible = true
	game_over_ok_button.grab_focus()


func _on_game_over_ok() -> void:
	game_over_ok.emit()


func _on_game_over_cancel() -> void:
	game_over_cancel.emit()
