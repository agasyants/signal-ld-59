extends Node3D

@export var segment_count: int = 20
@export var segment_length: float = 30.0
@export var curve_strength: float = 0.3
@export var tunnel_radius: float = 2.0
@export var tunnel_seed: int = 42
@export var sides: int = 12
@export var bake_interval: float = 4.0

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
	
var spawner: ObstacleSpawner

func generate():
	# ... (очистка как у тебя)
	curve = Curve3D.new()
	curve.bake_interval = bake_interval

	var points = []
	var pos = Vector3.ZERO
	var dir = Vector3(0, 0, -1)
	points.append(pos)

	# Шаг 1: Генерируем только позиции (скелет пути)
	for i in segment_count:
		var bend = Vector3(
			rng.randf_range(-curve_strength, curve_strength),
			rng.randf_range(-curve_strength, curve_strength),
			0
		)
		dir = (dir + bend).normalized() # bend без 0.1, т.к. сгладим позже
		pos += dir * segment_length
		points.append(pos)

	# Шаг 2: Расставляем точки в Curve3D с плавными касательными
	for i in range(points.size()):
		var p = points[i]
		var in_handle = Vector3.ZERO
		var out_handle = Vector3.ZERO

		if i > 0 and i < points.size() - 1:
			# Главный секрет плавности: касательная параллельна вектору между соседями
			var diff = points[i + 1] - points[i - 1]
			# 0.35 — коэффициент "мягкости". 
			# Чем меньше, тем более "натянутая" кривая. 0.5 — очень свободная.
			out_handle = diff * 0.25
			in_handle = - out_handle
		elif i == 0:
			# Для первой точки смотрим только вперед
			out_handle = (points[i + 1] - p) * 0.25
		elif i == points.size() - 1:
			# Для последней — только назад
			in_handle = (points[i - 1] - p) * 0.25

		curve.add_point(p, in_handle, out_handle)

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
		
		spawner = ObstacleSpawner.new()
		spawner.tunnel_radius = tunnel_radius
		add_child(spawner)
		spawner.setup(curve, player)

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
			# 1. Вычисляем направление от центра к данной вершине в сечении
			var direction_to_wall = (right * cos(angle) + up * sin(angle))
			# 2. Позиция вершины (центр + направление * радиус)
			var vertex = point + direction_to_wall * tunnel_radius
			# 3. НОРМАЛЬ: инвертируем направление, чтобы она смотрела ВНУТРЬ тоннеля
			# Именно по этому вектору шейдер будет "выдавливать" иголки
			var normal = - direction_to_wall.normalized()
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

	var shader = load("res://shaders/tunnel.gdshader")
	var mat = ShaderMaterial.new()
	mat.shader = shader
	mesh_instance.material_override = mat
	
	# Wireframe поверх
	var wire_instance = MeshInstance3D.new()
	add_child(wire_instance)
	wire_instance.mesh = mesh_instance.mesh # тот же меш
	
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
			
			for s in range(0, sides, 4): # каждое 4-е ребро продольно
				var angle = TAU * s / sides
				var va = point + (right * cos(angle) + up * sin(angle)) * tunnel_radius
				var vb = next_point + (nright * cos(angle) + nup * sin(angle)) * tunnel_radius
				wire_surface.add_vertex(va)
				wire_surface.add_vertex(vb)
	
	var wire_instance = MeshInstance3D.new()
	add_child(wire_instance)
	wire_instance.mesh = wire_surface.commit()
	
	var wire_mat = StandardMaterial3D.new()
	wire_mat.albedo_color = Color(0.0, 0.8, 0.957, 1.0)
	wire_instance.material_override = wire_mat
