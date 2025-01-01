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

class_name Version
extends Control
## Version control
##
## Display the game version

const _VERSION_KEY: String = "application/config/version"  ## Where the game version is stored

var _click_cd: float = 1
var _click_on_cd: bool = false

@onready var version_labels: RichTextLabel = $RichTextLabel  ## The label that will display the version
@onready var click_sound: AudioStreamPlayer2D = $ClickSound  ## Click sound


## Called when the version is added to the scene
func _ready() -> void:
	# get the game version
	var version_string: String = ProjectSettings.get_setting(_VERSION_KEY)
	# create an array with the version e.g. for version 1.2.3.4 it will be [v, 1, 2, 3, 4]
	var version: PackedStringArray = ("v." + version_string).split(".")

	# get the version colored
	var colors: Array[String] = ["#F000F0", "#FF0000", "#FFA500", "#FFFF00", "#00FF00"]
	for i: int in range(version.size()):
		version[i] = _get_bbcode_text_color(version[i], colors[i])
	var text: String = ".".join(version)

	# add url and right tag
	text = _get_bbcode_url_text(text, "https://github.com/juan-medina/godot-shootem-up/releases/latest")
	text = _get_bbcode_right_text(text)

	# set the version label
	version_labels.text = text


## Returns the bbcode for a text given color e.g. [color=red]text[/color]
static func _get_bbcode_text_color(text: String, color: String) -> String:
	return "[color=%s]%s[/color]" % [color, text]


## Returns the bbcode for a tag with given value e.g. [tag=value]text[/tag]
static func _get_bbcode_text_tag_value(tag: String, value: String, text: String) -> String:
	return "[%s=%s]%s[/%s]" % [tag, value, text, tag] if value else "[%s]%s[/%s]" % [tag, text, tag]


## Returns the bbcode for a tag e.g. [tag]text[/tag]
static func _get_bbcode_text_tag(tag: String, text: String) -> String:
	return _get_bbcode_text_tag_value(tag, "", text)


## Returns the bbcode for a url with given text e.g. [url=https://url.com]text[/url]
static func _get_bbcode_url_text(text: String, url: String) -> String:
	return _get_bbcode_text_tag_value("url", url, text)


## Returns the bbcode for a right tag with given text e.g. [right]text[/right]
static func _get_bbcode_right_text(text: String) -> String:
	return _get_bbcode_text_tag("right", text)


## Called when a meta is clicked
func _on_meta_clicked(meta: String) -> void:
	if not _click_on_cd and (meta.begins_with("https://") or meta.begins_with("http://")):
		_click_on_cd = true
		click_sound.play()
		if not OS.shell_open(meta) == OK:
			assert(false, "Failed to open url: " + meta)
		await get_tree().create_timer(_click_cd).timeout
		_click_on_cd = false
