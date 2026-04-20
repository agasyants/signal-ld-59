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
	var r = randf()
	if r < 0.2: # 20% chance for Max Health upgrade
		reward_type = "max_health"
		reward_amount = 1
	elif r < 0.6: # 40% chance for health
		reward_type = "health"
		reward_amount = 1
	else: # 40% chance for coins
		reward_type = "points"
		reward_amount = randi_range(2, 5)
