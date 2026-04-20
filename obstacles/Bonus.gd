class_name Bonus
extends Node3D

signal collected(type: BonusType)

enum BonusType { HEALTH = 1, COIN = 2, SLOW = 4 }

var bonus_type: BonusType = BonusType.HEALTH
var area: Area3D
var _time: float = 0.0
var _collected: bool = false

func _process(delta: float) -> void:
	_time += delta * Engine.time_scale
	rotation.z += delta * Engine.time_scale * 1.5
	position += transform.basis.y * sin(_time * 2.5) * delta * 0.25

func build(type: BonusType) -> void:
	bonus_type = type
	area = Area3D.new()
	add_child(area)
	area.area_entered.connect(_on_area_entered)
	_build_mesh()

const COLORS := {
	BonusType.HEALTH: Color(1.0, 0.15, 0.15),   # насыщенный красный
	BonusType.COIN:   Color(1.0, 0.9, 0.0),      # чистый жёлтый
	BonusType.SLOW:   Color(0.0, 0.85, 1.0),     # циановый
}

func _build_mesh() -> void:
	var color: Color = COLORS[bonus_type]

	var col := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 0.45
	col.shape = shape
	area.add_child(col)

	# Основной меш
	var mesh_inst := MeshInstance3D.new()
	mesh_inst.mesh = _make_mesh()
	mesh_inst.material_override = _make_mat(color, 3.5)
	add_child(mesh_inst)

	# Ореол — увеличенная полупрозрачная копия
	var glow := MeshInstance3D.new()
	glow.mesh = _make_mesh()
	glow.scale = Vector3(1.6, 1.6, 1.6)
	glow.material_override = _make_mat(color, 0.6, 0.25)  # dim + прозрачный
	add_child(glow)

func _make_mat(color: Color, emission_energy: float = 2.0, alpha: float = 1.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(color.r, color.g, color.b, alpha)
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = emission_energy
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	if alpha < 1.0:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return mat

func _make_mesh() -> Mesh:
	match bonus_type:
		BonusType.COIN:
			var m := CylinderMesh.new()
			m.top_radius = 0.22
			m.bottom_radius = 0.22
			m.height = 0.08
			return m
		_:
			var m := SphereMesh.new()
			m.radius = 0.22
			m.height = 0.44
			return m

func _on_area_entered(other: Area3D) -> void:
	if _collected:
		return
	if not other.get_parent().is_in_group("player"):
		return
	_collected = true
	collected.emit(bonus_type)
	queue_free()
