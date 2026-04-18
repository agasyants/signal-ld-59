shader_type spatial;
render_mode cull_front, blend_mix, depth_draw_always;

uniform vec3 color_top : source_color = vec3(0.0, 0.02, 0.0);
uniform vec3 color_bottom : source_color = vec3(0.0, 0.02, 0.05); 

uniform float exponent = 1.5;
uniform float wave_speed : hint_range(0.0, 10.0) = 2.0;
uniform float wave_frequency : hint_range(0.0, 10.0) = 3.0; // Плотность волн

void fragment() {
    float wave = cos(UV.y * wave_frequency - TIME * wave_speed);

    float gradient_factor = clamp(SCREEN_UV.y, 0.0, 1.0);
    ALBEDO = mix(color_top, color_bottom, pow(gradient_factor, exponent));

    ROUGHNESS = 0.6;
    METALLIC = 0.8;
}