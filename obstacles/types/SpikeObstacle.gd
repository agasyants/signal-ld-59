class_name SpikeObstacle
extends Obstacle

func build(tunnel_radius: float, params: Dictionary = {}):
	super.build(tunnel_radius, params)
	var spike_count: int = 16
	var gap_count: int = params.get("gap_count", randi_range(2, 3))
	
	# Выбираем случайные индексы для прорех
	var gaps: Array = []
	while gaps.size() < gap_count:
		var idx = randi() % spike_count
		if idx not in gaps:
			gaps.append(idx)
	
	for i in spike_count:
		if i in gaps:
			continue
		var angle = TAU * i / spike_count
		_build_spike(tunnel_radius, angle, TAU / spike_count)

func _build_spike(tunnel_radius: float, angle: float, width: float):
	var length = tunnel_radius * 0.4
	var mesh_instance = MeshInstance3D.new()
	add_child(mesh_instance)
	var box = BoxMesh.new()
	box.size = Vector3(width * tunnel_radius * 0.8, length, 0.4)
	mesh_instance.mesh = box
	mesh_instance.rotation.z = angle
	mesh_instance.position = Vector3(
		cos(angle) * (tunnel_radius - length * 0.5),
		sin(angle) * (tunnel_radius - length * 0.5),
		0)
	mesh_instance.material_override = _make_mat(Color(1.0, 0.3, 0.0))

	var shape = CollisionShape3D.new()
	var bs = BoxShape3D.new()
	bs.size = box.size
	shape.shape = bs
	shape.rotation.z = angle
	shape.position = mesh_instance.position
	area.add_child(shape)
