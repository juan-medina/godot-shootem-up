class_name BasicEnemy extends Area2D

func _on_area_entered(object: Area2D) -> void:
	if object is PlayerShot:
		add_hit_effect()
		object.destroy()


@export var hit_duration: float = 1.0


@onready var hit_material: ShaderMaterial = preload("res://resources/materials/hit.tres")


var remove_material_timer: Timer = null


func add_hit_effect() -> void:
	if remove_material_timer == null:
		remove_material_timer = Timer.new()
		remove_material_timer.one_shot = true
		remove_material_timer.timeout.connect(_on_remove_material_timer_timeout.bind())
		add_child(remove_material_timer)

	if remove_material_timer.is_stopped():
		self.material = hit_material
	else:
		remove_material_timer.stop()
	remove_material_timer.start(hit_duration)

func _on_remove_material_timer_timeout() -> void:
	self.material = null
