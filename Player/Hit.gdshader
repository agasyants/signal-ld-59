shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float shake_intensity : hint_range(0.0, 0.1) = 0.0;
uniform float glitch_intensity : hint_range(0.0, 1.0) = 0.0;

// Функция для генерации псевдослучайного шума
float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // Эффект тряски: смещаем UV на основе случайного значения и интенсивности
    float shake_x = (random(vec2(TIME, 0.0)) - 0.5) * shake_intensity;
    float shake_y = (random(vec2(0.0, TIME)) - 0.5) * shake_intensity;
    vec2 offset = vec2(shake_x, shake_y);
    
    // Эффект глитча (смещение каналов)
    float r = texture(SCREEN_TEXTURE, uv + offset + vec2(glitch_intensity * 0.02, 0.0)).r;
    float g = texture(SCREEN_TEXTURE, uv + offset).g;
    float b = texture(SCREEN_TEXTURE, uv + offset - vec2(glitch_intensity * 0.02, 0.0)).b;
    
    // Добавляем полосы (сканлайны) для ретро-вайба
    float scanline = sin(uv.y * 800.0 + TIME * 10.0) * 0.05 * glitch_intensity;
    
    COLOR = vec4(r + scanline, g + scanline, b + scanline, 1.0);
}