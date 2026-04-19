shader_type spatial;
render_mode unshaded, blend_add;

uniform vec3 stream_color : source_color = vec3(1.0, 0.2, 0.2);

void fragment() {
	float pos = UV.y * 20.0 - TIME * 5.0;
	float stream = pow(max(0.0, sin(pos)), 10.0);
	
	ALBEDO = stream_color * (0.1 + stream * 5.0);
}
