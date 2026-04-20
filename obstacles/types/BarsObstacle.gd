class_name BarsObstacle
extends Obstacle

func build(tunnel_radius: float, params: Dictionary = {}):
	super.build(tunnel_radius, params)
	rotation.z = params.get("gap_start", randf() * TAU)
	var bar_thickness: float = 0.25
	var gap: float = params.get("gap", tunnel_radius * 0.5)
	
	# Верхняя палка
	_build_bar(tunnel_radius, gap * 0.5, bar_thickness)
	# Нижняя палка
	_build_bar(tunnel_radius, -gap * 0.5, bar_thickness)

func _build_bar(tunnel_radius: float, y: float, thickness: float):
	var mesh_instance = MeshInstance3D.new()
	add_child(mesh_instance)
	var box = BoxMesh.new()
	box.size = Vector3(tunnel_radius * 2, tunnel_radius * 0.5, 0.4)
	mesh_instance.mesh = box
	mesh_instance.position.y = y
	mesh_instance.material_override = _make_mat(Color(0.0, 1.0, 0.5))

	var shape = CollisionShape3D.new()
	var bs = BoxShape3D.new()
	bs.size = box.size
	shape.shape = bs
	shape.position.y = y
	area.add_child(shape)
