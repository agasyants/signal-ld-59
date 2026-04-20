shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float intensity : hint_range(0.0, 5.0) = 2.0;

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 rel_uv = uv - 0.5; // Координаты относительно центра
    
    vec3 color_acc = vec3(0.0);
    float weight_acc = 0.0;
    
    // Количество итераций для "линий". 32 — для высокой четкости.
    const int SAMPLES = 32;
    
    for (int i = 0; i < SAMPLES; i++) {
        float t = float(i) / float(SAMPLES);
        
        // Математика гиперпрыжка: экспоненциальное растяжение
        // Каждая выборка масштабирует UV всё сильнее
        float scale = 1.0 + (t * progress * intensity);
        vec2 sample_uv = rel_uv / scale + 0.5;
        
        // Вес выборки: делаем края прозрачнее, чтобы не было "каши"
        float weight = pow(1.0 - t, 2.0);
        
        // Добавляем эффект "хроматического распада" (разные каналы тянутся по-разному)
        float r = texture(SCREEN_TEXTURE, rel_uv / (scale * 1.05) + 0.5).r;
        float g = texture(SCREEN_TEXTURE, sample_uv).g;
        float b = texture(SCREEN_TEXTURE, rel_uv / (scale * 0.95) + 0.5).b;
        
        color_acc += vec3(r, g, b) * weight;
        weight_acc += weight;
    }
    
    vec3 final_color = color_acc / weight_acc;
    
    // Вспышка: на пике progress изображение уходит в белый через экспозицию
    // Это создаёт эффект "вылета" из света
    float exposure = 1.0 + (progress * 3.0);
    final_color *= exposure;
    
    // Смешивание с чистым белым (на самом старте)
    final_color = mix(final_color, vec3(1.0), pow(progress, 3.0));

    COLOR = vec4(final_color, 1.0);
}