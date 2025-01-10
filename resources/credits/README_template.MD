# Shoot 'em up in Godot
[![License: MIT](https://img.shields.io/badge/License-MIT-478CBF.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![Conduct](https://img.shields.io/badge/Conduct-Covenat%202.0-478CBF.svg?style=for-the-badge)](https://www.contributor-covenant.org/version/2/0/code_of_conduct/)
[![Made with Godot](https://img.shields.io/badge/GODOT-4.3-478CBF?style=for-the-badge&logo=godot%20engine&logoColor=white)](https://godotengine.org)
[![GitHub Release](https://img.shields.io/github/v/release/juan-medina/godot-shootem-up.svg?style=for-the-badge&color=478CBF&label=Last%20game%20release)](https://github.com/juan-medina/godot-shootem-up/releases/latest)
[![Itch.io](https://img.shields.io/badge/itch.io-478CBF.svg?style=for-the-badge&logo=itch.io&logoColor=white)](https://juanmedina.itch.io/godot-shoot-em-up)

<p align="center">
	<img src="media/game_small.jpg" alt="Game Screenshot">
</p>

This is just an example of creating a Shoot 'em up in Godot.

You can download the latest release [here](https://github.com/juan-medina/godot-shootem-up/releases/latest) or on [itch.io](https://juanmedina.itch.io/godot-shoot-em-up).

If you need to open a bug or enhancement, please do it [here](https://github.com/juan-medina/godot-shootem-up/issues/new/choose).

## Features

%%FEATURES%%

## Credits

%%CREDITS%%

## CI
This project includes an Godot [addon](addons/ci_tools/) that deliver several functionalities:

### Build Version: Increase And Launch Main Scene

This will read the game version from the [project.godot](project.godot) file, increase the build version, and then launch the main scene. It default bind to ***CTRL+F5***.

### Update Credits & Features

This will read the [credits.json](resources/credits/credits.json) and [features.json](resources/credits/features.json) and then using to:

 - Update the [README.md](README.md) file with the content of the template [README_template.MD](resources/credits/README_template.MD).
 - Update the [about.bbcode](resources/credits/about.bbcode) file with the content of the [about_template.bbcode](resources/credits/about_template.bbcode) file, this is use in the about menu in the game.
- Update the [itchio.html](resources/credits/itchio.html) file with the content of the [itchio_template.html](resources/credits/itchio_template.html) file, this is use in the itch.io page.

In this way, you can update the credits and features in one place and then update all the files that use it.

### Create Release (Github & itch.io)

This will read the game version from the [project.godot](project.godot) file, and then push a new release to github include the details of the [release_notes.md](release_notes.md) file, this tool requires [Github CLI](https://cli.github.com/) to be installed.

On Github a Windows, Linux, and MacOS builds will be attached to the release and a then release then in itch.io via [this action](.github/workflows/release.yaml)

## LICENSE
```
 Copyright (c) 2024 Juan Antonio Medina Iglesias

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
```
