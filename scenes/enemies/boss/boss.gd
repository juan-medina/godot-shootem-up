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

class_name Boss
extends BasicEnemy
## Boss BasicEnemy
##
## This is our game boss

## The state of the boss
enum BossState {
	IDLE,
	ENTERING,
	UP,
	DOWN,
}

@export var change_energy_time: float = 2.0  ## Time to change energy
@export var wait_to_move: float = 1.5  ## Time to wait before moving
@export var vertical_speed: float = 100  ## Speed of the boss when moving up or down

var _state: BossState = BossState.IDLE  ## The boss state, idle by default
var _time_passed: float = 0.0  ## Time passed since the boss started

@onready var ship: Sprite2D = $Sprite2D  ## boss ship
@onready var ship_size: Vector2 = ship.region_rect.size * scale * 2  ## Boss ship size


## Called every physics iteration, delta is the elapsed time since the previous call, this is FPS independent
func _physics_process(delta: float) -> void:
	# If the boss is dead, stop the movement
	if life <= 0:
		_direction = Vector2.ZERO
	elif _state == BossState.UP or _state == BossState.DOWN:  # If the boss is moving up or down
		# If the boss is at the top or bottom of the screen, change the direction
		if global_position.y < 100 and _direction == Vector2.UP:
			_direction = Vector2.DOWN
			turbo = false
		elif global_position.y > 600 and _direction == Vector2.DOWN:
			_direction = Vector2.UP
			turbo = true

		# Switch energy between green and blue every change_energy_time
		_time_passed += delta
		if _time_passed >= change_energy_time:
			_time_passed = 0.0
			if energy == Game.EnergyType.BLUE:
				energy = Game.EnergyType.GREEN
			else:
				energy = Game.EnergyType.BLUE

	# the basic enemy will calculate the movement
	super._physics_process(delta)


## Called when the enemy enters the screen
func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	# When the boss enters the screen, start the entering state
	super._on_visible_on_screen_notifier_2d_screen_entered()
	_state = BossState.ENTERING
	_direction = Vector2.ZERO
	# await the wait_to_move time to start moving
	await get_tree().create_timer(wait_to_move).timeout
	speed = vertical_speed
	_state = BossState.UP
	_direction = Vector2.UP
	_time_passed = 0.0
