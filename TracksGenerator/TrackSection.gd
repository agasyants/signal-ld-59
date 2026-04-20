# track_section.gd
class_name TrackSection
extends Resource

# Временная метка в секундах
@export var time: float = 0.0

# Коэффициенты 0..1 — min/max для интерполяции внутри секции
# Итоговое значение = session_value * коэффициент
@export_group("Speed")
@export var speed_curve: Vector2 = Vector2(0.2, 0.2)

@export_group("Density")
@export var density_curve: Vector2 = Vector2(1.0, 1.0)

@export_group("Difficulty")
@export var difficulty_curve: Vector2 = Vector2(0.2, 0.4)

@export_group("Radius")
# Коэффициент масштабирования session.radius
# radius_min = session.radius * (k - spread), radius_max = session.radius * (k + spread)
@export var radius_curve: Vector2 = Vector2(1.0, 1.0)

@export_group("Obstacle Types")
# Битовые флаги — пересекаются с глобальными разрешениями сессии
@export_flags("Wall", "Pillar", "Ring", "Gateway", "Switch", "Spinner", "Spikes", "Bars", "LaserGrid", "Pendulum", "Vortex") var obstacle_types: int = 2047

@export_group("Bonus Types")
@export_flags("Health", "Shield", "Slow") var bonus_types: int = 7

@export_group("Behavior")
@export var allow_rotating: bool = true
@export var allow_sliding: bool = true
