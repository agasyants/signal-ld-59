shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_opaque;

uniform vec3 neon_color : source_color = vec3(1.0, 0.08, 0.45);
uniform vec3 neon_secondary : source_color = vec3(1.0, 0.55, 0.75);
uniform float pulse_speed : hint_range(0.5, 5.0) = 2.8;
uniform float grid_speed : hint_range(0.0, 4.0) = 1.2;
uniform float rim_power : hint_range(1.0, 8.0) = 3.5;

varying vec3 world_normal;
varying vec3 world_pos;

void vertex() {
    world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    vec3 view_dir = normalize(CAMERA_POSITION_WORLD - world_pos);
    float NdotV = max(dot(world_normal, view_dir), 0.0);

    float pulse = 0.5 + 0.5 * sin(TIME * pulse_speed);
    float slow_pulse = 0.5 + 0.5 * sin(TIME * 1.1);

    // --- Tron grid ---
    vec2 uv = UV * 6.0;
    float scroll = TIME * grid_speed;
    vec2 grid_uv = uv + vec2(scroll, scroll);
    vec2 grid = abs(fract(grid_uv) - 0.5);
    float lines = min(grid.x, grid.y);
    float grid_mask = 1.0 - smoothstep(0.02, 0.06, lines);
    vec3 grid_color = neon_color * grid_mask * 0.35;

    // --- dark interior ---
    vec3 base = vec3(0.0, 0.0, 0.02);

    // --- fresnel rim (neon edge) ---
    float rim = pow(1.0 - NdotV, rim_power);
    float rim_bright = pow(1.0 - NdotV, 1.8);
    vec3 rim_color = mix(neon_color, neon_secondary, rim_bright) * (rim * (1.8 + 0.6 * pulse));

    // --- sweep scan line ---
    float angle = atan(world_pos.y - MODEL_MATRIX[3][1],
                       world_pos.x - MODEL_MATRIX[3][0]);
    float sweep = mod(angle + TIME * 2.4, TAU) / TAU;
    float sweep_mask = smoothstep(0.0, 0.12, sweep) * (1.0 - smoothstep(0.12, 0.18, sweep));
    vec3 sweep_color = neon_secondary * sweep_mask * 0.6 * NdotV;

    // --- inner glow ---
    float inner = smoothstep(0.6, 0.0, NdotV);
    vec3 inner_color = neon_color * inner * 0.15;

    // --- compose ---
    vec3 col = base + grid_color + rim_color + sweep_color + inner_color;

    // outer edge hard line
    float edge = smoothstep(0.08, 0.0, NdotV);
    col += neon_secondary * edge * (1.0 + pulse * 0.5);

    ALBEDO = col;
    EMISSION = col;
    ALPHA = clamp(rim + grid_mask * 0.6 + sweep_mask * 0.5 + edge, 0.0, 1.0);
}