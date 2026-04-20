class_name MyGraphNode
var id: int
var level: int
var index_in_level: int
var connections: Array[MyGraphConnection] = []

var reward_type: String = "none" # "health", "points", etc.
var reward_amount: int = 0

var node_type: String = "Terminal"
var ip_address: String = "127.0.0.1"

func _init(_id, _lvl, _idx):
	id = _id
	level = _lvl
	index_in_level = _idx
	
	var types = ["SERVER", "DNS NODE", "FIREWALL", "GATEWAY", "ROUTER", "DATABASE", "UPLINK"]
	node_type = types.pick_random()
	ip_address = "%d.%d.%d.%d" % [randi_range(10, 255), randi_range(0, 255), randi_range(0, 255), randi_range(1, 254)]
	
	# Always give a reward
	reward_type = ["health", "points"].pick_random()
	if reward_type == "points":
		reward_amount = randi_range(2, 5) # 2 to 5 coins
	else:
		reward_amount = 1 # Always +1 health
