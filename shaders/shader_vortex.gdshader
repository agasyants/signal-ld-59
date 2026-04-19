shader_type spatial;
render_mode cull_front, unshaded;

void fragment() {
	vec2 centered_uv = UV * 2.0 - 1.0;
	float angle = atan(centered_uv.y, centered_uv.x);
	float dist = length(centered_uv);
	
	float spiral = sin(angle * 5.0 + dist * 10.0 - TIME * 5.0);
	vec3 color = mix(vec3(0.1, 0.0, 0.2), vec3(0.5, 0.0, 1.0), spiral * 0.5 + 0.5);
	
	ALBEDO = color / (dist + 0.1);
	ALPHA = 1.0 - dist;
}
