class_name WallObstacle
extends Obstacle

func build(tunnel_radius: float, params: Dictionary = {}):
	super.build(tunnel_radius, params)
	# gap_start — начальный угол поворота, не трогаем rotation в _process
	var gap_start: float = params.get("gap_start", randf() * TAU)
	rotation.z = gap_start  # начальный угол
	_build_mesh(tunnel_radius)
	_build_collider(tunnel_radius)

func _build_mesh(tunnel_radius: float):
	var mesh_instance = MeshInstance3D.new()
	add_child(mesh_instance)
	var box = BoxMesh.new()
	box.size = Vector3(tunnel_radius * 2, tunnel_radius, 0.5)
	mesh_instance.mesh = box
	# Меш смещён — закрывает нижнюю половину в локальном пространстве
	# rotation.z ноды поворачивает всё вместе
	mesh_instance.position.y = -tunnel_radius * 0.5
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.2, 0.1)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.1, 0.0)
	mat.emission_energy_multiplier = 1.5
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh_instance.material_override = mat

func _build_collider(tunnel_radius: float):
	var shape = CollisionShape3D.new()
	var box = BoxShape3D.new()
	box.size = Vector3(tunnel_radius * 2, tunnel_radius, 0.5)
	shape.shape = box
	shape.position.y = -tunnel_radius * 0.5
	area.add_child(shape)
