shader_type spatial;
render_mode cull_front, unshaded;

uniform vec3 base_color : source_color = vec3(0.05, 0.05, 0.6); // Фон туннеля
uniform vec3 wave_color_1 : source_color = vec3(0.0, 0.8, 0.95);
uniform vec3 wave_color_2 : source_color = vec3(1.0, 0.23, 0.23);

uniform float speed_1 = 2.0;
uniform float density = 30.0;
uniform float ring_width = 0.1;

void fragment() {
    // 1. Кольцевые волны (поперек туннеля)
    float w1 = cos(UV.y * density - TIME * speed_1);
    float mask1 = smoothstep(1.0 - ring_width, 1.0, w1);
    
    // 2. Продольные линии (вдоль туннеля)
    // Используем UV.x. sides в коде Godot должны соответствовать этой плотности
    float w2 = cos(UV.x * 12.0); // Фиксированные полосы вдоль
    float mask2 = smoothstep(1.0 - ring_width, 1.0, w2);
    
    // 3. Быстрая "вспышка" или вторая волна
    float w3 = cos(UV.y * (density * 0.5) - TIME * 2.0);
    float mask3 = smoothstep(1.0 - ring_width * 0.5, 1.0, w3);

    // Комбинируем маски. Используем max(), чтобы они не складывались в белый цвет,
    // а просто накладывались друг на друга.
    float final_mask = max(mask1, mask3);
    
    // Смешиваем цвета: сначала базовый, потом волны, потом продольные линии другим цветом
    vec3 color = mix(base_color, wave_color_1, final_mask);
    color = mix(color, wave_color_2, mask2 * 0.5); // Добавляем продольные линии чуть тусклее

    ALBEDO = color;
    EMISSION = color * 2.0;
}