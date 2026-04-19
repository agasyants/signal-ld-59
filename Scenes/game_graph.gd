extends Node
# GameGraph

var levels = [] # Массив массивов узлов
var current_node: MyGraphNode
var current_connection: MyGraphConnection

var score: int = 0
var health: int = 3
var last_result := { "completed": false, "score": 0, "time": 0.0 }

func start_level(connection: MyGraphConnection) -> void:
	current_connection = connection
	get_tree().change_scene_to_file("res://Scenes/LoadingScreen.tscn")

func finish_level(completed: bool, result: Dictionary = {}) -> void:
	Engine.time_scale = 1.0
	last_result = {
		"completed": completed,
		"score":     result.get("score", 0),
		"time":      result.get("time",  0.0),
	}
	if completed:
		score += last_result["score"]
		if current_connection:
			current_node = current_connection.to_node
	
	get_tree().change_scene_to_file("res://Scenes/GameGraph.tscn")

func reset_run() -> void:
	Engine.time_scale = 1.0
	current_connection = null
	score  = 0
	health = 3
	last_result = { "completed": false, "score": 0, "time": 0.0 }
	generate_planar_graph(5)
	if levels.size() > 0 and levels[0].size() > 0:
		current_node = levels[0][0]

func _init() -> void:
	generate_planar_graph(5)
	if levels.size() > 0 and levels[0].size() > 0:
		current_node = levels[0][0]

func generate_planar_graph(num_middle_levels: int):
	levels.clear()
	var current_id = 0
	
	for i in range(num_middle_levels + 2):
		var nodes_in_level = 1
		if i > 0 and i < num_middle_levels + 1:
			nodes_in_level = randi_range(2, 4)
		
		var level_array = []
		for j in range(nodes_in_level):
			level_array.append(MyGraphNode.new(current_id, i, j))
			current_id += 1
		levels.append(level_array)

	for i in range(levels.size() - 1):
		var curr_level = levels[i]
		var next_level = levels[i + 1]
		var last_min_next_idx = 0
		
		for node_idx in range(curr_level.size()):
			var node = curr_level[node_idx]
			var start_target = last_min_next_idx
			var end_target = randi_range(start_target, next_level.size() - 1)
			
			if node_idx == curr_level.size() - 1:
				end_target = next_level.size() - 1
				
			for target_idx in range(start_target, end_target + 1):
				var target_node = next_level[target_idx]
				var complexity = randf_range(1.0, 5.0)
				var track_name = "Track " + str(node.id) + "-" + str(target_node.id)
				var connection = MyGraphConnection.new(node, target_node, complexity, track_name)
				connection.track = load("res://Tracks/Delux2/Delux2.tres")
				node.connections.append(connection)
			
			last_min_next_idx = end_target
