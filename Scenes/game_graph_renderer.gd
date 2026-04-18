extends Control

var graph_container

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	graph_container = Node2D.new()
	# 1. Сначала создаем все линии, чтобы они были под узлами
	for level in GameGraph.levels:
		for node in level:
			var start_pos = Vector2(node.level * 100, node.index_in_level * 100)
			
			for connection in node.connections:
				# ВАЖНО: используем координаты цели, а не индекс k
				var end_pos = Vector2(connection.level * 100, connection.index_in_level * 100)
				
				var line = Line2D.new()
				line.width = 20
				line.default_color = Color(0.87, 0.43, 0.56, 0.5) # Немного прозрачности для красоты
				line.add_point(start_pos)
				line.add_point(end_pos)
				graph_container.add_child(line)

	# 2. Потом создаем визуальные узлы (спрайты)
	for level in GameGraph.levels:
		for node in level:
			var node_2d = Sprite2D.new()
			# Для тестов лучше использовать простую иконку или маленький TextureRect
			var tex = GradientTexture2D.new()
			tex.width = 16
			tex.height = 16
			node_2d.texture = tex
			node_2d.position = Vector2(node.level * 100, node.index_in_level * 100)
			graph_container.add_child(node_2d)

	graph_container.position = Vector2(100, 100)
	add_child(graph_container)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
