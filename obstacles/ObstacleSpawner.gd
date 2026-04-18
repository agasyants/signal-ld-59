class_name ObstacleSpawner
extends Node3D

@export var spawn_interval: float = 20.0
@export var tunnel_radius: float = 2.5

var curve: Curve3D
var player: Node3D
var rng = RandomNumberGenerator.new()

func setup(c: Curve3D, p: Node3D):
	curve = c
	player = p
	rng.randomize()
	_spawn_all()

func _spawn_all():
	var length = curve.get_baked_length()
	var progress = spawn_interval

	while progress < length - spawn_interval:
		_spawn_random(progress)
		progress += spawn_interval + rng.randf_range(-3.0, 5.0)


func _spawn_random(progress: float):
	var t: Transform3D = curve.sample_baked_with_rotation(progress, true)
	var mode = _random_mode()
	var obstacle: Obstacle

	match rng.randi() % 3:
		0:
			obstacle = WallObstacle.new()
		1:
			obstacle = PillarObstacle.new()
		2:
			obstacle = RingObstacle.new()
	add_child(obstacle)
	obstacle.global_transform = t
	obstacle.build(tunnel_radius, _random_params(obstacle, mode))  # потом build
	obstacle.hit.connect(_on_hit)

func _random_params(obstacle: Obstacle, mode: Obstacle.BehaviorMode) -> Dictionary:
	var base = { "mode": mode, "speed": rng.randf_range(0.5, 2.0) }
	if obstacle is WallObstacle:
		base["gap_start"] = rng.randf() * TAU
	elif obstacle is PillarObstacle:
		base["offset"] = rng.randf_range(-tunnel_radius * 0.4, tunnel_radius * 0.4)
		base["amplitude"] = tunnel_radius * 0.4
	elif obstacle is RingObstacle:
		base["gap_start"] = rng.randf() * TAU
		base["gap_size"] = PI * rng.randf_range(0.3, 0.6)
	return base

func _random_mode() -> Obstacle.BehaviorMode:
	match rng.randi() % 3:
		0: return Obstacle.BehaviorMode.STATIC
		1: return Obstacle.BehaviorMode.ROTATING
		2: return Obstacle.BehaviorMode.SLIDING
	return Obstacle.BehaviorMode.STATIC

func _on_hit(damage: float):
	if player.has_method("take_damage"):
		player.take_damage(damage)
