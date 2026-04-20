class_name PendulumObstacle
extends Obstacle

var _swing_speed: float = 2.0
var _swing_amplitude: float = PI * 0.6
var _time_offset: float = 0.0

func build(tunnel_radius: float, params: Dictionary = {}):
	# Не вызываем super.build с mode — маятник всегда своя логика
	damage = params.get("damage", 20.0)
	_swing_speed = params.get("speed", randf_range(1.0, 2.5))
	_swing_amplitude = params.get("amplitude", PI * 0.6)
	_time_offset = randf() * TAU

	var mesh_instance = MeshInstance3D.new()
	add_child(mesh_instance)
	var box = BoxMesh.new()
	box.size = Vector3(tunnel_radius * 2, tunnel_radius*0.8, 0.4)
	mesh_instance.mesh = box
	mesh_instance.material_override = _make_mat(Color(0.8, 1.0, 0.0))

	var shape = CollisionShape3D.new()
	var bs = BoxShape3D.new()
	bs.size = box.size
	shape.shape = bs
	area.add_child(shape)

func _process(delta):
	_time += delta
	rotation.z = sin(_time * _swing_speed + _time_offset) * _swing_amplitude
