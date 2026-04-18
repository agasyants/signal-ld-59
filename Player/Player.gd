extends Node3D

@export var rotate_speed: float = 3.5
@export var tunnel_radius: float = 1.7
@export var smoothing: float = 8.0
@export var inertia_friction: float = 5.0  # трение при отсутствии ввода
@export var inertia_strength: float = 8.0  # сила инерции от ввода

@export var health: int = 3

var angular_velocity: float = 0.0
var current_angle: float = 0.0

var body: StaticBody3D

func _ready():
	add_to_group("player")
	
	var area = Area3D.new()
	add_child(area)
	
	var shape = CollisionShape3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = 0.3
	shape.shape = sphere
	area.add_child(shape)

func _process(delta):
	var input = Input.get_axis("ui_left", "ui_right")
	
	if input != 0:
		angular_velocity += input * rotate_speed * inertia_strength * delta
	else:
		angular_velocity = lerp(angular_velocity, 0.0, inertia_friction * delta)
	
	var max_velocity = rotate_speed * 1.5
	angular_velocity = clamp(angular_velocity, -max_velocity, max_velocity)
	
	current_angle += angular_velocity * delta
	
	position.x = cos(current_angle) * tunnel_radius
	position.y = sin(current_angle) * tunnel_radius
	
	var to_center = Vector2(cos(current_angle), sin(current_angle))
	rotation.z = atan2(to_center.y, to_center.x) + PI / 2.0

func change_health(delta: int):
	health += delta
	if health <= 0:
		print('end')
