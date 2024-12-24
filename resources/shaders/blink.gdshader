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
