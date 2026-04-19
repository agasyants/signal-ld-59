# tunnel_generator.gd
class_name TunnelGenerator
extends Node3D

@export var segment_length: float = 30.0
@export var curve_strength: float = 0.5
@export var sides: int = 12
@export var bake_interval: float = 3.0

func get_radius_at_t(t: float) -> float:
	# Просто берём из кеша по индексу
	if _baked_radii.is_empty():
		return session["radius"]
	var idx = clamp(int(t * _baked_radii.size()), 0, _baked_radii.size() - 1)
	return _baked_radii[idx]

@export var player_scene: PackedScene
@export var track: TrackData

# Сессионные параметры — задаются через start()
var session := {
	"speed": 25.0,
	"density": 0.4,
	"difficulty": 10000.3,
	"radius": 2.0,
	"allow_wall": true,
	"allow_pillar": true,
	"allow_ring": true,
	"allow_bonuses": true,
	"allow_rotating": true,
	"allow_sliding": false,
}

# Внутренние переменные
var curve: Curve3D
var player: Node3D
var _follow := PathFollow3D.new()
var _rng := RandomNumberGenerator.new()
var _track_player: TrackPlayer
var _baked_points: PackedVector3Array
var _baked_radii: PackedFloat32Array
var _current_speed: float = 15.0

var rng := RandomNumberGenerator.new()

# Вызывается из ObstacleSpawner для синхронизации скорости с треком
func set_speed_from_track(speed: float) -> void:
	_current_speed = speed

func _process(delta: float) -> void:
	_follow.progress += _current_speed * delta
	if player and curve:
		var t := _follow.progress / curve.get_baked_length()
		player.tunnel_radius = get_radius_at_t(t) * 0.8

# Добавить в tunnel_generator.gd (дополнения к существующему коду)

# 1. В начало класса добавить сигнал:
signal track_finished

# 2. Заменить метод start() на generate_from_session():
func generate_from_session(s: Dictionary) -> void:
	session = s
	_current_speed = session["speed"]
	rng.randomize()
	generate()

func _on_track_finished() -> void:
	track_finished.emit()

func get_radius_at_point(world_pos: Vector3) -> float:
	var closest_idx := 0
	var closest_dist := world_pos.distance_squared_to(_baked_points[0])
	for i in range(1, _baked_points.size()):
		var d := world_pos.distance_squared_to(_baked_points[i])
		if d < closest_dist:
			closest_dist = d
			closest_idx = i
	return _baked_radii[closest_idx]

func generate() -> void:
	assert(track != null, "TunnelGenerator: track не назначен")

	# Длина трассы из трека
	var total_length := track.get_total_length(session["speed"]) * 1.5
	var segment_count := ceili(total_length / segment_length) + 2

	# Генерация кривой
	curve = Curve3D.new()
	curve.bake_interval = bake_interval

	var points: Array[Vector3] = []
	var pos := Vector3.ZERO
	var dir := Vector3(0.0, 0.0, -1.0)
	points.append(pos)

	for i in segment_count:
		var bend := Vector3(
			_rng.randf_range(-curve_strength, curve_strength),
			_rng.randf_range(-curve_strength, curve_strength),
			_rng.randf_range(-curve_strength, curve_strength)
		)
		dir = (dir + bend).normalized()
		pos += dir * segment_length
		points.append(pos)

	for i in range(points.size()):
		var p := points[i]
		var in_handle := Vector3.ZERO
		var out_handle := Vector3.ZERO
		if i > 0 and i < points.size() - 1:
			var diff := points[i + 1] - points[i - 1]
			out_handle = diff * 0.25
			in_handle = - out_handle
		elif i == 0:
			out_handle = (points[i + 1] - p) * 0.25
		elif i == points.size() - 1:
			in_handle = (points[i - 1] - p) * 0.25
		curve.add_point(p, in_handle, out_handle)
		

	var path := Path3D.new()
	path.curve = curve
	add_child(path)

	_follow.loop = false
	path.add_child(_follow)
	
	# В generate() — до _cache_radii()
	_sampler = TrackSampler.new()
	_sampler.setup(track, session)

	_cache_radii()
	_build_mesh()
	_build_wireframe(_baked_points)

	# Игрок
	if player_scene:
		player = player_scene.instantiate()
		_follow.add_child(player)

	# TrackPlayer + спавнер
	_track_player = TrackPlayer.new()
	_track_player.setup(track, session)
	add_child(_track_player)

	var spawner := ObstacleSpawner.new()
	add_child(spawner)
	spawner.setup(curve, player, self , _track_player)
	
	await get_tree().process_frame
	_track_player.start()
	_track_player.track_finished.connect(_on_track_finished)

# tunnel_generator.gd — добавить переменную
var _sampler: TrackSampler

func _cache_radii() -> void:
	_baked_points = curve.get_baked_points()
	_baked_radii.resize(_baked_points.size())
	var total := float(_baked_points.size())
	var baked_len := curve.get_baked_length()
	
	for i in _baked_points.size():
		# Переводим позицию точки в время через скорость
		var dist := (float(i) / total) * baked_len
		var time := dist / _current_speed
		var params := _sampler.sample(time)
		_baked_radii[i] = params["radius_min"]

