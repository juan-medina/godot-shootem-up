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
extends HBoxContainer
## Version control
##
## Display the game version

const _VERSION_KEY: String = "application/config/version"  ## Where the game version is stored

@onready var version_labels: Array[Label] = [$Major, $Minor, $Patch, $Build]  ## Version labels


## Called when the version is added to the scene
func _ready() -> void:
	# Get the game version
	var version_string: String = ProjectSettings.get_setting(_VERSION_KEY)
	var version: PackedStringArray = version_string.split(".")

	# Update the version labels
	for i: int in range(version.size()):
		version_labels[i].text = version[i]
