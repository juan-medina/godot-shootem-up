@tool extends EditorPlugin

const _TOOL_MENU_ITEM_NAME: String = "Build Version: Increase And Launch Main Scene (CTRL+F5)"
var shortcut: Shortcut = preload("res://addons/build_version/default_shortcut.tres")


func _enter_tree() -> void:
	add_tool_menu_item(_TOOL_MENU_ITEM_NAME, _increase_build_and_launch)


func _exit_tree() -> void:
	remove_tool_menu_item(_TOOL_MENU_ITEM_NAME)


func _shortcut_input(event: InputEvent) -> void:
	if not Engine.is_editor_hint() or not event.is_pressed() or event.is_echo(): return
	if shortcut.matches_event(event):
		_increase_build_and_launch()


func _increase_build_and_launch() -> void:
	if Engine.is_editor_hint():
		var version = ProjectSettings.get_setting("application/config/version").split(".")
		version[3] = str(int(version[3]) + 1)
		var new_version = "%s.%s.%s.%s" % [version[0], version[1], version[2], version[3]]
		ProjectSettings.set_setting("application/config/version", new_version)
		ProjectSettings.save()
		EditorInterface.play_main_scene()



