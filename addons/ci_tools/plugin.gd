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

const _VERSION_INCREASE_MENU: String = "Build Version: Increase And Launch Main Scene (CTRL+F5)"  ## Version increase menu text
const _UPDATE_CREDITS_MENU: String = "Update Credits"  ## Update credits menu text
const _VERSION_KEY: String = "application/config/version"  ## Where the build version is stored

const _CREDITS_JSON_FILE: String = "res://resources/credits/credits.json"  ## The JSON file with the credits data

const _BBCODE_TEMPLATE_FILE: String = "res://resources/credits/about_template.bbcode"  ## The template file for the about BBCode
const _ABOUT_BBCODE_FILE: String = "res://resources/credits/about.bbcode"  ## The output file for the about BBCode

var _shortcut: Shortcut = preload("res://addons/ci_tools/shortcut.tres")  ## The shortcut to use


## Plugin enabled
func _enter_tree() -> void:
	# add our tool menus item to our functions
	add_tool_menu_item(_VERSION_INCREASE_MENU, _increase_build_and_launch)
	add_tool_menu_item(_UPDATE_CREDITS_MENU, _update_credits)


## Plugin disabled
func _exit_tree() -> void:
	# remove our tool menu item
	remove_tool_menu_item(_VERSION_INCREASE_MENU)
	remove_tool_menu_item(_UPDATE_CREDITS_MENU)


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


## Update the credits menu item
func _update_credits() -> void:
	# Read JSON file
	var json_file: FileAccess = FileAccess.open(_CREDITS_JSON_FILE, FileAccess.READ)
	if not json_file:
		push_error("JSON file not found: %s" % _CREDITS_JSON_FILE)
		return
	var json_data: String = json_file.get_as_text()
	json_file.close()
	var credits_data: Dictionary = JSON.parse_string(json_data)

	# Generate the about BBCode
	_generate_about_bbcode(credits_data)


## Generate the about BBCode
func _generate_about_bbcode(credits_data: Dictionary) -> void:
	# Generate BBCode for credits
	var bbcode: String = ""
	for credit in credits_data["credits"]:
		bbcode += "- %s: [url=%s][color=#59B0F0]%s[/color][/url]" % [credit["role"], credit["url"], credit["name"]]
		if "author" in credit:
			bbcode += " by [url=%s][color=#59B0F0]%s[/color][/url]" % [credit["author"]["url"], credit["author"]["name"]]
		bbcode += "."
		if "details" in credit:
			for detail in credit["details"]:
				bbcode += "\n    - %s: %s." % [detail["type"], detail["name"]]
		bbcode += "\n"

	# Remove the last newline character
	if bbcode.ends_with("\n"):
		bbcode = bbcode.substr(0, bbcode.length() - 1)

	## Write the about BBCode file
	_write_file(_BBCODE_TEMPLATE_FILE, _ABOUT_BBCODE_FILE, {"CREDITS": bbcode})


## Write a output file using a template file and the giving data
func _write_file(template_path: String, output_path: String, replacements: Dictionary) -> void:
	# Read template file
	var template_file: FileAccess = FileAccess.open(template_path, FileAccess.READ)
	if not template_file:
		push_error("Template file not found: %s" % template_path)
		return
	var template_text: String = template_file.get_as_text()
	template_file.close()

	# Do template replacements
	for data in replacements:
		var key: String = "%%" + data + "%%"
		template_text = template_text.replace(key, replacements[data])

	# Write to output file
	var output_file: FileAccess = FileAccess.open(output_path, FileAccess.WRITE)
	output_file.store_string(template_text)
	output_file.close()