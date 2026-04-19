shader_type spatial;
render_mode cull_front;

uniform vec3 gold_color : source_color = vec3(1.0, 0.8, 0.2);

void fragment() {
	float pattern = step(0.8, sin(UV.x * 20.0) * cos(UV.y * 20.0));
	ALBEDO = gold_color * (0.5 + pattern * 0.5);
	METALLIC = 0.9;
	ROUGHNESS = 0.2;
	EMISSION = gold_color * pattern * 2.0;
}
