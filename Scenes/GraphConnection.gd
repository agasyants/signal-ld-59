# my_graph_connection.gd
class_name MyGraphConnection

var from_node: MyGraphNode
var to_node: MyGraphNode
var complexity: float = 1.0
var track_name: String = "Unknown Track"
var other_params: Dictionary = {}

# Трек и сессия генерируются один раз при создании ребра
var track: TrackData = null
var session: Dictionary = {}

func _init(_from: MyGraphNode, _to: MyGraphNode, _complexity: float = 1.0, _track: String = "Track"):
	from_node = _from
	to_node = _to
	complexity = _complexity
	track_name = _track
	session = _generate_session(_complexity)

# complexity 1..5 → сессионные параметры
# Чем выше complexity, тем быстрее, плотнее и сложнее
func _generate_session(c: float) -> Dictionary:
	var t := clampf((c - 1.0) / 4.0, 0.0, 1.0)
	return {
		"speed":            lerpf(40.0, 50.0, t),
		"density":          lerpf(0.7,  0.95,  t),
		"difficulty":       lerpf(0.6,  1.0,  t),
		"radius":           lerpf(1.6,  1.3,  t),
		"allow_wall":       true,
		"allow_pillar":     true,
		"allow_ring":       true,
		"allow_gateway":    true,
		"allow_switch":     t > 0.2,
		"allow_spinner":    t > 0.34,
		"allow_spikes":     t > 0.5,
		"allow_bars":       true,
		"allow_lasergrid":  t > 0.2,
		"allow_pendulum":   true,
		"allow_vortex":     t > 0.6,
		"allow_bonuses":    true,
		"allow_rotating":   true,
		"allow_sliding":    false,
		"seed":             randi()
	}
