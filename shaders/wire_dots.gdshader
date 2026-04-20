shader_type spatial;
render_mode unshaded;

uniform vec3 dot_color : source_color = vec3(1.0, 1.0, 0.0);

void fragment() {
	float dots = step(0.2, sin(UV.y * 200.0 - TIME * 5.0));
	ALBEDO = dot_color;
	ALPHA = dots;
}
