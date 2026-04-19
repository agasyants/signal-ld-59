shader_type spatial;
render_mode cull_front, unshaded;

uniform vec3 base_color : source_color = vec3(0.1, 0.5, 1.0);
uniform float glitch_intensity = 0.05;

float hash(float n) { return fract(sin(n) * 43758.5453123); }

void fragment() {
	float g = hash(floor(TIME * 15.0));
	vec2 uv = UV;
	
	if (hash(floor(uv.y * 50.0) + floor(TIME * 20.0)) < glitch_intensity) {
		uv.x += (hash(TIME) - 0.5) * 0.2;
		ALBEDO = vec3(1.0, 0.0, 0.0);
	} else {
		float stripes = step(0.8, sin(uv.y * 100.0));
		ALBEDO = base_color * (0.5 + stripes * 0.5);
	}
	
	ALPHA = 0.8;
}
