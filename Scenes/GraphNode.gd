class_name MyGraphNode
var id: int
var level: int
var index_in_level: int
var connections: Array[MyGraphConnection] = []

var reward_type: String = "none" # "health", "points", etc.
var reward_amount: int = 0

func _init(_id, _lvl, _idx):
	id = _id
	level = _lvl
	index_in_level = _idx
	
	# Randomize reward for demo
	if randf() > 0.7:
		reward_type = ["health", "points"].pick_random()
		reward_amount = randi_range(1, 10) * (10 if reward_type == "points" else 1)
