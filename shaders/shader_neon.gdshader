shader_type spatial;
render_mode cull_front, unshaded;

uniform vec3 neon_color : source_color = vec3(1.0, 0.0, 0.8);
uniform float speed = 4.0;

void fragment() {
	float grid = sin(UV.x * 40.0) * sin(UV.y * 100.0 - TIME * speed);
	grid = pow(abs(grid), 10.0);
	
	float pulse = sin(TIME * 2.0) * 0.5 + 0.5;
	
	ALBEDO = neon_color * grid * (1.0 + pulse * 2.0);
	ALPHA = clamp(grid * 2.0, 0.0, 1.0);
}
