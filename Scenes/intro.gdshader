shader_type spatial;
render_mode cull_disabled;

uniform float speed = 1.0; 
uniform float strength = 0.05; 
uniform float frequency = 10.0;
uniform vec3 color = vec3(0.0, 0.8, 1.0);

// Параметры сетки для WebGL
uniform float line_width : hint_range(0.0, 0.2) = 0.01;
uniform float grid_size = 2.0;

varying vec3 v_local_pos;

void vertex() {
    v_local_pos = VERTEX;
    
    float noise = sin(VERTEX.x * frequency + TIME * speed) 
                * cos(VERTEX.y * frequency + TIME * speed * 0.5) 
                * sin(VERTEX.z * frequency + TIME * speed * 1.2);
    
    float spike = (noise + 1.0) * 0.5;
    VERTEX += NORMAL * spike * strength;
}

void fragment() {
    // Вычисляем сетку на основе локальных координат
    vec3 grid = abs(fract(v_local_pos * grid_size - 0.5) - 0.5) / fwidth(v_local_pos * grid_size);
    float line = min(min(grid.x, grid.y), grid.z);
    
    // Рисуем линии. Если пиксель не на линии — отбрасываем его
    float mask = 1.0 - smoothstep(0.0, 1.0, line - line_width);
    
    if (mask < 0.5) {
        discard;
    }
    
    ALBEDO = color;
    EMISSION = color * 1.5; // Свечение для стиля
}