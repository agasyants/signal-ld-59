extends Node3D

@export var lateral_speed: float = 4.0
@export var tunnel_radius: float = 2.5

var lateral_offset: Vector2 = Vector2.ZERO

func _process(delta):
	var input = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)
	lateral_offset += input * lateral_speed * delta
	lateral_offset = lateral_offset.limit_length(tunnel_radius)
	
	# Смещение относительно родителя (PathFollow3D)
	position.x = lateral_offset.x
	position.y = lateral_offset.y
	position.z = 0.0
