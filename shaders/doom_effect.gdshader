shader_type canvas_item;

uniform float timer = 0.0;
uniform float[64] y_offsets;
uniform sampler2D melt_tex;
uniform bool melting = false;

// Force this color for the background
uniform vec4 melt_color : source_color = vec4(0.0, 0.0, 0.0, 1.0); 

void fragment() {
    vec2 tex_uv = UV;
    
    if (melting) {
        float index = tex_uv.x * float(y_offsets.length());
        
        // Move the pixels down
        tex_uv.y -= timer * y_offsets[int(index)];
        
        // If the pixel has moved off the bottom (or is from "above" the screen)
        // we draw BLACK instead of the texture
        if (tex_uv.y < 0.0 || tex_uv.y > 1.0) {
            COLOR = melt_color;
        } else {
            COLOR = texture(melt_tex, tex_uv);
        }
    } else {
        COLOR = texture(melt_tex, tex_uv);
    }
}