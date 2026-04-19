shader_type spatial;
render_mode unshaded, blend_add;

uniform vec3 holo_color : source_color = vec3(0.4, 0.7, 1.0);

float hash(float n) { return fract(sin(n) * 43758.5453123); }

void fragment() {
	float flicker = step(0.1, hash(floor(TIME * 20.0)));
	float noise = hash(UV.y * 100.0 + TIME);
	
	ALBEDO = holo_color;
	ALPHA = flicker * (0.5 + noise * 0.5);
}
