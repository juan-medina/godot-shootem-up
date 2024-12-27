class_name UI extends Control


@onready var shields_sprites: Array[Sprite2D] = [$ShieldBar/Shield1, $ShieldBar/Shield2, $ShieldBar/Shield3]
@onready var hit_material: ShaderMaterial = preload("res://resources/materials/hit.tres")


@export var shield_depleted_duration: float = 0.25


func _ready() -> void:
	var version = ProjectSettings.get_setting("application/config/version").split(".")

	$Version/Major.text = version[0]
	$Version/Minor.text = version[1]
	$Version/Patch.text = version[2]
	$Version/Build.text = version[3]


@export var points: int = 0:
	set(value):
		points = value
		$Points.text = str(points)

@export var shields: int = 0:
	set(value):
		shields = value
		shields_sprites[value].material = hit_material
		await get_tree().create_timer(shield_depleted_duration).timeout
		shields_sprites[value].material = null
		shields_sprites[value].visible = false