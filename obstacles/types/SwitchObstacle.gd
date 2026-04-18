class_name SwitchObstacle
extends Obstacle

func build(tunnel_radius: float, params: Dictionary = {}):
	super.build(tunnel_radius, params)
	rotation.z = params.get("gap_start", randf() * TAU)
	_build_bar(tunnel_radius, true)   # горизонтальная
	_build_bar(tunnel_radius, false)  # вертикальная

func _build_bar(tunnel_radius: float, horizontal: bool):
	var mesh_instance = MeshInstance3D.new()
	add_child(mesh_instance)
	var box = BoxMesh.new()
	box.size = Vector3(tunnel_radius * 2, 0.3, 0.5) if horizontal else Vector3(0.3, tunnel_radius * 2, 0.5)
	mesh_instance.mesh = box
	mesh_instance.material_override = _make_mat(Color(0.8, 0.0, 1.0))

	var shape = CollisionShape3D.new()
	var bs = BoxShape3D.new()
	bs.size = box.size
	shape.shape = bs
	area.add_child(shape)
