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

class_name BasicEnemy
extends Area2D
## Basic Enemy
##
## This is the basic enemy of the game, other enemies will inherit from this

signal destroyed(points: int)  ## Emitted when the enemy is destroyed with the amount of points to add

@export var max_life: int = 1  ## Max life units
@export var damage: int = 1  ## Damage units
@export var speed: float = 250  ## Speed of the enemy
@export var points: int = 150  ## Points that will add
@export var hit_duration: float = 1.0  ## How long the hit effect will last
@export var damage_on_player_hit: int = 1  ## Damage to this enemy when the player hits it

@export var energy: Game.EnergyType = Game.EnergyType.BLUE:  ## Energy type of the enemy
	set(value):
		_energy = value
		if not is_instance_valid(sprite_glow):
			return
		# set the color of the sprite glow depending on the energy type
		sprite_glow.modulate = Game.ENERGY_TYPE_COLOR[_energy]
		# reduce alpha
		sprite_glow.modulate.a = 0.75
	get:
		return _energy

var turbo: bool = false:  ## Indicates if is accelerating, visually the exhaust will be faster
	set(value):
		turbo = value
		# an enemy has an exhaust with two animations depending on turbo
		exhaust.play("turbo" if turbo else "normal")

var _direction: Vector2 = Vector2.LEFT  ## In which direction the enemy is moving, default left
var _on_screen: bool = false  ## Indicates if the enemy is on the screen
var _energy: Game.EnergyType = Game.EnergyType.BLUE  ## Energy type of the enemy

@onready var sprite: Sprite2D = $Sprite2D  ## Enemy sprite, the enemy ship
@onready var sprite_glow: Sprite2D = $SpriteGlow  ## Sprite glow, a glow effect for the enemy ship
@onready var exhaust: AnimatedSprite2D = $Exhaust  ## Exhaust animation
@onready var collision_shape: CollisionShape2D = $CollisionShape2D  ## Collision shape
@onready var ship_explosion: AnimatedSprite2D = $ShipExplosion  ## Ship explosion animation
@onready var explosion_sound: AudioStreamPlayer2D = $ExplosionSound  ## Explosion sound
@onready var points_label: Label = $Points  ## Label to show the points when destroyed
@onready var hit_material: ShaderMaterial = preload("res://resources/materials/hit.tres")  ## material for the hit effect
@onready var initial_speed: float = speed  ## Initial speed of the enemy
@onready var life: int = max_life  ## Current life units
@onready var player: Player = get_tree().get_first_node_in_group("player")  ## The player ship


## Called when the enemy is added to the scene
func _ready() -> void:
	exhaust.play("normal")
	points_label.text = str(points)
	energy = _energy


## Called every physics iteration, delta is the elapsed time since the previous call, this is FPS independent
func _physics_process(delta: float) -> void:
	# Move the enemy. If the enemy is not alive, move it at its initial speed. This ensures that enemies that were accelerating
	# when they died, that now are visually an explosion, are noticeable to the player, if not they will move too fast
	position += _direction * (speed if life > 0 else initial_speed) * delta


## Called when an area enters the enemy, current only player shots
func _on_area_entered(object: Area2D) -> void:
	# if the enemy is not on screen, do nothing, we do this because we spawn enemies off screen, our player shots are destroyed
	# of screen too, but there is an small chance that they collide just before they are off screen
	if not _on_screen:
		return
	# cast to player shot, destroy the shot, it will play its animation and do damage to this enemy
	var player_shot: PlayerShot = object as PlayerShot
	player_shot.destroy()

	# we get damage only if the energy type of the player is different to the enemy
	if player_shot._energy != _energy:
		_damage(player_shot.damage)


## Called when a body enters the enemy, current only the player
func _on_body_entered(body: Node2D) -> void:
	# this shouldn't happen since our player can not go off screen, however it is here for safety
	if not _on_screen:
		return

	# cast to player, damage the player and do damage to this enemy
	var player_body: Player = body as Player
	_damage(damage_on_player_hit)

	# we damage the player only if the energy type of the player is different to the enemy
	if player_body._energy != _energy:
		player_body.damage(damage)


## Called when the enemy goes off screen
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# delete the enemy, notify that is destroyed, 0 points since the player didn't destroy it
	destroyed.emit(0)
	queue_free()


## Called when the enemy is on screen
func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	# set that the enemy is on screen
	_on_screen = true


## Damage the enemy for an amount
func _damage(amount: int) -> void:
	# add hit effect
	_add_hit_effect()

	# damage the enemy and check if it is dead
	life -= amount
	if life <= 0:
		_die()


## Add a hit effect to the enemy
func _add_hit_effect() -> void:
	# we use a hit material that do a red blink effect, wait for the hit duration and remove the effect
	sprite.material = hit_material
	await get_tree().create_timer(hit_duration).timeout
	sprite.material = null


## Called when the enemy is destroyed
func _die() -> void:
	# signal that the enemy was destroyed and add the points
	destroyed.emit(points)

	# disable the collision shape, in the next physics iteration, so no more collisions
	collision_shape.set_deferred("disabled", true)

	# hide the enemy ship, glow and it exhaust
	sprite.visible = false
	exhaust.visible = false
	sprite_glow.visible = false

	# show the ship explosion and points, play the explosion animation and sound
	ship_explosion.visible = true
	points_label.visible = true
	ship_explosion.play()
	explosion_sound.play()

	# wait for the explosion animation to finish and delete the enemy
	await ship_explosion.animation_finished
	queue_free()


## Helper to check if the enemy is on the line of sight of the player, that means
## when the center of the enemy ship is in line with the player
func _is_player_on_line_of_sight() -> bool:
	# if the player has died we don't have a valid instance, so return false
	if not is_instance_valid(player):
		return false

	# get half of the height of the player ship, since is a centered sprite
	var texture: Texture2D = player.ship.texture
	var player_half_height: float = texture.get_height() / 2.0

	# calculate the top and bottom y position of the player
	var player_top_y: float = player.global_position.y - player_half_height
	var player_bottom_y: float = player.global_position.y + player_half_height

	# calculate if the enemy y position, is inside the player top and bottom y position
	return (global_position.y >= player_top_y) and (global_position.y <= player_bottom_y)
