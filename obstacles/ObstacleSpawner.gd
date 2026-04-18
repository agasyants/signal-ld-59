class_name ObstacleSpawner
extends Node3D

@export var spawn_interval: float = 20.0
@export var tunnel_radius: float = 2.5

var curve: Curve3D
var player: Node3D

func setup(c: Curve3D, p: Node3D):
	curve = c
	player = p
	_spawn_all()

func _on_obstacle_hit():
	player.change_health(-1)

func _spawn_all():
	var length = curve.get_baked_length()
	var progress = spawn_interval

	while progress < length - spawn_interval:
		_spawn_wall(progress)
		progress += spawn_interval + randf_range(-3.0, 3.0)

func _spawn_wall(progress: float):
	var t: Transform3D = curve.sample_baked_with_rotation(progress, true)
	
	var wall = WallObstacle.new()
	add_child(wall)
	wall.global_transform = t
	wall.hit.connect(_on_obstacle_hit)
	wall.build(tunnel_radius, {
		"gap_start": randf() * TAU,
		"gap_size": PI  # половина открыта
	})
