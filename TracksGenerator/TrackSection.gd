# track_section.gd
class_name TrackSection
extends Resource

# Временная метка в секундах
@export var time: float = 0.0

# Коэффициенты 0..1 — min/max для интерполяции внутри секции
# Итоговое значение = session_value * коэффициент
@export_group("Speed")
@export var speed_curve: Vector2 = Vector2(0.8, 1.2)

@export_group("Density")
@export var density_curve: Vector2 = Vector2(0.4, 0.6)

@export_group("Difficulty")
@export var difficulty_curve: Vector2 = Vector2(0.2, 0.4)

@export_group("Radius")
# Коэффициент масштабирования session.radius
# radius_min = session.radius * (k - spread), radius_max = session.radius * (k + spread)
@export var radius_curve: Vector2 = Vector2(0.7, 1.3)

@export_group("Obstacle Types")
# Битовые флаги — пересекаются с глобальными разрешениями сессии
@export_flags("Wall", "Pillar", "Ring") var obstacle_types: int = 7

@export_group("Bonus Types")
@export_flags("Health", "Shield", "Slow") var bonus_types: int = 0

@export_group("Behavior")
@export var allow_rotating: bool = true
@export var allow_sliding: bool = false
