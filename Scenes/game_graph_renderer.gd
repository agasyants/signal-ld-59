extends Control

var graph_container: Node2D

func _ready() -> void:
	graph_container = Node2D.new()
	add_child(graph_container)

	var screen_size = get_viewport_rect().size
	
	var total_levels = GameGraph.levels.size()
	var max_nodes_in_level = 0
	for level in GameGraph.levels:
		max_nodes_in_level = max(max_nodes_in_level, level.size())

	# --- Настройки сетки ---
	var step_x = 200.0 # Расстояние между колонками (уровнями)
	var step_y = 120.0 # Расстояние между узлами в одной колонке

	# Вычисляем габариты всего графа
	var total_graph_width = (total_levels - 1) * step_x
	# Высота считается по самому "толстому" уровню
	var total_graph_height = (max_nodes_in_level - 1) * step_y

	# Точка старта, чтобы центр графа совпал с центром экрана
	var start_x = (screen_size.x - total_graph_width) / 2.0
	var start_y = (screen_size.y - total_graph_height) / 2.0

	# Функция расчета позиции
	var get_node_pos = func(l_idx: int, n_idx: int):
		var current_level_size = GameGraph.levels[l_idx].size()
		
		# X — позиция колонки (уровня)
		var x = start_x + l_idx * step_x
		
		# Y — позиция узла. 
		# Вычисляем "высоту" текущего уровня, чтобы найти его локальный центр
		var current_level_height = (current_level_size - 1) * step_y
		var center_offset_y = (total_graph_height - current_level_height) / 2.0
		
		var y = start_y + center_offset_y + n_idx * step_y
		return Vector2(x, y)

	# --- Отрисовка ---
	
	# 1. Линии и кнопки соединений
	for l_idx in total_levels:
		var level = GameGraph.levels[l_idx]
		for n_idx in level.size():
			var node = level[n_idx]
			var p1 = get_node_pos.call(l_idx, n_idx)
			
			for conn in node.connections:
				var target_node = conn.to_node
				var p2 = get_node_pos.call(target_node.level, target_node.index_in_level)
				
				var is_available = (node == GameGraph.current_node)
				
				# Рисуем линию
				var line = Line2D.new()
				line.points = PackedVector2Array([p1, p2])
				line.width = 3.0
				line.default_color = Color(0.4, 1.0, 0.4, 0.8) if is_available else Color(0.4, 0.7, 1.0, 0.2)
				line.antialiased = true
				line.z_index = -1
				graph_container.add_child(line)
				
				# Создаем кнопку в центре соединения
				var midpoint = (p1 + p2) / 2.0
				var conn_btn = Button.new()
				conn_btn.text = conn.track_name + "\nDiff: %.1f" % conn.complexity
				conn_btn.custom_minimum_size = Vector2(80, 40)
				conn_btn.position = midpoint - Vector2(40, 20)
				conn_btn.add_theme_font_size_override("font_size", 10)
				
				# Блокируем кнопку если это не текущий путь
				conn_btn.disabled = !is_available
				
				# При клике - перемещаемся к следующему узлу
				conn_btn.pressed.connect(func(): 
					print("Selected connection: ", conn.track_name)
					GameGraph.current_connection = conn
					GameGraph.current_node = target_node
					# Перерисовываем граф, чтобы обновить доступные кнопки
					get_tree().reload_current_scene() 
				)
				
				graph_container.add_child(conn_btn)

	# 2. Узлы (спрайты) и награды
	for l_idx in total_levels:
		var level = GameGraph.levels[l_idx]
		for n_idx in level.size():
			var node = level[n_idx]
			var node_pos = get_node_pos.call(l_idx, n_idx)
			var is_current = (node == GameGraph.current_node)
			
			var node_sprite = Sprite2D.new()
			var tex = GradientTexture2D.new()
			tex.width = 40 if is_current else 32
			tex.height = 40 if is_current else 32
			tex.fill = GradientTexture2D.FILL_RADIAL
			tex.fill_from = Vector2(0.5, 0.5)
			var grad = Gradient.new()
			
			# Подсвечиваем текущий узел золотым, остальные — голубым
			var glow_color = Color.GOLD if is_current else Color.CYAN
			grad.set_color(0, glow_color)
			grad.set_color(1, Color(glow_color.r, glow_color.g, glow_color.b, 0))
			
			tex.gradient = grad
			node_sprite.texture = tex
			node_sprite.position = node_pos
			graph_container.add_child(node_sprite)
			
			# Отображение награды
			if node.reward_type != "none":
				var label = Label.new()
				label.text = "%s: +%d" % [node.reward_type.capitalize(), node.reward_amount]
				label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				label.position = node_pos + Vector2(-50, 20)
				label.custom_minimum_size = Vector2(100, 20)
				label.add_theme_color_override("font_color", Color.YELLOW)
				label.add_theme_font_size_override("font_size", 12)
				graph_container.add_child(label)
