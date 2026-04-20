shader_type spatial;
render_mode unshaded, blend_add;

uniform vec3 line_color : source_color = vec3(0.0, 1.0, 1.0);

void fragment() {
	float flow = fract(UV.y * 10.0 - TIME * 0.3);
	float pulse = step(0.5, flow);
	
	ALBEDO = line_color * (0.2 + pulse * 2.0);
}
