class_name VortexObstacle
extends Obstacle

var _rings: Array[Node3D] = []
var _speeds: Array[float] = []

func build(tunnel_radius: float, params: Dictionary = {}):
	damage = params.get("damage", 20.0)
	var ring_count: int = 3
	var speeds = [1.5, -1.0, 2.0]  # разные скорости и направления

	for i in ring_count:
		var ring = Node3D.new()
		add_child(ring)
		_rings.append(ring)
		_speeds.append(speeds[i])

		var gap_start = randf() * TAU
		var gap_size = PI * randf_range(0.35, 0.5)
		var r = tunnel_radius * lerp(0.5, 1.0, float(i) / (ring_count - 1))
		ring.rotation.z = gap_start
		_build_ring_mesh(ring, r, gap_size, tunnel_radius)
		_build_ring_collider(ring, r, gap_size, tunnel_radius)

func _process(delta):
	for i in _rings.size():
		_rings[i].rotation.z += _speeds[i] * delta

func _build_ring_mesh(parent: Node3D, radius: float, gap_size: float, tunnel_radius: float):
	var surface = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var sides = 24
	var step = TAU / sides
	var inner = radius * 0.75
	var thickness = 0.3

	for i in sides:
		var a = step * i
		var b = step * (i + 1)
		if a < gap_size:
			continue
		var va_out = Vector3(cos(a) * radius, sin(a) * radius, 0)
		var vb_out = Vector3(cos(b) * radius, sin(b) * radius, 0)
		var va_in  = Vector3(cos(a) * inner, sin(a) * inner, 0)
		var vb_in  = Vector3(cos(b) * inner, sin(b) * inner, 0)
		var o = Vector3(0, 0, -thickness)
		_add_quad(surface, va_out, vb_out, vb_in, va_in, Vector3(0, 0, 1))
		_add_quad(surface, va_in + o, vb_in + o, vb_out + o, va_out + o, Vector3(0, 0, -1))

	var mesh_instance = MeshInstance3D.new()
	parent.add_child(mesh_instance)
	mesh_instance.mesh = surface.commit()
	mesh_instance.material_override = _make_mat(Color(0.0, 0.6, 1.0))

func _build_ring_collider(parent: Node3D, radius: float, gap_size: float, tunnel_radius: float):
	var sides = 24
	var step = TAU / sides
	var inner = radius * 0.75
	for i in sides:
		var a = step * i
		if a < gap_size:
			continue
		var mid = a + step * 0.5
		var shape = CollisionShape3D.new()
		var bs = BoxShape3D.new()
		bs.size = Vector3(radius - inner, 0.3, 0.3)
		shape.shape = bs
		shape.position = Vector3(
			cos(mid) * (inner + (radius - inner) * 0.5),
			sin(mid) * (inner + (radius - inner) * 0.5),
			-0.15)
		shape.rotation.z = mid
		area.add_child(shape)

func _add_quad(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, normal: Vector3):
	surface.set_normal(normal)
	surface.add_vertex(a); surface.add_vertex(b); surface.add_vertex(c)
	surface.set_normal(normal)
	surface.add_vertex(a); surface.add_vertex(c); surface.add_vertex(d)
