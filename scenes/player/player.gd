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

class_name Player
extends CharacterBody2D
## Player
##
## Player logic

signal shields_changed(current_shields: int)

@export var speed: float = 400
@export var fire_rate: float = 0.20
@export var max_shield: int = 3
@export var hit_duration: float = 1.0

var previous_direction: Vector2 = Vector2.ZERO

var previous_exhaust: String = "normal"
var shot_on_cd: bool = false
var dead: bool = false

@onready var ship: Sprite2D = $Ship
@onready var exhaust_anim: AnimatedSprite2D = $Exhaust
@onready var shot_point: Marker2D = $ShotPoint
@onready var shot_sound: AudioStreamPlayer2D = $ShotSound
@onready var shot_out_effect: AnimatedSprite2D = $ShotOutEffect
@onready var ship_explosion: AnimatedSprite2D = $ShipExplosion
@onready var collision: CollisionPolygon2D = $Collision
@onready var shot_scene: PackedScene = preload("res://scenes/player/shot/player_shot.tscn")
@onready var hit_material: ShaderMaterial = preload("res://resources/materials/hit.tres")
@onready var half_size: Vector2 = ship.region_rect.size * scale / 2
@onready var current_shields: int = max_shield


func _ready() -> void:
	exhaust_anim.play(previous_exhaust)


func _physics_process(_delta: float) -> void:
	if !dead:
		_move_logic()
		_shot_logic()


func _move_logic() -> void:
	var x_axis: float = Input.get_axis("left", "right")
	var y_axis: float = Input.get_axis("up", "down")

	var direction: Vector2 = Vector2(x_axis, y_axis)
	velocity = direction * speed

	if direction != previous_direction:
		_direction_changed(direction)
		previous_direction = direction

	if direction != Vector2.ZERO:
		# waiting for https://github.com/godotengine/godot-proposals/issues/5870
		@warning_ignore("return_value_discarded")
		move_and_slide()

	# we do this even without moving because the user can resize the window
	var clamp_max: Vector2 = get_viewport_rect().size
	var limit: Vector2 = clamp_max - half_size
	position = position.clamp(half_size, limit)


func _direction_changed(direction: Vector2) -> void:
	var exhaust: String = "turbo" if direction.x > 0 else "normal"
	if previous_exhaust != exhaust:
		exhaust_anim.play(exhaust)
		previous_exhaust = exhaust


func _shot_logic() -> void:
	if Input.is_action_pressed("fire") && !shot_on_cd:
		shot_on_cd = true
		_shot()
		await get_tree().create_timer(fire_rate).timeout
		shot_on_cd = false


func _shot() -> void:
	shot_out_effect.visible = true
	shot_out_effect.play()
	shot_sound.play()
	var shot_instance: PlayerShot = shot_scene.instantiate()
	shot_instance.init(shot_point)
	get_parent().add_child(shot_instance)


func _on_shot_out_effect_animation_finished() -> void:
	shot_out_effect.visible = false


func _add_hit_effect() -> void:
	self.material = hit_material
	await get_tree().create_timer(hit_duration).timeout
	self.material = null


func _die() -> void:
	dead = true
	collision.set_deferred("disabled", true)
	ship.visible = false
	exhaust_anim.visible = false
	ship_explosion.visible = true
	ship_explosion.play()
	await ship_explosion.animation_finished
	queue_free()


func damage(amount: int) -> void:
	_add_hit_effect()
	current_shields -= amount
	shields_changed.emit(current_shields)
	if current_shields <= 0:
		_die()
