# track_sampler.gd
class_name TrackSampler
extends RefCounted

var track: TrackData
var session: Dictionary
var _rng := RandomNumberGenerator.new()

func setup(t: TrackData, s: Dictionary) -> void:
	track = t
	session = s
	_rng.randomize()

# Возвращает текущие параметры для заданного момента времени
func sample(time: float) -> Dictionary:
	var sections := _find_sections(time)
	var a: TrackSection = sections["a"]
	var b: TrackSection = sections["b"]
	var t: float = sections["t"]

	var speed_k      := _interp(a.speed_curve,      b.speed_curve,      t)
	var density_k    := _interp(a.density_curve,    b.density_curve,    t)
	var difficulty_k := _interp(a.difficulty_curve, b.difficulty_curve, t)
	var radius_k     := _interp(a.radius_curve,     b.radius_curve,     t)

	var spread := 0.15
	var r_min = session["radius"] * clampf(radius_k - spread, 0.1, 10.0)
	var r_max = session["radius"] * clampf(radius_k + spread, 0.1, 10.0)

	return {
		"speed":          session["speed"]      * speed_k,
		"density":        session["density"]    * density_k,
		"difficulty":     session["difficulty"] * difficulty_k,
		"radius_min":     r_min,
		"radius_max":     r_max,
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

func _interp(ca: Vector2, cb: Vector2, t: float) -> float:
	var va := _rng.randf_range(ca.x, ca.y)
	var vb := _rng.randf_range(cb.x, cb.y)
	return smoothstep(0.0, 1.0, lerpf(va, vb, t))

func _session_obstacle_mask() -> int:
	var mask := 0
	if session.get("allow_wall",   true): mask |= 1
	if session.get("allow_pillar", true): mask |= 2
	if session.get("allow_ring",   true): mask |= 4
	return mask

func _session_bonus_mask() -> int:
	if not session.get("allow_bonuses", true):
		return 0
	return 7
