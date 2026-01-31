shader_type canvas_item;

// Alpha slider: 0 = fully transparent, 1 = fully opaque
uniform float alpha_percent : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    // Get the original texture color
    vec4 color = texture(TEXTURE, UV);

    // Apply the slider to the alpha channel
    color.a *= alpha_percent;

    COLOR = color;
}
