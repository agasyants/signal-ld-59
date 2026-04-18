class_name PillarObstacle
extends Obstacle

func build(tunnel_radius: float, params: Dictionary = {}):
	super.build(tunnel_radius, params)
	_build_mesh(tunnel_radius)
	_build_collider(tunnel_radius)

func _build_mesh(tunnel_radius: float):
	var mesh_instance = MeshInstance3D.new()
	add_child(mesh_instance)
	var box = BoxMesh.new()
	box.size = Vector3(0.4, tunnel_radius * 2, 0.5)
	mesh_instance.mesh = box
	# Смещение только у меша — origin ноды остаётся в центре трубы
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.6, 0.0)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.4, 0.0)
	mat.emission_energy_multiplier = 1.5
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh_instance.material_override = mat

func _build_collider(tunnel_radius: float):
	var shape = CollisionShape3D.new()
	var box = BoxShape3D.new()
	box.size = Vector3(0.4, tunnel_radius * 2, 0.5)
	shape.shape = box
	# Коллайдер тоже смещён как меш
	area.add_child(shape)
