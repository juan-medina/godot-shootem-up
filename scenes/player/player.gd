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

signal shields_changed(current_shields: int)  ## Signal when the player's shields change
signal energy_type_changed(energy_type: Game.EnergyType)  ## Signal when the player's energy type change

@export var speed: float = 400  ## How fast the player moves
@export var fire_rate: float = 0.20  ## How fast the player fires
@export var max_shield: int = 3  ## Max shield units
@export var hit_duration: float = 1.0  ## How long the hit effect will last

var previous_direction: Vector2 = Vector2.ZERO  ## Previous direction the player was moving in

var previous_exhaust: String = "normal"  ## The previous exhaust animation
var shot_on_cd: bool = false  ## Indicates if the player shot is on cooldown
var dead: bool = false  ## Indicates if the player is dead
var won: bool = false  ## Indicates if the player has won

var _energy: Game.EnergyType = Game.EnergyType.BLUE  ## Player energy type

@onready var ship: Sprite2D = $Ship  ## Player ship
@onready var ship_glow: Sprite2D = $ShipGlow  ## Player ship glow
@onready var exhaust_anim: AnimatedSprite2D = $Exhaust  ## Exhaust animation
@onready var shot_point: Marker2D = $ShotPoint  ## Shot spawn point
@onready var shot_sound: AudioStreamPlayer2D = $ShotSound  ## Shot sound
@onready var energy_change_sound: AudioStreamPlayer2D = $EnergyChangeSound  ## Energy change sound
@onready var shot_out_effect: AnimatedSprite2D = $ShotOutEffect  ## Shot out effect
@onready var ship_explosion: AnimatedSprite2D = $ShipExplosion  ## Ship explosion effect
@onready var collision: CollisionPolygon2D = $Collision  ## Collision
@onready var shot_scene: PackedScene = preload("res://scenes/player/shot/player_shot.tscn")  ## Shot scene
@onready var hit_material: ShaderMaterial = preload("res://resources/materials/hit.tres")  ## Hit material
@onready var half_size: Vector2 = ship.region_rect.size * scale / 2  ## Half size of the ship
@onready var current_shields: int = max_shield  ## Current shields


## Called when the player is added to the scene
func _ready() -> void:
	# play the normal exhaust
	exhaust_anim.play(previous_exhaust)


## Called every physics iteration, delta is the elapsed time since the previous call, this is FPS independent
func _physics_process(_delta: float) -> void:
	# if the player is not dead, do the move and shot logic
	if not dead and not won:
		_move_logic()
		_shot_logic()


## Move the player and clamp it to the screen
func _move_logic() -> void:
	# calculate the x and y axis based on the input to create the direction
	var x_axis: float = Input.get_axis("left", "right")
	var y_axis: float = Input.get_axis("up", "down")
	var direction: Vector2 = Vector2(x_axis, y_axis)

	# calculate the velocity based on the direction and speed
	velocity = direction * speed

	# if the direction has changed, call the direction changed
	if direction != previous_direction:
		_direction_changed(direction)
		previous_direction = direction

	# move the player
	if direction != Vector2.ZERO:
		# waiting for https://github.com/godotengine/godot-proposals/issues/5870
		@warning_ignore("return_value_discarded")
		move_and_slide()

	# clamp the player, we do this even without moving because the user can resize the window
	var clamp_max: Vector2 = get_viewport_rect().size
	var limit: Vector2 = clamp_max - half_size
	position = position.clamp(half_size, limit)


## Called when the direction changes
func _direction_changed(direction: Vector2) -> void:
	# determine the exhaust animation
	var exhaust: String = "turbo" if direction.x > 0 else "normal"

	# if the exhaust has changed, play the correct animation
	if previous_exhaust != exhaust:
		exhaust_anim.play(exhaust)
		previous_exhaust = exhaust


## Handle the player shot logic
func _shot_logic() -> void:
	# if the player shot is not on cooldown and the fire button is pressed, shot
	if Input.is_action_pressed("fire") and not shot_on_cd:
		_shot()
		# shot cooldown
		shot_on_cd = true
		await get_tree().create_timer(fire_rate).timeout
		shot_on_cd = false
	## Change the player energy type, cycle between green and blue
	if Input.is_action_just_pressed("change_energy"):
		if _energy == Game.EnergyType.GREEN:
			_energy = Game.EnergyType.BLUE
		else:
			_energy = Game.EnergyType.GREEN
		# update the ship glow color and emit the signal that the energy type has changed
		ship_glow.modulate = Game.ENERGY_TYPE_COLOR[_energy]
		# reduce alpha to halve
		ship_glow.modulate.a = 0.5
		energy_type_changed.emit(_energy)
		energy_change_sound.play()


## Make the player shot
func _shot() -> void:
	# play the shot sound
	shot_sound.play()

	# spawn the shot from the spawn point
	var shot_instance: PlayerShot = shot_scene.instantiate()
	get_parent().add_child(shot_instance)
	shot_instance.init(shot_point, _energy)

	# play the shot out effect
	shot_out_effect.modulate = Game.ENERGY_TYPE_COLOR[_energy]
	shot_out_effect.visible = true
	shot_out_effect.play()
	await shot_out_effect.animation_finished
	shot_out_effect.visible = false


## Damage the player
func damage(amount: int) -> void:
	if won:
		return
	# add hit effect to the player
	_add_hit_effect()

	# remove player shields and emit the signal
	current_shields -= amount
	shields_changed.emit(current_shields)

	# if the player shields are depleted, the player is dead
	if current_shields <= 0:
		_die()


## Add hit effect to the player
func _add_hit_effect() -> void:
	# we use a hit material that do a red blink effect, wait for the hit duration and remove the effect
	self.material = hit_material
	await get_tree().create_timer(hit_duration).timeout
	self.material = null


## Kill the player
func _die() -> void:
	# set that the player is dead
	dead = true

	# disable the collision, in the next physics iteration, so no more collisions
	collision.set_deferred("disabled", true)

	# hide the player ship and it exhaust
	ship_glow.visible = false
	ship.visible = false
	exhaust_anim.visible = false

	# show the ship explosion, play the explosion animation
	ship_explosion.visible = true
	ship_explosion.play()

	# wait for the explosion animation to finish and delete the player
	await ship_explosion.animation_finished
	queue_free()
