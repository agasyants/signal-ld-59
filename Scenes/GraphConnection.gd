class_name MyGraphConnection
var from_node: MyGraphNode
var to_node: MyGraphNode
var complexity: float = 1.0
var track_name: String = "Unknown Track"
var other_params: Dictionary = {}

func _init(_from: MyGraphNode, _to: MyGraphNode, _complexity: float = 1.0, _track: String = "Track"):
	from_node = _from
	to_node = _to
	complexity = _complexity
	track_name = _track
