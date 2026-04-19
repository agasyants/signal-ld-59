extends Node3D
class_name TunnelGenerator

@export var segment_count: int = 60
@export var segment_length: float = 30.0
@export var curve_strength: float = 0.8
@export var tunnel_radius: float = 2.0
@export var sides: int = 12
@export var bake_interval: float = 3.0

# 1. Адекватные размеры
@export var radius_min: float = 2.0
@export var radius_max: float = 3.0

# 2. Больше циклов — чаще меняется
@export var noise_cycles: float = 2.0

# 3. Усиливаем контраст — поднимаем шум в степень перед remap
func get_radius_at_t(t: float) -> float:
	var wave = sin(t * noise_cycles * TAU) * 0.6 \
			 + sin(t * noise_cycles * 2.3 * TAU) * 0.4
	var n = clamp((wave + 1.0) * 0.5, 0.0, 1.0)
	return lerp(radius_min, radius_max, n)

@export var player_scene: PackedScene

var player: Player

var curve: Curve3D
var mesh_instance: MeshInstance3D
var rng: RandomNumberGenerator
var follow := PathFollow3D.new()
var noise = FastNoiseLite.new()

# Кешируем запечённые точки и радиусы, чтобы не пересчитывать
var _baked_points: PackedVector3Array
var _baked_radii: PackedFloat32Array

func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()
	generate()

@export var speed: float = 15.0
@export var fastspeed: float = 30.0

func _process(delta):
	if Input.is_key_pressed(KEY_SHIFT):
		follow.progress += fastspeed * delta
	else:
		follow.progress += speed * delta
	player.tunnel_radius = get_radius_at_t(follow.progress / curve.get_baked_length())

# Получить радиус по мировой позиции (для спавнера и других внешних систем).
# Находим ближайшую запечённую точку и берём её радиус из кеша.
func get_radius_at_point(world_pos: Vector3) -> float:
	if _baked_points.is_empty():
		return radius_min
	var closest_idx = 0
	var closest_dist = world_pos.distance_squared_to(_baked_points[0])
	for i in range(1, _baked_points.size()):
		var d = world_pos.distance_squared_to(_baked_points[i])
		if d < closest_dist:
			closest_dist = d
			closest_idx = i
	return _baked_radii[closest_idx]

func generate():
	curve = Curve3D.new()
	curve.bake_interval = bake_interval

	var points = []
	var pos = Vector3.ZERO
	var dir = Vector3(0, 0, -1)
	points.append(pos)

	for i in segment_count:
		var bend = Vector3(
			rng.randf_range(-curve_strength, curve_strength),
			rng.randf_range(-curve_strength, curve_strength),
			0
		)
		dir = (dir + bend).normalized()
		pos += dir * segment_length
		points.append(pos)

	for i in range(points.size()):
		var p = points[i]
		var in_handle = Vector3.ZERO
		var out_handle = Vector3.ZERO
		if i > 0 and i < points.size() - 1:
			var diff = points[i + 1] - points[i - 1]
			out_handle = diff * 0.25
			in_handle = - out_handle
		elif i == 0:
			out_handle = (points[i + 1] - p) * 0.25
		elif i == points.size() - 1:
			in_handle = (points[i - 1] - p) * 0.25
		curve.add_point(p, in_handle, out_handle)

	var path = Path3D.new()
	path.curve = curve
	add_child(path)

	#follow.rotation_mode = PathFollow3D.ROTATION_ORIENTED
	follow.loop = false
	path.add_child(follow)

	_cache_radii()
	_build_mesh()
	_build_wireframe(_baked_points)

	if player_scene:
		player = player_scene.instantiate()
		follow.add_child(player)

		var spawner = ObstacleSpawner.new()
		add_child(spawner)
		spawner.setup(curve, player, self )

# Считаем радиус для каждой запечённой точки один раз при генерации
func _cache_radii():
	_baked_points = curve.get_baked_points()
	_baked_radii.resize(_baked_points.size())
	var total = float(_baked_points.size())
	
	print("Baked points: ", _baked_points.size()) # должно быть > 100
	
	var min_r = 9999.0
	var max_r = 0.0
	
	for i in _baked_points.size():
		var r = get_radius_at_t(float(i) / total)
		_baked_radii[i] = r
		min_r = min(min_r, r)
		max_r = max(max_r, r)
	
	print("Radius range: ", min_r, " → ", max_r) # если одно число — шум не работает

