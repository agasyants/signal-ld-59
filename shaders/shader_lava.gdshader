shader_type spatial;
render_mode cull_front;

uniform vec3 lava_color : source_color = vec3(1.0, 0.3, 0.0);
uniform vec3 rock_color : source_color = vec3(0.05, 0.05, 0.05);

float noise(vec2 p) {
	return fract(sin(dot(p, vec2(12.7, 7.3))) * 43758.5);
}

void fragment() {
	vec2 uv = UV * 10.0;
	float n = noise(floor(uv) + floor(TIME));
	float flow = sin(UV.y * 20.0 - TIME * 5.0 + UV.x * 5.0);
	
	float mask = step(0.5, sin(uv.x) * cos(uv.y + TIME));
	vec3 final_color = mix(rock_color, lava_color, mask);
	
	ALBEDO = final_color;
	EMISSION = lava_color * mask * (2.0 + sin(TIME * 3.0));
}
