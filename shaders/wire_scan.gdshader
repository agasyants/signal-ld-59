shader_type spatial;
render_mode unshaded, blend_add;

uniform vec3 base_color : source_color = vec3(0.0, 0.5, 1.0);
uniform vec3 scan_color : source_color = vec3(1.0, 1.0, 1.0);

void fragment() {
	float wave = sin(UV.y * 50.0 - TIME * 10.0);
	float mask = pow(clamp(wave, 0.0, 1.0), 10.0);
	
	ALBEDO = mix(base_color * 0.3, scan_color, mask);
}
