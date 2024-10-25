shader_type canvas_item;

uniform float factor: hint_range(0.0, 1.0, 0.01) = 0.8;

void fragment() {
	vec3 avg = vec3(dot(COLOR.rgb, vec3(0.333)));
	float desaturate = factor;
	float darken = factor * 0.4;
	COLOR.rgb = mix(COLOR.rgb, avg, desaturate) * (1.0 - darken);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
