extends Node3D

@export var speed: float = 15.0
@export var rotate_speed: float = 5.0  # скорость вращения вокруг оси
@export var tunnel_radius: float = 1.7
@export var smoothing: float = 8.0

var target_angle: float = 0.0
var current_angle: float = 0.0

func _process(delta):
	var input = Input.get_axis("ui_left", "ui_right")
	target_angle += input * rotate_speed * delta
	
	current_angle = lerp_angle(current_angle, target_angle, smoothing * delta)
	
	position.x = cos(current_angle) * tunnel_radius
	position.y = sin(current_angle) * tunnel_radius
	
	var to_center = Vector2(cos(current_angle), sin(current_angle))
	rotation.z = atan2(to_center.y, to_center.x) + PI / 2.0
