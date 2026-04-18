class_name LaserGridObstacle
extends Obstacle

func build(tunnel_radius: float, params: Dictionary = {}):
	super.build(tunnel_radius, params)
	var h_count: int = params.get("h_count", randi_range(2, 3))
	var v_count: int = params.get("v_count", randi_range(2, 3))
	var thickness: float = 0.08

	# Горизонтальные
	for i in h_count:
		var y = lerp(-tunnel_radius * 0.8, tunnel_radius * 0.8, float(i) / (h_count - 1) if h_count > 1 else 0.5)
		_build_bar(tunnel_radius, Vector3(tunnel_radius * 2, thickness, 0.3), Vector3(0, y, 0))

	# Вертикальные
	for i in v_count:
		var x = lerp(-tunnel_radius * 0.8, tunnel_radius * 0.8, float(i) / (v_count - 1) if v_count > 1 else 0.5)
		_build_bar(tunnel_radius, Vector3(thickness, tunnel_radius * 2, 0.3), Vector3(x, 0, 0))

func _build_bar(tunnel_radius: float, size: Vector3, pos: Vector3):
	var mesh_instance = MeshInstance3D.new()
	add_child(mesh_instance)
	var box = BoxMesh.new()
	box.size = size
	mesh_instance.mesh = box
	mesh_instance.position = pos
	mesh_instance.material_override = _make_mat(Color(1.0, 0.0, 0.8))

	var shape = CollisionShape3D.new()
	var bs = BoxShape3D.new()
	bs.size = size
	shape.shape = bs
	shape.position = pos
	area.add_child(shape)
