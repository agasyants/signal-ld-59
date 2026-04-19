shader_type spatial;
render_mode cull_front;

uniform vec3 vein_color : source_color = vec3(0.2, 0.8, 0.1);
uniform vec3 base_color : source_color = vec3(0.05, 0.1, 0.05);

void fragment() {
	float veins = sin(UV.x * 30.0 + sin(UV.y * 10.0)) * cos(UV.y * 20.0 + TIME);
	veins = smoothstep(0.4, 0.5, veins);
	
	ALBEDO = mix(base_color, vein_color, veins);
	EMISSION = vein_color * veins * (sin(TIME * 4.0) * 0.5 + 0.5);
}
