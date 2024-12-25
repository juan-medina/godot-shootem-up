class_name UI extends Control

@export var points: int = 0:
	set(value):
		points = value
		$Points.text = str(points)

func _ready() -> void:
	var version_split = ProjectSettings.get_setting("application/config/version").split(".")
	$Version/Major.text = version_split[0]
	$Version/Minor.text = version_split[1]
	$Version/Patch.text = version_split[2]
	$Version/Build.text = version_split[3]
