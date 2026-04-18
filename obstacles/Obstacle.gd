class_name Obstacle
extends Node3D

signal hit(damage: float)

enum BehaviorMode {
	STATIC,
	ROTATING,
	SLIDING
}

@export var damage: float = 20.0

var area: Area3D
var mode: BehaviorMode = BehaviorMode.STATIC
var behavior_speed: float = 1.0
var amplitude: float = 1.0

var _time: float = 0.0
var _start_position: Vector3

func _ready():
	area = Area3D.new()
	add_child(area)
	area.area_entered.connect(_on_area_entered)

func _process(delta):
	_time += delta
	match mode:
		BehaviorMode.ROTATING:
			rotation.z += behavior_speed * delta
		BehaviorMode.SLIDING:
			position = _start_position + Vector3(0, sin(_time * behavior_speed) * amplitude, 0)

func build(tunnel_radius: float, params: Dictionary = {}):
	mode = params.get("mode", BehaviorMode.STATIC)
	behavior_speed = params.get("speed", 1.0)
	amplitude = params.get("amplitude", tunnel_radius * 0.5)
	_start_position = position  # запоминаем после того как transform установлен спавнером

func _on_area_entered(other: Area3D):
	if other.get_parent().is_in_group("player"):
		hit.emit(damage)
		on_hit(other.get_parent())

func on_hit(_body: Node3D):
	pass
