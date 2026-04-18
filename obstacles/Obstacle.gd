class_name Obstacle
extends Node3D

signal hit(damage: float)

@export var damage: float = 20.0

var area: Area3D

func _ready():
	area = Area3D.new()
	add_child(area)
	area.area_entered.connect(_on_area_entered)

func _on_area_entered(other: Area3D):
	if other.get_parent().is_in_group("player"):
		hit.emit()
		on_hit(other.get_parent())

func build(_tunnel_radius: float, _params: Dictionary = {}):
	pass

func on_hit(_body: Node3D):
	pass
