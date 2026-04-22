# obstacle_spawner.gd
class_name ObstacleSpawner
extends Node3D

var curve: Curve3D
var player: Node3D
var generator: Node3D
var track_player: TrackPlayer

var _rng := RandomNumberGenerator.new()
var _current_params: Dictionary = {}

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
	var progress := 40.0
	var track_data := track_player.track
	var session_speed: float = track_player.session["speed"]

	while progress < length - 20.0:
		var time = track_data.get_time_at_dist(progress, session_speed)
		var params := track_player._sampler.sample(time)

		var density: float = params.get("density", 0.5)
		# density 0..1 → интервал 40..5, с рандомным разбросом
		var base_interval := lerpf(40.0, 5.0, density)
		var spread := lerpf(10.0, 1.0, density)  # при низкой плотности разброс больше
		var interval := base_interval + _rng.randf_range(-spread, spread)

		_current_params = params
		_try_spawn(progress)
		if randf() < 0.25:
			_try_spawn_bonus(progress + interval/2)

		progress += maxf(interval, 3.0)  # минимум 3 метра между препятствиями

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
	var max_len := curve.get_baked_length()
	if progress >= max_len:
		return

	var all_types := [Bonus.BonusType.HEALTH, Bonus.BonusType.HEALTH, Bonus.BonusType.HEALTH, Bonus.BonusType.COIN, Bonus.BonusType.COIN, Bonus.BonusType.COIN, Bonus.BonusType.COIN, Bonus.BonusType.COIN, Bonus.BonusType.COIN, Bonus.BonusType.COIN, Bonus.BonusType.COIN]
	var bonus_type: Bonus.BonusType = all_types[_rng.randi() % all_types.size()]

	var t := curve.sample_baked_with_rotation(progress, true)
	var current_radius: float = generator.get_radius_at_point(t.origin)

	# Случайный угол по окружности тоннеля
	var angle := _rng.randf() * TAU
	var offset := t.basis.x * cos(angle) * current_radius \
				+ t.basis.y * sin(angle) * current_radius

	var bonus := Bonus.new()
	add_child(bonus)
	bonus.global_transform = t
	bonus.global_position += offset * 0.8 
	bonus.build(bonus_type)
	bonus.collected.connect(_on_bonus_collected)

func _pick_obstacle() -> Obstacle:
	var types: int = _current_params.get("obstacle_types", 7)
	var available: Array[String] = []
	if types & 1:    available.append("wall")
	if types & 2:    available.append("pillar")
	if types & 4:    available.append("ring")
	if types & 8:    available.append("gateway")
	if types & 16:   available.append("switch")
	if types & 32:   available.append("spinner")
	if types & 64:   available.append("spikes")
	if types & 128:  available.append("bars")
	if types & 256:  available.append("lasergrid")
	if types & 512:  available.append("pendulum")
	if types & 1024: available.append("vortex")
	if available.is_empty():
		return null

	match available[_rng.randi() % available.size()]:
		"wall":      return WallObstacle.new()
		"pillar":    return PillarObstacle.new()
		"ring":      return RingObstacle.new()
		"gateway":   return GatewayObstacle.new()
		"switch":    return SwitchObstacle.new()
		"spinner":   return SpinnerObstacle.new()
		"spikes":    return SpikeObstacle.new()
		"bars":      return BarsObstacle.new()
		"lasergrid": return LaserGridObstacle.new()
		"pendulum":  return PendulumObstacle.new()
		"vortex":    return VortexObstacle.new()
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
		"speed": lerpf(0.3, 4.0, difficulty) + _rng.randf_range(-0.2, 0.2),
	}
	var base_speed := lerpf(1.0, 3.5, difficulty) + _rng.randf_range(-0.3, 0.3)

	# Случайное направление — просто знак
	var direction := 1.0 if _rng.randf() < 0.5 else -1.0
	params["speed"] = base_speed * direction

	# Линейный проход — для Gateway, Bars
	var passage_width := lerpf(tunnel_radius * 1.2, tunnel_radius * 0.3, difficulty)
	
	# Угловой проход — для Ring, Wall
	var passage_angle := lerpf(PI * 1.0, PI * 0.2, difficulty)

	if obstacle is WallObstacle:
		params["gap_start"] = _rng.randf() * TAU
	elif obstacle is PillarObstacle:
		params["offset"]    = _rng.randf_range(-tunnel_radius * 0.4, tunnel_radius * 0.4)
		params["amplitude"] = tunnel_radius * lerpf(0.2, 0.6, difficulty)
	elif obstacle is RingObstacle:
		params["gap_start"] = _rng.randf() * TAU
		params["gap_size"]  = passage_angle
	elif obstacle is GatewayObstacle:
		params["gap_width"]  = passage_width
		params["gap_offset"] = _rng.randf_range(-tunnel_radius * 0.3, tunnel_radius * 0.3)
		params["gap_start"]  = _rng.randf() * TAU
	elif obstacle is SwitchObstacle:
		params["gap_start"] = _rng.randf() * TAU
	elif obstacle is SpinnerObstacle:
		params["blade_count"] = 3
		params["speed"]       = lerpf(1.0, 5.0, difficulty)
	elif obstacle is SpikeObstacle:
		params["gap_count"] = roundi(lerpf(4.0, 2.0, difficulty))
	elif obstacle is BarsObstacle:
		params["gap"]       = passage_width
		params["gap_start"] = _rng.randf() * TAU
	elif obstacle is LaserGridObstacle:
		params["h_count"] = roundi(lerpf(2.0, 4.0, difficulty))
		params["v_count"] = roundi(lerpf(2.0, 4.0, difficulty))
	elif obstacle is PendulumObstacle:
		params["speed"]     = lerpf(1.0, 3.0, difficulty)
		params["amplitude"] = lerpf(PI * 0.4, PI * 0.8, difficulty)

	return params

func _on_hit(damage: float) -> void:
	if player.has_method("take_damage"):
		player.take_damage(damage)

func _on_bonus_collected(type: Bonus.BonusType) -> void:
	if player.has_method("apply_bonus"):
		player.apply_bonus(type)
