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

@tool
class_name BuildVersionIncreasePlugin
extends EditorPlugin
## Increase the build version and launch the main scene
##
## This plugin adds a tool menu item to the editor, and a shortcut, that will
## increase the build number and launch the main scene.

const _TOOL_MENU: String = "Build Version: Increase And Launch Main Scene (CTRL+F5)"  ## Tool menu text
const _VERSION_KEY: String = "application/config/version"  ## Where the build version is stored
var _shortcut: Shortcut = preload("res://addons/build_version_increase/shortcut.tres")  ## The shortcut to use


## Plugin enabled
func _enter_tree() -> void:
	# add our tool menu item to our function
	add_tool_menu_item(_TOOL_MENU, _increase_build_and_launch)


## Plugin disabled
func _exit_tree() -> void:
	# remove our tool menu item
	remove_tool_menu_item(_TOOL_MENU)


## When we get any shortcut pressed
func _shortcut_input(event: InputEvent) -> void:
	# return if we're not in the editor, if is not a key press, or a repetition
	if not Engine.is_editor_hint() or not event.is_pressed() or event.is_echo():
		return

	# if is our shortcut
	if _shortcut.matches_event(event):
		_increase_build_and_launch()


## Increase the project build number, save it and launch the main scene
func _increase_build_and_launch() -> void:
	# get the current version: major.minor.patch.build
	var version_string: String = ProjectSettings.get_setting(_VERSION_KEY)
	var version: PackedStringArray = version_string.split(".")

	# increase the build number
	version[3] = str(int(version[3]) + 1)

	# save the new version
	ProjectSettings.set_setting(_VERSION_KEY, ".".join(version))
	ProjectSettings.save()

	# launch the main scene
	EditorInterface.play_main_scene()
