shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_always;

uniform vec4  base_color    : source_color = vec4(1.0, 0.15, 0.05, 1.0);
uniform float glitch_strength : hint_range(0.0, 1.0) = 0.35;
uniform float scan_speed      : hint_range(0.1, 8.0) = 2.5;
uniform float edge_glow       : hint_range(0.0, 4.0) = 2.0;
uniform float flicker_rate    : hint_range(0.0, 20.0) = 8.0;
uniform float time_offset     : hint_range(0.0, 100.0) = 0.0;

// Простой hash для псевдорандома
float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

float hash2(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
    float t = TIME + time_offset;

    // --- Базовый цвет + UV-искажение от glitch ---
    vec2 uv = UV;

    // Горизонтальные полосы глитча: каждые ~0.1 единицы UV разная фаза
    float strip     = floor(uv.y * 18.0);
    float strip_t   = floor(t * 12.0);
    float glitch_on = step(0.92, hash(strip + strip_t * 0.3));   // ~8% полос активны
    float dx        = (hash(strip + strip_t) - 0.5) * glitch_strength * glitch_on;
    uv.x = fract(uv.x + dx);

    // --- Scanline (вертикальная бегущая линия) ---
    float scan_y    = fract(uv.y - t * scan_speed * 0.15);
    float scanline  = smoothstep(0.02, 0.0, abs(scan_y - 0.0)) * 0.7;
    // Тонкие горизонтальные CRT-полоски
    float crt       = smoothstep(0.3, 0.5, abs(sin(UV.y * 120.0))) * 0.08;

    // --- Мигание всего объекта ---
    float flicker   = step(0.97, hash(floor(t * flicker_rate))) * 0.5;

    // --- Краевое свечение по нормали ---
    // NORMAL.z близок к 0 на рёбрах при unshaded + cull_disabled
    float rim       = 1.0 - abs(dot(NORMAL, VIEW));
    rim = pow(rim, 2.5) * edge_glow;

    // --- Пульсация яркости ---
    float pulse     = 0.85 + 0.15 * sin(t * 3.7 + UV.y * 6.0);

    // --- Собираем цвет ---
    vec3 col = base_color.rgb;

    // Глитч-полосы немного сдвигают цвет в cyan/magenta (хроматическая аберрация)
    col.r += dx * 2.0;
    col.b -= dx * 1.5;

    // Бегущий скан — светлый штрих
    col += vec3(0.8, 0.9, 1.0) * scanline;

    // Rim glow поверх базового
    col += base_color.rgb * rim;

    // CRT затемнение
    col -= crt;

    // Пульс и флик
    col *= pulse * (1.0 - flicker);

    // --- Альфа: прозрачность на рёбрах (опционально) ---
    float alpha = base_color.a * (0.85 + 0.15 * rim) * (1.0 - flicker * 0.8);

    ALBEDO = clamp(col, 0.0, 3.0);   // HDR-пересвет разрешён — unshaded
    ALPHA  = alpha;
    EMISSION = col * 0.6;            // свечение дублируется в emission для bloom
}