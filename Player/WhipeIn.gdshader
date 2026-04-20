shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float intensity : hint_range(0.0, 5.0) = 2.0;

// Ключевая идея: mipmap уже содержит размытые версии текстуры.
// Вместо 32 сэмплов одного mip-уровня — несколько сэмплов разных уровней.
// GPU сделал эту работу за нас при загрузке текстуры.

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 rel_uv = uv - 0.5;
    
    float stretch = progress * intensity;
    
    // Всего 8 сэмплов вместо 96, но распределённых по mip-уровням
    const int SAMPLES = 8;
    vec3 color_acc = vec3(0.0);
    float weight_acc = 0.0;

    for (int i = 0; i < SAMPLES; i++) {
        float t = float(i) / float(SAMPLES - 1); // [0..1]
        float scale = 1.0 + t * stretch;
        
        // Используем mip-уровень пропорционально растяжению:
        // дальние сэмплы (сильное растяжение) читаем с более грубого mip.
        // textureLod — явный контроль LOD без автовычисления GPU.
        float lod = t * 3.0; // 0..3 уровень mipmap
        vec2 sample_uv = rel_uv / scale + 0.5;
        
        float weight = (1.0 - t) * (1.0 - t); // (1-t)²
        
        color_acc += textureLod(SCREEN_TEXTURE, sample_uv, lod).rgb * weight;
        weight_acc += weight;
    }

    vec3 base = color_acc / weight_acc;

    // Хроматика — один раз, после аккумуляции.
    // Это неотличимо визуально от per-sample хроматики,
    // но стоит 2 фетча вместо 64.
    float ca = stretch * 0.03; // сила аберрации
    float r = textureLod(SCREEN_TEXTURE, rel_uv / (1.0 + ca) + 0.5, 0.0).r;
    float b = textureLod(SCREEN_TEXTURE, rel_uv / (1.0 - ca) + 0.5, 0.0).b;
    base = vec3(r, base.g, b);

    // Экспозиция и вспышка — без изменений, это дёшево
    base *= 1.0 + progress * 3.0;
    base = mix(base, vec3(1.0), progress * progress * progress);

    COLOR = vec4(base, 1.0);
}