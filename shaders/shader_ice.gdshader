shader_type spatial;
render_mode cull_front;

uniform vec3 ice_color : source_color = vec3(0.7, 0.9, 1.0);

void fragment() {
	float fresnel = pow(1.0 - dot(NORMAL, VIEW), 3.0);
	float crack = sin(UV.x * 50.0 + UV.y * 20.0) * cos(UV.y * 50.0);
	
	ALBEDO = ice_color;
	ALPHA = 0.4 + fresnel * 0.6;
	ROUGHNESS = 0.05;
	METALLIC = 0.1;
	EMISSION = ice_color * step(0.95, crack) * 2.0;
}
