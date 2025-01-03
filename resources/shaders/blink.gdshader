/****************************************************************************
MIT License

Copyright (c) 2024 Juan Medina

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
****************************************************************************/
shader_type canvas_item;

uniform float blink_frequency : hint_range(0.1, 5.0) = 5.0;
uniform vec4 blink_color : source_color = vec4(1.0, 0.0, 0.0, 1);

void fragment() {
    vec4 texture_color = texture(TEXTURE, UV);
    float alpha = mod(TIME * blink_frequency, 1.0);

    if (alpha < 0.5) {
        COLOR = vec4(mix(texture_color.rgb, blink_color.rgb, blink_color.a), texture_color.a);
    } else {
        COLOR = texture_color;
    }
}
