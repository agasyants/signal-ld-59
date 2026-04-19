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
	# Нормализуем complexity в [0, 1]
	var t := clampf((c - 1.0) / 4.0, 0.0, 1.0)
	var s = {
		"speed":          lerpf(100.0,  100.0, t),
		"density":        lerpf(0.4,  0.8,  t),
		"difficulty":     lerpf(0.1,  1.0,  t),
		"radius":         lerpf(2.0, 2.0,  t),
		"allow_wall":     true,
		"allow_pillar":   true,
		"allow_ring":     t > 0.3,
		"allow_bonuses":  true,
		"allow_rotating": t > 0.2,
		"allow_sliding":  t > 0.5,
		"seed":           randi() # Фиксированный сид для этой связи
	}
	return s
