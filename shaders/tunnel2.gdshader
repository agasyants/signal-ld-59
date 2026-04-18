shader_type spatial;
render_mode cull_front, blend_mix, depth_draw_always;

uniform vec3 color_top : source_color = vec3(0.0, 0.4, 0.0);
uniform vec3 color_top_2 : source_color = vec3(0.4, 0.4, 0.0); 
uniform vec3 color_bottom : source_color = vec3(0.0, 0.0, 0.5);
uniform vec3 color_bottom_2 : source_color = vec3(0.5, 0.0, 0.5); 

uniform float exponent = 1.5;
uniform float wave_speed : hint_range(0.0, 10.0) = 2.0;
uniform float wave_frequency : hint_range(0.0, 10.0) = 3.0; // Плотность волн
uniform float min_alpha : hint_range(0.0, 1.0) = 0.2;
uniform float max_alpha : hint_range(0.0, 1.0) = 1.0;

// Смещение, чтобы сделать туннель более "плотным"
uniform float visibility_bias : hint_range(-1.0, 1.0) = 0.8;

void fragment() {
    // 1. Создаем волну прозрачности, зависящую от UV.y (длины туннеля) и времени
    // Вычитание времени заставляет волну бежать "ОТ" камеры (если UV.y растет вглубь)
    float wave = cos(UV.y * wave_frequency - TIME * wave_speed);
    
    // 2. Искажаем волну, чтобы она дольше была в "максимуме" (max_alpha)
    // Добавляем bias и ограничиваем 0..1
    float alpha_wave = clamp(wave + visibility_bias, 0.0, 1.0);
    // float alpha_wave = fract(UV.y - TIME * wave_speed)
    
    // Применяем финальную прозрачность
    ALPHA = mix(min_alpha, max_alpha, alpha_wave);

    // --- Остальная логика цветов ---
    float color_time_sine = (sin(TIME * 0.5) + 1.0) * 0.5;
    vec3 current_top = mix(color_top, color_top_2, color_time_sine);
    vec3 current_bottom = mix(color_bottom, color_bottom_2, color_time_sine);

    float gradient_factor = clamp(SCREEN_UV.y, 0.0, 1.0);
    ALBEDO = mix(current_top, current_bottom, pow(gradient_factor, exponent));

    if (!FRONT_FACING) {
        NORMAL = -NORMAL;
    }
    ROUGHNESS = 0.3;
    METALLIC = 0.5;
}