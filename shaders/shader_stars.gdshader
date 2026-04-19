shader_type spatial;
render_mode cull_front, unshaded;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

void fragment() {
	vec2 uv = UV * 50.0;
	float star = hash(floor(uv));
	float blink = sin(TIME * 2.0 + star * 10.0) * 0.5 + 0.5;
	
	float mask = step(0.98, star);
	ALBEDO = vec3(1.0) * mask * blink;
	ALPHA = mask;
}
