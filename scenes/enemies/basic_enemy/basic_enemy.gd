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

signal destroyed(points: int)

@export var max_life: int = 1
@export var damage: int = 1
@export var speed: float = 250
@export var points: int = 150
@export var hit_duration: float = 1.0

var turbo: bool = false:
	set(value):
		turbo = value
		exhaust.play("turbo" if turbo else "normal")

var _direction: Vector2 = Vector2.LEFT
var _on_screen: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var exhaust: AnimatedSprite2D = $Exhaust
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var ship_explosion: AnimatedSprite2D = $ShipExplosion
@onready var explosion_sound: AudioStreamPlayer2D = $ExplosionSound
@onready var points_label: Label = $Points
@onready var hit_material: ShaderMaterial = preload("res://resources/materials/hit.tres")
@onready var initial_speed: float = speed
@onready var life: int = max_life
@onready var player: Player = get_tree().get_first_node_in_group("player")


func _ready() -> void:
	exhaust.play("normal")
	points_label.text = str(points)


func _physics_process(delta: float) -> void:
	position += _direction * (speed if sprite.visible else initial_speed) * delta


func _on_area_entered(object: Area2D) -> void:
	if not _on_screen:
		return
	var player_shot: PlayerShot = object as PlayerShot
	if player_shot:
		player_shot.destroy()
		_damage(player_shot.damage)


func _on_body_entered(body: Node2D) -> void:
	if not _on_screen:
		return
	var player_body: Player = body as Player
	if player_body:
		_damage(max_life)
		player_body.damage(damage)


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	_on_screen = true


func _damage(amount: int) -> void:
	life -= amount
	_add_hit_effect()
	if life <= 0:
		_die()


func _add_hit_effect() -> void:
	self.material = hit_material
	await get_tree().create_timer(hit_duration).timeout
	self.material = null


func _die() -> void:
	sprite.visible = false
	exhaust.visible = false
	points_label.visible = true
	collision_shape.set_deferred("disabled", true)
	ship_explosion.visible = true
	ship_explosion.play()
	explosion_sound.play()
	destroyed.emit(points)
	await ship_explosion.animation_finished
	queue_free()


func _is_player_on_line_of_sight() -> bool:
	if not is_instance_valid(player):
		return false

	var texture: Texture2D = player.ship.texture
	var player_half_height: float = texture.get_height() / 2.0

	var player_top_y: float = player.global_position.y - player_half_height
	var player_bottom_y: float = player.global_position.y + player_half_height

	return (global_position.y >= player_top_y) and (global_position.y <= player_bottom_y)
