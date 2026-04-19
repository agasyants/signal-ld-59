extends Node

var levels = [] # Массив массивов узлов
var current_node: MyGraphNode
var current_connection: MyGraphConnection

# Called when the node enters the scene tree for the first time.
func _init() -> void:
	generate_planar_graph(5)
	if levels.size() > 0 and levels[0].size() > 0:
		current_node = levels[0][0]

func generate_planar_graph(num_middle_levels: int):
	levels.clear()
	var current_id = 0
	
	# 1. Генерируем уровни и узлы
	for i in range(num_middle_levels + 2):
		var nodes_in_level = 1
		if i > 0 and i < num_middle_levels + 1:
			nodes_in_level = randi_range(2, 4)
		
		var level_array = []
		for j in range(nodes_in_level):
			level_array.append(MyGraphNode.new(current_id, i, j))
			current_id += 1
		levels.append(level_array)

	# 2. Создаем связи между уровнями
	for i in range(levels.size() - 1):
		var curr_level = levels[i]
		var next_level = levels[i + 1]
		
		# Чтобы не было пересечений, используем метод "раздвижного окна"
		var last_min_next_idx = 0
		
		for node_idx in range(curr_level.size()):
			var node = curr_level[node_idx]
			
			# Определяем диапазон узлов на следующем уровне, к которым можно подключиться
			# Он начинается там, где закончил предыдущий узел этого уровня (или раньше, но без перехлеста)
			var start_target = last_min_next_idx
			
			# Выбираем случайное количество связей (минимум 1)
			# Но так, чтобы последний узел на уровне обязательно дотянулся до последнего узла следующего
			var end_target = randi_range(start_target, next_level.size() - 1)
			
			# Если это последний узел текущего уровня, он ОБЯЗАН соединиться с последним узлом следующего
			if node_idx == curr_level.size() - 1:
				end_target = next_level.size() - 1
				
			for target_idx in range(start_target, end_target + 1):
				var target_node = next_level[target_idx]
				var complexity = randf_range(1.0, 5.0)
				var track_name = "Track " + str(node.id) + "-" + str(target_node.id)
				var connection = MyGraphConnection.new(node, target_node, complexity, track_name)
				node.connections.append(connection)
			
			# Обновляем границу, чтобы следующий узел не "залезал" выше текущих связей
			last_min_next_idx = end_target
