class_name VortexObstacle
extends Obstacle

var gap_size: float = PI * 0.5
var sides: int = 16
var _gap_start: float = 0.0

func build(tunnel_radius: float, params: Dictionary = {}):
	super.build(tunnel_radius, params)
	gap_size = params.get("gap_size", PI * 0.5)
	_gap_start = params.get("gap_start", randf() * TAU)
	rotation.z = _gap_start  # начальный угол
	_build_mesh(tunnel_radius)
	_build_collider(tunnel_radius)

func _build_mesh(tunnel_radius: float):
	var surface = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var step = TAU / sides
	var inner = tunnel_radius * 0.7
	var thickness = 0.5

	for i in sides:
		var a = step * i
		var b = step * (i + 1)
		# Дырка всегда начинается с угла 0 в локальном пространстве
		# rotation.z ноды поворачивает всё кольцо целиком

		var va_out = Vector3(cos(a) * tunnel_radius, sin(a) * tunnel_radius, 0)
		var vb_out = Vector3(cos(b) * tunnel_radius, sin(b) * tunnel_radius, 0)
		var va_in  = Vector3(cos(a) * inner, sin(a) * inner, 0)
		var vb_in  = Vector3(cos(b) * inner, sin(b) * inner, 0)

		_add_quad(surface, va_out, vb_out, vb_in, va_in, Vector3(0, 0, 1))
		var o = Vector3(0, 0, -thickness)
		_add_quad(surface, va_in + o, vb_in + o, vb_out + o, va_out + o, Vector3(0, 0, -1))
		
		# Внешний торец
		# Внешний торец
		_add_quad(surface,
			vb_out, vb_out + o, va_out + o, va_out,
			Vector3(cos((a+b)*0.5), sin((a+b)*0.5), 0))
		# Внутренний торец  
		_add_quad(surface,
			va_in, va_in + o, vb_in + o, vb_in,
			-Vector3(cos((a+b)*0.5), sin((a+b)*0.5), 0))
	
	for i in sides:
		var a = step * i
		var b = step * (i + 1)
		# Дырка всегда начинается с угла 0 в локальном пространстве
		# rotation.z ноды поворачивает всё кольцо целиком
		if a < gap_size:
			continue
		
		inner = 0

		var va_out = Vector3(cos(a) * tunnel_radius, sin(a) * tunnel_radius, 0)
		var vb_out = Vector3(cos(b) * tunnel_radius, sin(b) * tunnel_radius, 0)
		var va_in  = Vector3(cos(a) * inner, sin(a) * inner, 0)
		var vb_in  = Vector3(cos(b) * inner, sin(b) * inner, 0)

		_add_quad(surface, va_out, vb_out, vb_in, va_in, Vector3(0, 0, 1))
		var o = Vector3(0, 0, -thickness)
		_add_quad(surface, va_in + o, vb_in + o, vb_out + o, va_out + o, Vector3(0, 0, -1))
		
		# Внешний торец
		# Внешний торец
		_add_quad(surface,
			vb_out, vb_out + o, va_out + o, va_out,
			Vector3(cos((a+b)*0.5), sin((a+b)*0.5), 0))
		# Внутренний торец  
		_add_quad(surface,
			va_in, va_in + o, vb_in + o, vb_in,
			-Vector3(cos((a+b)*0.5), sin((a+b)*0.5), 0))

	var mesh_instance = MeshInstance3D.new()
	add_child(mesh_instance)
	mesh_instance.mesh = surface.commit()

	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.875, 0.0, 0.0, 1.0)
	mat.emission_enabled = true
	mat.emission = Color(0.772, 0.0, 0.248, 1.0)
	mat.emission_energy_multiplier = 1.5
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh_instance.material_override = mat
	

func _add_quad(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, normal: Vector3):
	surface.set_normal(normal)
	surface.add_vertex(a); surface.add_vertex(b); surface.add_vertex(c)
	surface.set_normal(normal)
	surface.add_vertex(a); surface.add_vertex(c); surface.add_vertex(d)

func _build_collider(tunnel_radius: float):
	var step = TAU / sides
	var inner = tunnel_radius * 0.6
	for i in sides:
		var a = step * i
		var mid = a + step * 0.5
		var shape = CollisionShape3D.new()
		var box = BoxShape3D.new()
		box.size = Vector3(tunnel_radius - inner, 0.5, 0.1)
		shape.shape = box
		shape.position = Vector3(
			cos(mid) * (inner + (tunnel_radius - inner) * 0.7),
			sin(mid) * (inner + (tunnel_radius - inner) * 0.7),
			-0.25
		)
		shape.rotation.z = mid
		area.add_child(shape)
		
	
	inner = 0
	for i in sides:
		var a = step * i
		if a < gap_size:
			continue
		var mid = a + step * 0.5
		var shape = CollisionShape3D.new()
		var box = BoxShape3D.new()
		box.size = Vector3(tunnel_radius - inner, 0.2, 0.3)
		shape.shape = box
		shape.position = Vector3(
			cos(mid) * (inner + (tunnel_radius - inner) * 0.5),
			sin(mid) * (inner + (tunnel_radius - inner) * 0.5),
			-0.25
		)
		shape.rotation.z = mid
		area.add_child(shape)
