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

class_name Wave
extends Node2D
## Wave Node2D
##
## This is the basic enemy wave

signal enemy_die(points: int)  ## Emitted when an enemy is destroyed with the amount of points to add
signal wave_destroyed  ## Emitted when the wave is destroyed

var _total_enemies: int = 0  ## Total enemies in the wave


## when this wave is add to the scene
func _ready() -> void:
	# get all the children that are BasicEnemy
	var children: Array[Node] = find_children("*", "BasicEnemy")
	for enemy: BasicEnemy in children:
		_total_enemies += 1
		if enemy.destroyed.connect(_on_enemy_died) != OK:
			assert(false, "Error connecting destroyed signal")


## Called when an enemy is destroyed
func _on_enemy_died(points: int) -> void:
	# emit the enemy_die signal
	enemy_die.emit(points)
	# reduce the total enemies and if there are no more enemies, wait 3 seconds and free the wave
	_total_enemies -= 1
	if _total_enemies == 0:
		wave_destroyed.emit()
		await get_tree().create_timer(3.0).timeout
		queue_free()
