shader_type sky;

// Цвета для синтвейв-градиента
uniform vec3 top_color : source_color = vec3(0.243, 0.0, 0.329);    // Глубокий фиолетовый/черный
uniform vec3 mid_color : source_color = vec3(0.137, 0.004, 0.231);     // Пурпурный
uniform vec3 bottom_color : source_color = vec3(0.012, 0.239, 0.408);  // Циановый горизонт

uniform float star_density : hint_range(0.01, 1.0) = 0.5;
uniform float star_brightness : hint_range(0.1, 5.0) = 1.2;
uniform float star_speed : hint_range(0.0, 0.2) = 0.02;         // Скорость "дрейфа" звезд
uniform float parallax_strength : hint_range(0.0, 0.5) = 0.01;   // Сила параллакса при вращении

float hash(vec3 p) {
    p  = fract(p * 0.1031);
    p += dot(p, p.zyx + 31.32);
    return fract((p.x + p.y) * p.z);
}

void sky() {
    vec3 dir = EYEDIR;
    
    // --- 1. СИНТВЕЙВ ГРАДИЕНТ ---
    // Используем dir.y (от -1.0 до 1.0), чтобы сделать растяжку
    float h = dir.y;
    vec3 sky_gradient = mix(mid_color, top_color, smoothstep(0.0, 0.8, h));
    sky_gradient = mix(sky_gradient, bottom_color, smoothstep(0.0, -1.0, h));
    
    // --- 2. ЗВЕЗДЫ С ПАРАЛЛАКСОМ И ДВИЖЕНИЕМ ---
    // Добавляем TIME для медленного дрейфа и смещаем координаты на dir для параллакса
    vec3 star_pos = dir + (dir * parallax_strength);
    star_pos.xz += TIME * star_speed; 
    
    vec3 star_grid = floor(star_pos * 200.0 * star_density);
    float star_noise = hash(star_grid);
    vec3 stars = vec3(0.0);
    
    if (star_noise > 0.995) {
        // Делаем мерцание звезд через TIME
        float blink = 0.8 + 0.2 * sin(TIME * 2.0 + star_noise * 100.0);
        float star_intensity = pow(hash(star_grid + 0.5), 10.0) * star_brightness * blink;
        stars = vec3(star_intensity);
    }
    
    // Смешиваем звезды с градиентом
    // Звезды видны в основном в верхней части неба (где темнее)
    float star_mask = smoothstep(-0.2, 0.5, h);
    
    COLOR = sky_gradient + (stars * star_mask);
}