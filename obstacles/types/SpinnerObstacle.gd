class_name SpinnerObstacle
extends Obstacle

func build(tunnel_radius: float, params: Dictionary = {}):
	params["mode"] = BehaviorMode.ROTATING
	params["speed"] = params.get("speed", randf_range(1.0, 3.0))
	super.build(tunnel_radius, params)
	var blade_count: int = params.get("blade_count", 3)
	for i in blade_count:
		_build_blade(tunnel_radius, TAU * i / blade_count)

func _build_blade(tunnel_radius: float, angle: float):
	var mesh_instance = MeshInstance3D.new()
	add_child(mesh_instance)
	var box = BoxMesh.new()
	box.size = Vector3(tunnel_radius * 2, 0.25, 0.4)
	mesh_instance.mesh = box
	mesh_instance.rotation.z = angle
	mesh_instance.material_override = _make_mat(Color(1.0, 0.0, 0.5))

	var shape = CollisionShape3D.new()
	var bs = BoxShape3D.new()
	bs.size = box.size
	shape.shape = bs
	shape.rotation.z = angle
	area.add_child(shape)