func _build_mesh():
	var surface = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)

	for i in _baked_points.size():
		var point = _baked_points[i]
		var current_radius = _baked_radii[i]
		var forward: Vector3
		if i < _baked_points.size() - 1:
			forward = (_baked_points[i + 1] - point).normalized()
		else:
			forward = (point - _baked_points[i - 1]).normalized()

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

			# ВАЖНО: Устанавливаем UV
			# x - по кругу (от 0 до 1)
			# y - по длине туннеля (от 0 до 1)
			var uv = Vector2(float(s) / sides, float(i) / float(_baked_points.size() - 1))
			surface.set_uv(uv)

			var vertex = point + direction_to_wall * current_radius
			# 3. НОРМАЛЬ: инвертируем направление, чтобы она смотрела ВНУТРЬ тоннеля
			# Именно по этому вектору шейдер будет "выдавливать" иголки
			var normal = direction_to_wall.normalized()
			surface.set_normal(normal)
			surface.add_vertex(vertex)

	for i in _baked_points.size() - 1:
		for s in sides:
			var a = i * sides + s
			var b = i * sides + (s + 1) % sides
			var c = (i + 1) * sides + s
			var d = (i + 1) * sides + (s + 1) % sides
			surface.add_index(a); surface.add_index(b); surface.add_index(c)
			surface.add_index(b); surface.add_index(d); surface.add_index(c)

	mesh_instance = MeshInstance3D.new()
	add_child(mesh_instance)
	mesh_instance.mesh = surface.commit()

	var tunnel_shaders = [
		"res://shaders/tunnel.gdshader", 
		"res://shaders/tunnel2.gdshader",
		"res://shaders/shader_matrix.gdshader",
		"res://shaders/shader_lava.gdshader",
		"res://shaders/shader_glitch.gdshader",
		"res://shaders/shader_neon.gdshader",
		"res://shaders/shader_ice.gdshader",
		"res://shaders/shader_toxic.gdshader",
		"res://shaders/shader_stars.gdshader",
		"res://shaders/shader_vortex.gdshader",
		"res://shaders/shader_gold.gdshader"
	]

	var shader = load(tunnel_shaders[rng.randi_range(0, tunnel_shaders.size() - 1)])
	var mat = ShaderMaterial.new()
	mat.shader = shader
	mesh_instance.material_override = mat

func _build_wireframe(baked: PackedVector3Array):
	var wire_surface = SurfaceTool.new()
	wire_surface.begin(Mesh.PRIMITIVE_LINES)

	for i in baked.size():
		var point = baked[i]
		var current_radius = _baked_radii[i] # берём из кеша
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
			var angle_a = float(s) / sides
			var angle_b = float(s + 1) / sides
			
			var va = point + (right * cos(angle_a * TAU) + up * sin(angle_a * TAU)) * current_radius
			var vb = point + (right * cos(angle_b * TAU) + up * sin(angle_b * TAU)) * current_radius

			# Прогресс вдоль пути (V-координата)
			var v_coord = float(i) / (baked.size() - 1)

			# Вершина A
			wire_surface.set_uv(Vector2(angle_a, v_coord))
			wire_surface.add_vertex(va)
			
			# Вершина B
			wire_surface.set_uv(Vector2(angle_b, v_coord))
			wire_surface.add_vertex(vb)

		if i < baked.size() - 1:
			var next_point = baked[i + 1]
			var next_radius = _baked_radii[i + 1]
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

			for s in sides:
				var angle = TAU * s / sides
				var va = point + (right * cos(angle) + up * sin(angle)) * current_radius
				var vb = next_point + (nright * cos(angle) + nup * sin(angle)) * next_radius
				wire_surface.add_vertex(va)
				wire_surface.add_vertex(vb)

	var wire_instance = MeshInstance3D.new()
	add_child(wire_instance)
	wire_instance.mesh = wire_surface.commit()

	var wire_tunnel_shaders = [
		"res://shaders/wire.gdshader", 
		"res://shaders/wire2.gdshader",
		"res://shaders/wire_cyber.gdshader",
		"res://shaders/wire_rainbow.gdshader",
		"res://shaders/wire_scan.gdshader",
		"res://shaders/wire_dots.gdshader",
		"res://shaders/wire_holo.gdshader",
		"res://shaders/wire_stream.gdshader"
	]

	var shader = load(wire_tunnel_shaders[rng.randi_range(0, wire_tunnel_shaders.size() - 1)])
	var wire_mat = ShaderMaterial.new()
	wire_mat.shader = shader
	wire_instance.material_override = wire_mat
