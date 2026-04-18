shader_type spatial;
render_mode cull_front; 

uniform vec3 color_top : source_color = vec3(0.0, 0.2, 0.0);
uniform vec3 color_bottom : source_color = vec3(0.0, 0.0, 0.5);
uniform float exponent = 1.5;

void fragment() {
    // Градиент привязан к плоскости экрана
    float gradient_factor = clamp(SCREEN_UV.y, 0.0, 1.0);
    
    if (exponent != 1.0) {
        gradient_factor = pow(gradient_factor, exponent);
    }

    vec3 grad_color = mix(color_top, color_bottom, gradient_factor);
    
    // Назначаем цвет в ALBEDO. 
    // Поскольку unshaded нет, Godot сам добавит свет и тени поверх этого цвета.
    ALBEDO = grad_color;
    
    // Настройки материала для лучшего взаимодействия со светом
    ROUGHNESS = 1.0; // Небольшой блеск
    SPECULAR = .8;  // Отражения
	METALLIC = 0.5;
}