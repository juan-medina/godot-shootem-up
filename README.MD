# Shoot 'em up

This is just an example of creating a Shoot 'em up in Godot 4.

## Resources

- Game music: [Abstraction - Music Loop Bundle](https://tallbeard.itch.io/music-loop-bundle) by [Abstraction](https://abstractionmusic.com).
- Background: [Glacial Mountains: Parallax Background](https://vnitti.itch.io/glacial-mountains-parallax-background) by [vnitti](https://vnitti.itch.io/).
- Spaceships: [Free Enemy Spaceship 2D Sprites Pixel Art](https://free-game-assets.itch.io/free-enemy-spaceship-2d-sprites-pixel-art) by [Craftpix](https://craftpix.net/)
- Shield Bar: [UI BARS](https://guilemus.itch.io/ui-bars) by [guilemus](https://guilemus.itch.io/).
- Player shot fire sound: [laser.wav](https://freesound.org/people/Shaun105/sounds/268168) by [Shaun105](https://freesound.org/people/Shaun105/).
- Player shot hit sound: [Hit/Hurt](https://freesound.org/people/Prof.Mudkip/sounds/398957/) by [Prof.Mudkip](https://freesound.org/people/Prof.Mudkip/).
- Ship explosion sound: [8-Bit explosion](https://freesound.org/people/Prof.Mudkip/sounds/386862/) by [Prof.Mudkip](https://freesound.org/people/Prof.Mudkip/).

## CI

I use the action https://github.com/felix-schindler/build-godot-action

To trigger a new release using this powershell [script](create-release.ps1).

```powershell
.\create-release.ps1
```

This will read the version from the [project.godot](project.godot) file, requires [Github CLI](https://cli.github.com/).

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
