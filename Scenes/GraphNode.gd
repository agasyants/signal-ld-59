class_name MyGraphNode
var id: int
var level: int
var index_in_level: int
var connections: Array[MyGraphNode] = []

func _init(_id, _lvl, _idx):
	id = _id
	level = _lvl
	index_in_level = _idx
