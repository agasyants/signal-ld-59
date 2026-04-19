# obstacle_spawner.gd
class_name ObstacleSpawner
extends Node3D

var curve: Curve3D
var player: Node3D
var generator: Node3D
var track_player: TrackPlayer

var _rng := RandomNumberGenerator.new()
var _current_params: Dictionary = {}

# Сколько метров впереди игрока спавним препятствия
const SPAWN_AHEAD: float = 80.0

func setup(c: Curve3D, p: Node3D, gen: Node3D, tp: TrackPlayer) -> void:
	curve = c
	player = p
	generator = gen
	track_player = tp
	_rng.randomize()
	track_player.params_changed.connect(_on_params_changed)
	
	# Спавним всё сразу после первого кадра
	call_deferred("_spawn_all")

func _spawn_all() -> void:
	var length := curve.get_baked_length()
	var progress := 40.0  # отступ от старта
	var track_data := track_player.track
	var session_speed: float = track_player.session["speed"]
	
	while progress < length - 20.0:
		# Берём параметры трека в этой временной точке через точное соответствие расстояние -> время
		var time = track_data.get_time_at_dist(progress, session_speed)
		var params := track_player._sampler.sample(time)
		
		var density: float = params.get("density", 0.5)
		var interval := lerpf(40.0, 5.0, density)
		
		_current_params = params
		_try_spawn(progress)
		
		progress += interval + _rng.randf_range(-2.0, 2.0)
	
	print("Spawned all obstacles. Curve length: ", length)

func _on_params_changed(params: Dictionary) -> void:
	_current_params = params
	generator.set_speed_from_track(params["speed"])

func _try_spawn(progress: float) -> void:
	var max_len := curve.get_baked_length()
	if progress >= max_len:
		return

	var t := curve.sample_baked_with_rotation(progress, true)
	var current_radius: float = generator.get_radius_at_point(t.origin)
	var obstacle := _pick_obstacle()
	if obstacle == null:
		return

	add_child(obstacle)
	obstacle.global_transform = t
	obstacle.build(current_radius, _build_params(obstacle, current_radius))
	obstacle.hit.connect(_on_hit)

func _try_spawn_bonus(progress: float) -> void:
	if not _current_params.get("allow_bonuses", false):
		return
	var bonus_mask: int = _current_params.get("bonus_types", 0)
	if bonus_mask == 0:
		return

	var max_len := curve.get_baked_length()
	if progress >= max_len:
		return

	# Выбираем случайный разрешённый тип бонуса
	var available_bonuses: Array[int] = []
	if bonus_mask & 1: available_bonuses.append(Bonus.BonusType.HEALTH)
	if bonus_mask & 2: available_bonuses.append(Bonus.BonusType.SHIELD)
	if bonus_mask & 4: available_bonuses.append(Bonus.BonusType.SLOW)
	if available_bonuses.is_empty():
		return

	var bonus_type: int = available_bonuses[_rng.randi() % available_bonuses.size()]
	var t := curve.sample_baked_with_rotation(progress, true)
	var bonus := Bonus.new()
	add_child(bonus)
	bonus.global_transform = t
	bonus.build(bonus_type)
	bonus.collected.connect(_on_bonus_collected)

func _pick_obstacle() -> Obstacle:
	var types: int = _current_params.get("obstacle_types", 7)
	var available: Array[String] = []
	if types & 1: available.append("wall")
	if types & 2: available.append("pillar")
	if types & 4: available.append("ring")
	if available.is_empty():
		return null

	match available[_rng.randi() % available.size()]:
		"wall":   return WallObstacle.new()
		"pillar": return PillarObstacle.new()
		"ring":   return RingObstacle.new()
	return null

func _build_params(obstacle: Obstacle, tunnel_radius: float) -> Dictionary:
	var difficulty: float = _current_params.get("difficulty", 0.3)
	var allow_rotating: bool = _current_params.get("allow_rotating", true)
	var allow_sliding: bool  = _current_params.get("allow_sliding",  false)

	var modes: Array[Obstacle.BehaviorMode] = [Obstacle.BehaviorMode.STATIC]
	if allow_rotating: modes.append(Obstacle.BehaviorMode.ROTATING)
	if allow_sliding:  modes.append(Obstacle.BehaviorMode.SLIDING)
	var mode: Obstacle.BehaviorMode = modes[_rng.randi() % modes.size()]

	var params := {
		"mode":  mode,
		# difficulty 0..1 → скорость препятствия 0.3..4.0
		"speed": lerpf(0.3, 4.0, difficulty) + _rng.randf_range(-0.2, 0.2),
	}

	if obstacle is WallObstacle:
		params["gap_start"] = _rng.randf() * TAU
	elif obstacle is PillarObstacle:
		params["offset"]    = _rng.randf_range(-tunnel_radius * 0.4, tunnel_radius * 0.4)
		params["amplitude"] = tunnel_radius * lerpf(0.2, 0.6, difficulty)
	elif obstacle is RingObstacle:
		params["gap_start"] = _rng.randf() * TAU
		params["gap_size"]  = lerpf(PI * 0.7, PI * 0.25, difficulty)

	return params

func _on_hit(damage: float) -> void:
	if player.has_method("take_damage"):
		player.take_damage(damage)

func _on_bonus_collected(type: String) -> void:
	if player.has_method("apply_bonus"):
		player.apply_bonus(type)
