extends Node3D

@export var segment_count: int = 20
@export var segment_length: float = 10.0
@export var curve_strength: float = 3.0
@export var tunnel_radius: float = 3.0
@export var tunnel_seed: int = 42
@export var sides: int = 24
@export var bake_interval: float = 0.5  # чем меньше, тем плавнее

var curve: Curve3D
var mesh_instance: MeshInstance3D
var rng: RandomNumberGenerator
@export var player_scene: PackedScene
var follow := PathFollow3D.new()


@export var speed: float = 15.0
func _process(delta):
	follow.progress += speed * delta

func _ready():
	rng = RandomNumberGenerator.new()
	rng.seed = tunnel_seed
	generate()

func generate():
	# Чистим старое
	for child in get_children():
		child.queue_free()
	await get_tree().process_frame

	# Строим кривую
	curve = Curve3D.new()
	curve.bake_interval = bake_interval

	var pos = Vector3.ZERO
	var dir = Vector3(0, 0, -1)
	curve.add_point(pos)

	for i in segment_count:
		var bend = Vector3(
			rng.randf_range(-curve_strength, curve_strength),
			rng.randf_range(-curve_strength, curve_strength),
			0
		)
		dir = (dir + bend * 0.1).normalized()
		pos += dir * segment_length
		var tangent = dir * segment_length * 0.5
		curve.add_point(pos, -tangent, tangent)

	# Path3D создаём и добавляем в дерево
	var path = Path3D.new()
	path.curve = curve
	add_child(path)

	# PathFollow3D — после того как Path3D в дереве
	follow.rotation_mode = PathFollow3D.ROTATION_ORIENTED
	follow.loop = false
	path.add_child(follow)

	_build_mesh()

	# Игрок — в самом конце
	if player_scene:
		var player = player_scene.instantiate()
		follow.add_child(player)

func _build_mesh():
	var baked = curve.get_baked_points()

	var surface = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)

	for i in baked.size():
		var point = baked[i]
		var forward: Vector3
		if i < baked.size() - 1:
			forward = (baked[i + 1] - point).normalized()
		else:
			forward = (point - baked[i - 1]).normalized()

		var up = Vector3.UP
		if abs(forward.dot(up)) > 0.99:
			up = Vector3.RIGHT
		var right = forward.cross(up).normalized()
		up = right.cross(forward).normalized()

		for s in sides:
			var angle = TAU * s / sides
			var vertex = point + (right * cos(angle) + up * sin(angle)) * tunnel_radius
			# Нормаль смотрит внутрь — от стенки к центру
			var normal = (right * cos(angle) + up * sin(angle))
			surface.set_normal(normal)
			surface.add_vertex(vertex)

	for i in baked.size() - 1:
		for s in sides:
			var a = i * sides + s
			var b = i * sides + (s + 1) % sides
			var c = (i + 1) * sides + s
			var d = (i + 1) * sides + (s + 1) % sides
			# Было: a c b / b c d
			# Стало: порядок обратный — нормали внутрь
			surface.add_index(a); surface.add_index(b); surface.add_index(c)
			surface.add_index(b); surface.add_index(d); surface.add_index(c)

	# Не вызываем generate_normals() — мы задали их вручную
	mesh_instance = MeshInstance3D.new()
	add_child(mesh_instance)
	mesh_instance.mesh = surface.commit()

	var mat = StandardMaterial3D.new()
	mat.cull_mode = BaseMaterial3D.CULL_FRONT
	mat.albedo_color = Color(0.0, 0.8, 1.0)
	mat.emission_enabled = true
	mat.emission = Color(0.0, 0.5, 1.0)
	mat.emission_energy_multiplier = 2.0
	mesh_instance.material_override = mat
	
	# Wireframe поверх
	var wire_instance = MeshInstance3D.new()
	add_child(wire_instance)
	wire_instance.mesh = mesh_instance.mesh  # тот же меш
	
	_build_wireframe(baked)


func _build_wireframe(baked: Array):
	var wire_surface = SurfaceTool.new()
	wire_surface.begin(Mesh.PRIMITIVE_LINES)
	
	for i in baked.size():
		var point = baked[i]
		var forward: Vector3
		if i < baked.size() - 1:
			forward = (baked[i + 1] - point).normalized()
		else:
			forward = (point - baked[i - 1]).normalized()
		
		var up = Vector3.UP
		if abs(forward.dot(up)) > 0.99:
			up = Vector3.RIGHT
		var right = forward.cross(up).normalized()
		up = right.cross(forward).normalized()
		
		# Кольцо рёбер
		for s in sides:
			var angle_a = TAU * s / sides
			var angle_b = TAU * ((s + 1) % sides) / sides
			var va = point + (right * cos(angle_a) + up * sin(angle_a)) * tunnel_radius
			var vb = point + (right * cos(angle_b) + up * sin(angle_b)) * tunnel_radius
			wire_surface.add_vertex(va)
			wire_surface.add_vertex(vb)
		
		# Продольные рёбра — только каждые N колец чтобы не перегружать
		if i < baked.size() - 1:
			var next_point = baked[i + 1]
			var next_forward: Vector3
			if i + 1 < baked.size() - 1:
				next_forward = (baked[i + 2] - next_point).normalized()
			else:
				next_forward = forward
			
			var nup = Vector3.UP
			if abs(next_forward.dot(nup)) > 0.99:
				nup = Vector3.RIGHT
			var nright = next_forward.cross(nup).normalized()
			nup = nright.cross(next_forward).normalized()
			
			for s in range(0, sides, 4):  # каждое 4-е ребро продольно
				var angle = TAU * s / sides
				var va = point + (right * cos(angle) + up * sin(angle)) * tunnel_radius
				var vb = next_point + (nright * cos(angle) + nup * sin(angle)) * tunnel_radius
				wire_surface.add_vertex(va)
				wire_surface.add_vertex(vb)
	
	var wire_instance = MeshInstance3D.new()
	add_child(wire_instance)
	wire_instance.mesh = wire_surface.commit()
	
	var wire_mat = StandardMaterial3D.new()
	wire_mat.albedo_color = Color(0.0, 1.0, 0.8)
	wire_mat.emission_enabled = true
	wire_mat.emission = Color(0.0, 1.0, 0.8)
	wire_mat.emission_energy_multiplier = 2.0
	wire_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	wire_instance.material_override = wire_mat
