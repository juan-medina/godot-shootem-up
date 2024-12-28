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

class_name Kamikaze
extends BasicEnemy
## Kamikaze Enemy
##
## This enemy will charge to the player when in line of sight

enum KamikazeState {
	IDLE,
	SEARCHING_FOR_PLAYER,
	KAMIKAZE,
}

@export var acceleration: float = 15

var _state: KamikazeState = KamikazeState.IDLE


func _physics_process(delta: float) -> void:
	if _state == KamikazeState.SEARCHING_FOR_PLAYER and super._is_player_on_line_of_sight():
		_state = KamikazeState.KAMIKAZE
		turbo = true

	if _state == KamikazeState.KAMIKAZE:
		speed += acceleration

	super._physics_process(delta)


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	_state = KamikazeState.SEARCHING_FOR_PLAYER
	super._on_visible_on_screen_notifier_2d_screen_entered()
