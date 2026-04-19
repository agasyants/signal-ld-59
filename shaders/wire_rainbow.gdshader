shader_type spatial;
render_mode unshaded, blend_add;

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
	float hue = fract(UV.y * 2.0 + TIME * 0.5);
	ALBEDO = hsv2rgb(vec3(hue, 0.8, 1.0));
}
