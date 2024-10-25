shader_type canvas_item;

uniform sampler2D palette_texture; // La texture 1x256 avec la palette
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float themix : hint_range(0.0, 1.0, 0.01) = 1.0;

float color_distance(vec3 color1, vec3 color2) {
    vec3 diff = color1 - color2;
    return dot(diff, diff);  // Squared distance (no need for sqrt)
}

void fragment() {
    // Récupérer la couleur actuelle du pixel
	vec4 color = texture(screen_texture, SCREEN_UV);

    // Initialize minimum distance and color match
    float min_dist = 9999.0;
    vec3 closest_color = color.rgb;

    // Iterate through the palette
    for (int i = 0; i < 256; i++) {
        // Get color from palette texture
        vec3 palette_color = texelFetch(palette_texture, ivec2(i, 0), 0).rgb;

        // Calculate the distance to the current palette color
        float dist = color_distance(color.rgb, palette_color);

        // Update if this palette color is closer
        if (dist < min_dist) {
            min_dist = dist;
            closest_color = palette_color;
        }
    }

    // Appliquer la couleur de la palette au fragment
    COLOR.rgb = closest_color.rgb * themix + color.rgb * (1.0 - themix);
	COLOR.a = color.a;
}
