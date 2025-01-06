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

- Player spaceship with movement and shooting.
- Different enemy spaceships.
- CRT effect for retro look.
- Menu with options including:
	- Borderless fullscreen or windowed mode.
	- Music and sound effects volume.
	- CRT effect configuration.
- Game over window.
- Pause and resume game.
- Score and shield bar.
- Sound effects and music.

## Resources

- Game music: [Abstraction - Music Loop Bundle](https://tallbeard.itch.io/music-loop-bundle) by [Abstraction](https://abstractionmusic.com).
	- Menu: Box Jump.
	- Level: Out of Time.
- Background: [Glacial Mountains: Parallax Background](https://vnitti.itch.io/glacial-mountains-parallax-background) by [vnitti](https://vnitti.itch.io/).
- Spaceships: [Free Enemy Spaceship 2D Sprites Pixel Art](https://free-game-assets.itch.io/free-enemy-spaceship-2d-sprites-pixel-art) by [Craftpix](https://craftpix.net/)
- Shield Bar: [UI BARS](https://guilemus.itch.io/ui-bars) by [guilemus](https://guilemus.itch.io/).
- Player shot fire sound: [laser.wav](https://freesound.org/people/Shaun105/sounds/268168) by [Shaun105](https://freesound.org/people/Shaun105/).
- Player shot hit sound: [Hit/Hurt](https://freesound.org/people/Prof.Mudkip/sounds/398957/) by [Prof.Mudkip](https://freesound.org/people/Prof.Mudkip/).
- Ship explosion sound: [8-Bit explosion](https://freesound.org/people/Prof.Mudkip/sounds/386862/) by [Prof.Mudkip](https://freesound.org/people/Prof.Mudkip/).
- Game Over sound: [8-bit Game Over](https://freesound.org/people/Euphrosyyn/sounds/442127/) by [Euphrosyyn](https://freesound.org/people/Euphrosyyn/).
- Button press sound: [8-bit 2022 Poke Bright Select Button BBM](https://freesound.org/people/NovaSoundTechnology/sounds/653049/) by [NovaSoundTechnology](https://freesound.org/people/NovaSoundTechnology/).
- Font: [Pixeloid](https://www.fontspace.com/pixeloid-font-f69232) by [GGBotNet](https://www.fontspace.com/ggbotnet)
- CRT effect: [Godot CRT Shader](https://perons.itch.io/godot-crt-shader) by [Perons](https://perons.itch.io/).

## CI
To trigger a new release I use this powershell [script](create-release.ps1).

```powershell
.\create-release.ps1
```

This will read the game version from the [project.godot](project.godot) file, requires [Github CLI](https://cli.github.com/), and then push a new release to github and itch.io.

This will trigger a github [action](.github/workflows/release.yaml) that will add to the release a zip package with the game.

Additionally this project includes an Godot [addon](addons/build_version/) that will launch the main scene and increase the build number.

You can use this either via the tool menu: ***Build Version: Increase And Launch Main Scene*** or the shortcut ***CTRL+F5***.

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
