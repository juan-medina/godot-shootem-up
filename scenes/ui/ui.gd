class_name UI extends Control

@export var points: int = 0:
	set(value):
		points = value
		$Points.text = str(points)

func _ready() -> void:
	var version = ProjectSettings.get_setting("application/config/version").split(".")

	if OS.is_debug_build():
		version[3] = str(int(version[3]) + 1)
		var new_version = "%s.%s.%s.%s" % [version[0], version[1], version[2], version[3]]
		ProjectSettings.set_setting("application/config/version", new_version)
		ProjectSettings.save()

	$Version/Major.text = version[0]
	$Version/Minor.text = version[1]
	$Version/Patch.text = version[2]
	$Version/Build.text = version[3]

