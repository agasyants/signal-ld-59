shader_type spatial;
render_mode wireframe, cull_disabled;

uniform float speed = 1.0;      // Скорость шевеления иголок
uniform float strength = 10.3;   // Максимальная длина иголок
uniform float frequency = 10.0; // Плотность «хаоса»
uniform vec3 color = vec3(1, 1, 1);

void vertex() {
    // Создаем псевдослучайное смещение для каждой вершины.
    // Используем синус от координат, чтобы у каждой точки была своя фаза.
    float noise = sin(VERTEX.x * frequency + TIME * speed) 
                * cos(VERTEX.y * frequency + TIME * speed * 0.5) 
                * sin(VERTEX.z * frequency + TIME * speed * 1.2);
    
    // Превращаем диапазон синуса [-1, 1] в [0, 1], чтобы иголки не уходили внутрь объекта
    float spike = (noise + 1.0) * 0.5;

    // Смещаем вершину строго по направлению её нормали
    VERTEX += NORMAL * spike * strength;
}

void fragment() {
    ALBEDO = color;
    ROUGHNESS = 0.2;
}