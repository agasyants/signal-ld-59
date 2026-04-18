shader_type ;
render_mode cull_front, blend_mix, depth_draw_always;

uniform vec3 emission_color : source_color = vec3(1.0, 0.5, 0.0); // Цвет свечения
uniform float emission_energy : hint_range(0.0, 10.0) = 2.0;    // Яркость

void fragment() {
    // Расчет волны (из предыдущего шага)
    float wave = cos(UV.y * 5.0 - TIME * 2.0);
    float glow_mask = clamp(wave + 0.2, 0.0, 1.0);
    
    // ALBEDO делаем темным
    ALBEDO = vec3(0.05, 0.05, 0.1); 
    
    // EMISSION будет гореть только на гребнях волны
    EMISSION = emission_color * emission_energy * glow_mask;
    
    // Можно также сделать так, чтобы светящиеся части были менее прозрачными
    ALPHA = mix(0.2, 1.0, glow_mask);
}