func _build_mesh() -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)

	var last_right := Vector3.RIGHT
	var last_up := Vector3.UP

	for i in _baked_points.size():
		var point := _baked_points[i]
		var current_radius := _baked_radii[i]
		var forward: Vector3
		if i < _baked_points.size() - 1:
			forward = (_baked_points[i + 1] - point).normalized()
		else:
			forward = (point - _baked_points[i - 1]).normalized()

		if i == 0:
			# Initial frame
			if abs(forward.dot(Vector3.UP)) > 0.99:
				last_right = forward.cross(Vector3.RIGHT).normalized()
			else:
				last_right = forward.cross(Vector3.UP).normalized()
			last_up = last_right.cross(forward).normalized()
		else:
			# Parallel transport: keep the frame as consistent as possible
			last_right = last_up.cross(forward).normalized()
			last_up = forward.cross(last_right).normalized()

		var right := last_right
		var up := last_up

		for s in sides:
			var angle := TAU * s / sides
			var dir_to_wall := right * cos(angle) - up * sin(angle)
			var uv := Vector2(float(s) / sides, float(i) / float(_baked_points.size() - 1))
			surface.set_uv(uv)
			surface.set_normal(dir_to_wall.normalized())
			surface.add_vertex(point + dir_to_wall * current_radius)

	for i in _baked_points.size() - 1:
		for s in sides:
			var a := i * sides + s
			var b := i * sides + (s + 1) % sides
			var c := (i + 1) * sides + s
			var d := (i + 1) * sides + (s + 1) % sides
			surface.add_index(a); surface.add_index(b); surface.add_index(c)
			surface.add_index(b); surface.add_index(d); surface.add_index(c)

	var mesh_instance := MeshInstance3D.new()
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
		"res://shaders/shader_gold.gdshader"
	]

	var shader = load(tunnel_shaders[rng.randi_range(0, tunnel_shaders.size() - 1)])
	var mat = ShaderMaterial.new()
	mat.shader = shader
	mesh_instance.material_override = mat

func _build_wireframe(baked: PackedVector3Array) -> void:
	var wire_surface := SurfaceTool.new()
	wire_surface.begin(Mesh.PRIMITIVE_LINES)

	var frames_right: Array[Vector3] = []
	var frames_up: Array[Vector3] = []
	frames_right.resize(baked.size())
	frames_up.resize(baked.size())

	var last_right := Vector3.RIGHT
	var last_up := Vector3.UP

	for i in baked.size():
		var point := baked[i]
		var forward: Vector3
		if i < baked.size() - 1:
			forward = (baked[i + 1] - point).normalized()
		else:
			forward = (point - baked[i - 1]).normalized()

		if i == 0:
			if abs(forward.dot(Vector3.UP)) > 0.99:
				last_right = forward.cross(Vector3.RIGHT).normalized()
			else:
				last_right = forward.cross(Vector3.UP).normalized()
			last_up = last_right.cross(forward).normalized()
		else:
			last_right = last_up.cross(forward).normalized()
			last_up = forward.cross(last_right).normalized()
		
		frames_right[i] = last_right
		frames_up[i] = last_up

		var current_radius := _baked_radii[i]
		var right := last_right
		var up := last_up

		for s in sides:
			var angle_a := float(s) / sides
			var angle_b := float(s + 1) / sides
			var va := point + (right * cos(angle_a * TAU) + up * sin(angle_a * TAU)) * current_radius
			var vb := point + (right * cos(angle_b * TAU) + up * sin(angle_b * TAU)) * current_radius
			var v_coord := float(i) / (baked.size() - 1)
			wire_surface.set_uv(Vector2(angle_a, v_coord))
			wire_surface.add_vertex(va)
			wire_surface.set_uv(Vector2(angle_b, v_coord))
			wire_surface.add_vertex(vb)

	for i in baked.size() - 1:
		var p1 := baked[i]
		var p2 := baked[i + 1]
		var r1 := _baked_radii[i]
		var r2 := _baked_radii[i + 1]
		var right1 := frames_right[i]
		var up1 := frames_up[i]
		var right2 := frames_right[i + 1]
		var up2 := frames_up[i + 1]

		for s in sides:
			var angle := TAU * s / sides
			var va := p1 + (right1 * cos(angle) + up1 * sin(angle)) * r1
			var vb := p2 + (right2 * cos(angle) + up2 * sin(angle)) * r2
			wire_surface.add_vertex(va)
			wire_surface.add_vertex(vb)

	var wire_instance := MeshInstance3D.new()
	add_child(wire_instance)
	wire_instance.mesh = wire_surface.commit()

	var wire_tunnel_shaders = [
		"res://shaders/wire.gdshader",
		"res://shaders/wire2.gdshader",
		"res://shaders/wire_cyber.gdshader",
		"res://shaders/wire_rainbow.gdshader",
		"res://shaders/wire_scan.gdshader",
		"res://shaders/wire_dots.gdshader",
		"res://shaders/wire_stream.gdshader"
	]

	var shader = load(wire_tunnel_shaders[rng.randi_range(0, wire_tunnel_shaders.size() - 1)])
	var wire_mat = ShaderMaterial.new()
	wire_mat.shader = shader
	wire_instance.material_override = wire_mat
