shader_type spatial;
render_mode cull_front, blend_mix, depth_draw_always;

uniform vec3 color_top : source_color = vec3(0.012, 0.639, 0.651);
uniform vec3 color_bottom : source_color = vec3(0.016, 0.271, 0.541); 

uniform float exponent = 1.5;

void fragment() {

    float gradient_factor = clamp(SCREEN_UV.y, 0.0, 1.0);
    ALBEDO = mix(color_top, color_bottom, pow(gradient_factor, exponent));

    ROUGHNESS = 0.1;
    METALLIC = 0.4;
}