# bonus.gd
class_name Bonus
extends Node3D

signal collected(type: String)

enum BonusType { HEALTH, SHIELD, SLOW }

@export var type: BonusType = BonusType.HEALTH

var _area: Area3D

func _ready() -> void:
	_area = Area3D.new()
	add_child(_area)
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 0.5
	shape.shape = sphere
	_area.add_child(shape)
	_area.area_entered.connect(_on_area_entered)

func build(bonus_type: BonusType) -> void:
	type = bonus_type
	# TODO: построить меш и визуал под тип

func _on_area_entered(other: Area3D) -> void:
	if other.get_parent().is_in_group("player"):
		collected.emit(BonusType.keys()[type])
		queue_free()
