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
		"speed": lerpf(60.0, 60.0, t),
		"density": lerpf(0.7, 0.7, t),
		"difficulty": lerpf(1.0, 1.0, t),
		"radius": lerpf(2.0, 2.0, t),
		"allow_wall": true,
		"allow_pillar": true,
		"allow_ring": true,
		"allow_gateway": true,
		"allow_switch": true,
		"allow_spinner": true,
		"allow_spikes": true,
		"allow_bars": true,
		"allow_lasergrid": true,
		"allow_pendulum": true,
		"allow_vortex": true,
		"allow_bonuses": true,
		"allow_rotating": t > 0.2,
		"allow_sliding": t > 0.5,
		"seed": randi()
	}
