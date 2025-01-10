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
const _UPDATE_CREDITS_AND_FEATURES_MENU: String = "Update Credits & Features"  ## Update and features credits menu text
const _CREATE_RELEASE_MENU: String = "Create Release (Github & itch.io)"  ## Create release menu text
const _VERSION_KEY: String = "application/config/version"  ## Where the build version is stored

const JSON_FILE_PATH: String = "res://resources/credits/credits.json"  ## The JSON file with the credits
const FEATURES_JSON_FILE: String = "res://resources/credits/features.json"  ## The JSON file with the features
const ABOUT_BBCODE_TEMPLATE_FILE: String = "res://resources/credits/about_template.bbcode"  ## The about BBCode template file
const ABOUT_BBCODE_FILE: String = "res://resources/credits/about.bbcode"  ## The about BBCode file
const ITCHIO_HTML_TEMPLATE_FILE: String = "res://resources/credits/itchio_template.html"  ## The itchio HTML template file
const ITCHIO_HTML_OUTPUT_FILE: String = "res://resources/credits/itchio.html"  ## The itchio HTML output file
const README_TEMPLATE_FILE: String = "res://resources/credits/README_template.md"  ## The README template file
const README_OUTPUT_FILE: String = "res://README.md"  ## The README output file

var _shortcut: Shortcut = preload("res://addons/ci_tools/shortcut.tres")  ## The shortcut to use


## Plugin enabled
func _enter_tree() -> void:
	# add our tool menus item to our functions
	add_tool_menu_item(_VERSION_INCREASE_MENU, _increase_build_and_launch)
	add_tool_menu_item(_UPDATE_CREDITS_AND_FEATURES_MENU, _update_credits_and_features)
	add_tool_menu_item(_CREATE_RELEASE_MENU, _create_release)


## Plugin disabled
func _exit_tree() -> void:
	# remove our tool menu item
	remove_tool_menu_item(_VERSION_INCREASE_MENU)
	remove_tool_menu_item(_UPDATE_CREDITS_AND_FEATURES_MENU)
	remove_tool_menu_item(_CREATE_RELEASE_MENU)


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
func _update_credits_and_features() -> void:
	# Read JSON file for credits
	var json_file: FileAccess = FileAccess.open(JSON_FILE_PATH, FileAccess.READ)
	if not json_file:
		push_error("JSON file not found: %s" % JSON_FILE_PATH)
		return
	var json_data: String = json_file.get_as_text()
	json_file.close()
	var credits_data: Dictionary = JSON.parse_string(json_data)

	# Read JSON file for features
	var features_file: FileAccess = FileAccess.open(FEATURES_JSON_FILE, FileAccess.READ)
	if not features_file:
		push_error("Features JSON file not found: %s" % FEATURES_JSON_FILE)
		return
	var features_data: String = features_file.get_as_text()
	features_file.close()
	var features: Dictionary = JSON.parse_string(features_data)

	# Generate the about BBCode
	_generate_about_bbcode(credits_data)

	# Generate the itchio HTML
	_generate_itchio_html(credits_data, features)

	# Generate the README markdown
	_generate_readme(credits_data, features)


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

	# Write the about BBCode file
	_write_file(ABOUT_BBCODE_TEMPLATE_FILE, ABOUT_BBCODE_FILE, {"CREDITS": bbcode})


## Generate the itchio HTML
func _generate_itchio_html(credits_data: Dictionary, features: Dictionary) -> void:
	# Generate HTML for credits
	var html: String = "<ul>\n"
	for credit in credits_data["credits"]:
		html += "    <li>\n"
		html += "        %s:\n" % credit["role"]
		html += '        <a href="%s">%s</a>\n' % [credit["url"], credit["name"]]
		if "author" in credit:
			html += '        by <a href="%s">%s</a>.\n' % [credit["author"]["url"], credit["author"]["name"]]
		if "details" in credit:
			html += "        <ul>\n"
			for detail in credit["details"]:
				html += "            <li>%s: %s.</li>\n" % [detail["type"], detail["name"]]
			html += "        </ul>\n"
		html += "    </li>\n"
	html += "</ul>"

	# Generate HTML for features
	var features_html: String = "<ul>\n"
	for feature in features["features"]:
		features_html += "    <li>%s" % feature["text"]
		if "details" in feature:
			features_html += "\n        <ul>\n"
			for detail in feature["details"]:
				features_html += "            <li>%s</li>\n" % detail["type"]
			features_html += "        </ul>\n"
		features_html += "    </li>\n"
	features_html += "</ul>"

	# Write the HTML file
	_write_file(ITCHIO_HTML_TEMPLATE_FILE, ITCHIO_HTML_OUTPUT_FILE, {"CREDITS": html, "FEATURES": features_html})


## Generate the README markdown
func _generate_readme(credits_data: Dictionary, features: Dictionary) -> void:
	# Generate markdown for credits
	var credits_md: String = ""
	for i in range(1, credits_data["credits"].size()):
		var credit = credits_data["credits"][i]
		credits_md += (
			"- %s: [%s](%s) by [%s](%s).\n" % [credit["role"], credit["name"], credit["url"], credit["author"]["name"], credit["author"]["url"]]
		)
		if "details" in credit:
			for detail in credit["details"]:
				credits_md += "    - %s: %s.\n" % [detail["type"], detail["name"]]

	# Generate markdown for features
	var features_md: String = ""
	for feature in features["features"]:
		features_md += "- %s\n" % feature["text"]
		if "details" in feature:
			for detail in feature["details"]:
				features_md += "    - %s\n" % detail["type"]

	# Write the README file
	_write_file(README_TEMPLATE_FILE, README_OUTPUT_FILE, {"CREDITS": credits_md, "FEATURES": features_md})


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


## Create a release and publish to github
func _create_release() -> void:
	# get the current version: major.minor.patch.build
	var version_string: String = ProjectSettings.get_setting(_VERSION_KEY)

	# output from commands
	var output: Array[String]

	# check if github client is installed
	if not OS.execute("gh", ["--version"]) == 0:
		push_error("Github CLI is not installed, please install it.")
		return

	print("Creating release: %s..." % version_string)

	## launch: git tag -a $version -m 'Release $version'
	if not OS.execute("git", ["tag", "-a", version_string, "-m", "Release %s" % version_string], output) == 0:
		push_error("Failed to create git tag. %s" % output)
		return

	## launch: git push --tags
	if not OS.execute("git", ["push", "--tags"], output) == 0:
		push_error("Failed to push tags. %s" % output)
		return

	## launch: gh release create $version -F release_notes.md -t $version
	if not OS.execute("gh", ["release", "create", version_string, "-F", "release_notes.md", "-t", version_string], output) == 0:
		push_error("Failed to create release. %s" % output)
		return

	print("Release %s created successfully." % version_string)
