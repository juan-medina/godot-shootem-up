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

class_name EnemyShot
extends Area2D
## Player shot
##
## Shots from the player

@export var speed: int = 9  ## How fast the shot moves
@export var damage: int = 1  ## How much damage the shot does

var direction: Vector2 = Vector2.LEFT  ## Direction of the shot
var _energy: Game.EnergyType = Game.EnergyType.BLUE  ## Shot energy type

@onready var shot_explosion: AnimatedSprite2D = $ShotExplosion  ## Explosion animation
@onready var collision_shape: CollisionShape2D = $CollisionShape2D  ## Collision shape
@onready var sprite: Sprite2D = $Sprite2D  ## Shot sprite
@onready var shot_hit: AudioStreamPlayer2D = $ShotHit  ## Shot hit sound


## Called every physics iteration, delta is the elapsed time since the previous call, this is FPS independent
func _physics_process(_delta: float) -> void:
	global_position += direction * speed


## Called when the shot goes off screen
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# delete the shot
	queue_free()


## Initialize the shot when from a spawn point and an energy type
func init(from: Node2D, energy: Game.EnergyType, shot_direction: Vector2) -> void:
	global_position = from.global_position
	_energy = energy
	sprite.modulate = Game.ENERGY_TYPE_COLOR[_energy]
	direction = shot_direction
	rotation = direction.angle()
	sprite.flip_h = false

## Destroy the shot
func destroy() -> void:
	# disable the collision shape, in the next physics iteration, so no more collisions
	collision_shape.set_deferred("disabled", true)

	# stop the shot for moving, hide the sprite and play the hit sound
	direction = Vector2.ZERO
	sprite.visible = false
	shot_hit.play()

	# show the explosion and play the explosion animation with the energy color
	shot_explosion.modulate = Game.ENERGY_TYPE_COLOR[_energy]
	shot_explosion.visible = true
	shot_explosion.play()

	# wait for the explosion animation to finish and delete the shot
	await shot_explosion.animation_finished
	queue_free()

## Called when the shot enters in a body
func _on_body_entered(body:Node2D) -> void:
	var player_body: Player = body as Player
	# we damage the player only if the energy type of the player is different to the enemy
	if player_body._energy != _energy:
		player_body.damage(damage)
	# destroy the shot
	destroy()
