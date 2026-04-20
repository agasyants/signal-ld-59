shader_type spatial;
render_mode cull_front, unshaded;

uniform vec3 stream_color : source_color = vec3(0.0, 1.0, 0.2);
uniform float speed = 0.1;
uniform float density = 20.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 uv = UV * vec2(density, 1.0);
	float column_id = floor(uv.x);
	float offset = hash(vec2(column_id, 0.0)) * 10.0;
	float trail = fract(uv.y * 2.0 - TIME * speed + offset);
	
	float brightness = step(0.9, trail) * 1.5;
	brightness += pow(trail, 8.0);
	
	ALBEDO = stream_color * brightness;
	ALPHA = mix(0.98, 1.0, clamp(brightness, 0.0, 1.0));
}
