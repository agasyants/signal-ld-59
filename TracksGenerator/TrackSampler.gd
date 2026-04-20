# track_sampler.gd
class_name TrackSampler
extends RefCounted

var track: TrackData
var session: Dictionary
var _rng := RandomNumberGenerator.new()
var _cached_values := {}  # Кэш для хранения сгенерированных значений

func setup(t: TrackData, s: Dictionary, seed_val: int = 0) -> void:
	track = t
	session = s
	if seed_val != 0:
		_rng.seed = seed_val
	else:
		_rng.randomize()
	_cached_values.clear()

# Возвращает текущие параметры для заданного момента времени
func sample(time: float) -> Dictionary:
	var sections := _find_sections(time)
	var a: TrackSection = sections["a"]
	var b: TrackSection = sections["b"]
	var t: float = sections["t"]
	
	# Получаем уникальный ключ для кэширования значений этого временного отрезка
	var cache_key := _get_cache_key(a, b)
	
	# Генерируем или получаем из кэша значения для интерполяции
	var interp_values := _get_or_generate_interp_values(cache_key, a, b)
	
	var speed_k      := _interp_with_values(interp_values.speed_va, interp_values.speed_vb, t)
	var density_k    := _interp_with_values(interp_values.density_va, interp_values.density_vb, t)
	var difficulty_k := _interp_with_values(interp_values.difficulty_va, interp_values.difficulty_vb, t)
	var radius_k     := _interp_with_values(interp_values.radius_va, interp_values.radius_vb, t)
	
	var r_min = session["radius"] * radius_k
	
	return {
		"speed":          session["speed"]      * speed_k,
		"density":        session["density"]    * density_k,
		"difficulty":     session["difficulty"] * difficulty_k,
		"radius_min":     r_min,
		"obstacle_types": a.obstacle_types & _session_obstacle_mask(),
		"bonus_types":    a.bonus_types    & _session_bonus_mask(),
		"allow_rotating": session["allow_rotating"] and a.allow_rotating,
		"allow_sliding":  session["allow_sliding"]  and a.allow_sliding,
	}

func _find_sections(time: float) -> Dictionary:
	var def := TrackSection.new()

	if track.sections.is_empty():
		return { "a": def, "b": def, "t": 0.0 }

	if time <= track.sections[0].time:
		return { "a": track.sections[0], "b": track.sections[0], "t": 0.0 }

	if time >= track.sections[-1].time:
		return { "a": track.sections[-1], "b": track.sections[-1], "t": 1.0 }

	for i in range(track.sections.size() - 1):
		var sa := track.sections[i]
		var sb := track.sections[i + 1]
		if time >= sa.time and time <= sb.time:
			var dt := sb.time - sa.time
			var t := (time - sa.time) / dt if dt > 0.0 else 0.0
			return { "a": sa, "b": sb, "t": t }
	
	return { "a": track.sections[-1], "b": track.sections[-1], "t": 1.0 }

func _get_cache_key(a: TrackSection, b: TrackSection) -> String:
	# Используем уникальные идентификаторы секций для ключа кэша
	return str(a.get_instance_id()) + "_" + str(b.get_instance_id())

func _get_or_generate_interp_values(cache_key: String, a: TrackSection, b: TrackSection) -> Dictionary:
	if _cached_values.has(cache_key):
		return _cached_values[cache_key]
	
	# Генерируем случайные значения для интерполяции между a и b
	var values = {
		"speed_va":      _rng.randf_range(a.speed_curve.x,      a.speed_curve.y),
		"speed_vb":      _rng.randf_range(b.speed_curve.x,      b.speed_curve.y),
		"density_va":    _rng.randf_range(a.density_curve.x,    a.density_curve.y),
		"density_vb":    _rng.randf_range(b.density_curve.x,    b.density_curve.y),
		"difficulty_va": _rng.randf_range(a.difficulty_curve.x, a.difficulty_curve.y),
		"difficulty_vb": _rng.randf_range(b.difficulty_curve.x, b.difficulty_curve.y),
		"radius_va":     _rng.randf_range(a.radius_curve.x,     a.radius_curve.y),
		"radius_vb":     _rng.randf_range(b.radius_curve.x,     b.radius_curve.y),
	}
	
	_cached_values[cache_key] = values
	return values

func _interp_with_values(va: float, vb: float, t: float) -> float:
	# Просто линейная интерполяция - работает с любыми значениями
	return lerpf(va, vb, t)

func _session_obstacle_mask() -> int:
	var mask := 0
	if session.get("allow_wall",      true): mask |= 1
	if session.get("allow_pillar",    true): mask |= 2
	if session.get("allow_ring",      true): mask |= 4
	if session.get("allow_gateway",   true): mask |= 8
	if session.get("allow_switch",    true): mask |= 16
	if session.get("allow_spinner",   true): mask |= 32
	if session.get("allow_spikes",    true): mask |= 64
	if session.get("allow_bars",      true): mask |= 128
	if session.get("allow_lasergrid", true): mask |= 256
	if session.get("allow_pendulum",  true): mask |= 512
	if session.get("allow_vortex",    true): mask |= 1024
	return mask

func _session_bonus_mask() -> int:
	if not session.get("allow_bonuses", true):
		return 0
	return 7
