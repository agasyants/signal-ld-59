extends Node3D

@export var tunnel_radius: float = 3.0
@export var sides: int = 24
@export var segment_length: float = 100.0
@export var speed: float = 20.0

var tunnel1: MeshInstance3D
var tunnel2: MeshInstance3D
var wire1: MeshInstance3D
var wire2: MeshInstance3D

func _ready():
	var mesh = _build_tunnel_mesh()
	var wire_mesh = _build_wireframe_mesh()
	
	var mat = ShaderMaterial.new()
	mat.shader = load("res://shaders/tunnel2.gdshader")
	
	var wire_mat = ShaderMaterial.new()
	wire_mat.shader = load("res://shaders/wire_cyber.gdshader")
	
	tunnel1 = MeshInstance3D.new()
	tunnel1.mesh = mesh
	tunnel1.material_override = mat
	add_child(tunnel1)
	
	tunnel2 = MeshInstance3D.new()
	tunnel2.mesh = mesh
	tunnel2.material_override = mat
	tunnel2.position.z = -segment_length
	add_child(tunnel2)

	wire1 = MeshInstance3D.new()
	wire1.mesh = wire_mesh
	wire1.material_override = wire_mat
	add_child(wire1)
	
	wire2 = MeshInstance3D.new()
	wire2.mesh = wire_mesh
	wire2.material_override = wire_mat
	wire2.position.z = -segment_length
	add_child(wire2)

func _process(delta):
	tunnel1.position.z += speed * delta
	tunnel2.position.z += speed * delta
	wire1.position.z += speed * delta
	wire2.position.z += speed * delta
	
	if tunnel1.position.z > segment_length:
		tunnel1.position.z -= segment_length * 2
		wire1.position.z -= segment_length * 2
	if tunnel2.position.z > segment_length:
		tunnel2.position.z -= segment_length * 2
		wire2.position.z -= segment_length * 2

func _build_tunnel_mesh() -> Mesh:
	var surface = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var rings = 20
	for i in range(rings + 1):
		var z = -float(i) / rings * segment_length
		var v = float(i) / rings
		for s in range(sides + 1):
			var u = float(s) / sides
			var angle = u * TAU
			var pos = Vector3(cos(angle) * tunnel_radius, sin(angle) * tunnel_radius, z)
			surface.set_uv(Vector2(u, v))
			surface.set_normal(Vector3(-cos(angle), -sin(angle), 0))
			surface.add_vertex(pos)
			
	for i in range(rings):
		for s in range(sides):
			var a = i * (sides + 1) + s
			var b = i * (sides + 1) + s + 1
			var c = (i + 1) * (sides + 1) + s
			var d = (i + 1) * (sides + 1) + s + 1
			surface.add_index(a); surface.add_index(b); surface.add_index(c)
			surface.add_index(b); surface.add_index(d); surface.add_index(c)
			
	return surface.commit()

func _build_wireframe_mesh() -> Mesh:
	var surface = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_LINES)
	
	var rings = 20
	for i in range(rings + 1):
		var z = -float(i) / rings * segment_length
		for s in range(sides):
			var a1 = float(s) / sides * TAU
			var a2 = float(s + 1) / sides * TAU
			
			var p1 = Vector3(cos(a1) * tunnel_radius, sin(a1) * tunnel_radius, z)
			var p2 = Vector3(cos(a2) * tunnel_radius, sin(a2) * tunnel_radius, z)
			
			surface.set_uv(Vector2(float(s)/sides, float(i)/rings))
			surface.add_vertex(p1)
			surface.set_uv(Vector2(float(s+1)/sides, float(i)/rings))
			surface.add_vertex(p2)
			
			if i < rings:
				var z_next = -float(i + 1) / rings * segment_length
				var p3 = Vector3(cos(a1) * tunnel_radius, sin(a1) * tunnel_radius, z_next)
				surface.set_uv(Vector2(float(s)/sides, float(i)/rings))
				surface.add_vertex(p1)
				surface.set_uv(Vector2(float(s)/sides, float(i+1)/rings))
				surface.add_vertex(p3)
				
	return surface.commit()
