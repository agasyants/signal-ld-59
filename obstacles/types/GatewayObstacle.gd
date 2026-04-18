class_name GatewayObstacle
extends Obstacle

func build(tunnel_radius: float, params: Dictionary = {}):
	super.build(tunnel_radius, params)
	var gap_width: float = params.get("gap_width", tunnel_radius * 0.6)
	var gap_offset: float = params.get("gap_offset", randf_range(-tunnel_radius * 0.3, tunnel_radius * 0.3))
	rotation.z = params.get("gap_start", randf() * TAU)
	_build_side(tunnel_radius, gap_offset, gap_width, true)
	_build_side(tunnel_radius, gap_offset, gap_width, false)

func _build_side(tunnel_radius: float, gap_offset: float, gap_width: float, left: bool):
	var _sign = -1.0 if left else 1.0
	var stilt_width = tunnel_radius - abs(gap_offset) - gap_width * 0.5
	if stilt_width <= 0:
		return
	var x = _sign * (abs(gap_offset) + gap_width * 0.5 + stilt_width * 0.5)

	var mesh_instance = MeshInstance3D.new()
	add_child(mesh_instance)
	var box = BoxMesh.new()
	box.size = Vector3(stilt_width, tunnel_radius * 2, 0.5)
	mesh_instance.mesh = box
	mesh_instance.position.x = x
	mesh_instance.material_override = _make_mat(Color(0.0, 1.0, 0.4))

	var shape = CollisionShape3D.new()
	var bs = BoxShape3D.new()
	bs.size = box.size
	shape.shape = bs
	shape.position.x = x
	area.add_child(shape)
