class_name Obstacle
extends Node3D

signal hit(damage: float)

enum BehaviorMode { STATIC, ROTATING, SLIDING }

@export var damage: float = 20.0

var area: Area3D
var mode: BehaviorMode = BehaviorMode.STATIC
var behavior_speed: float = 1.0
var amplitude: float = 1.0

var _time: float = 0.0
var _start_position: Vector3
var _position_initialized: bool = false

func _ready():
	area = Area3D.new()
	add_child(area)
	area.area_entered.connect(_on_area_entered)

func _process(delta):
	# Берём start_position в первом кадре — после того как спавнер установил transform
	if not _position_initialized:
		_start_position = global_position
		_position_initialized = true
		return

	_time += delta
	match mode:
		BehaviorMode.ROTATING:
			rotation.z += behavior_speed * delta
		BehaviorMode.SLIDING:
			# Двигаем в локальном пространстве по Y
			var offset = sin(_time * behavior_speed) * amplitude
			global_position = _start_position + global_transform.basis.y * offset

func build(tunnel_radius: float, params: Dictionary = {}):
	mode = params.get("mode", BehaviorMode.STATIC)
	behavior_speed = params.get("speed", 1.0)
	amplitude = params.get("amplitude", tunnel_radius * 0.5)

func _on_area_entered(other: Area3D):
	if other.get_parent().is_in_group("player"):
		hit.emit(-1)
		

func _make_mat(color: Color) -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 1.5
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return mat
