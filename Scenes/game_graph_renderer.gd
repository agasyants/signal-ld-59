extends Control

var graph_container: Node2D

func _ready() -> void:
	Settings.resolution_changed.connect(_on_resolution_changed)
	_on_resolution_changed(Vector2.ZERO)

func _on_resolution_changed(_res: Vector2) -> void:
	update_graph()

func update_graph() -> void:
	if graph_container:
		graph_container.queue_free()
	
	graph_container = Node2D.new()
	add_child(graph_container)

	var screen_size = get_viewport_rect().size
	var k = Settings.k.y * 0.75
	
	# --- Background/Decorations ---
	var bg_label = Label.new()
	bg_label.text = "NETWORK TOPOLOGY MAP // PROTOCOL: SIGNAL-LD-59"
	bg_label.add_theme_font_size_override("font_size", int(24 * k))
	bg_label.modulate = Color(0, 1, 1, 0.3)
	bg_label.position = Vector2(40, 40) * k
	graph_container.add_child(bg_label)

	var status_label = Label.new()
	status_label.text = "STATUS: ACTIVE STREAM // ENCRYPTION: 1024-BIT"
	status_label.add_theme_font_size_override("font_size", int(14 * k))
	status_label.modulate = Color(0, 1, 0.5, 0.2)
	status_label.position = Vector2(40, 70) * k
	graph_container.add_child(status_label)

	# --- Player Stats HUD ---
	var coins_label = Label.new()
	coins_label.text = "DATA COINS: %d" % GameGraph.coins
	coins_label.add_theme_font_size_override("font_size", int(16 * k))
	coins_label.modulate = Color.GOLD
	coins_label.position = Vector2(screen_size.x - 300 * k, 70 * k)
	graph_container.add_child(coins_label)

	var health_label = Label.new()
	var hearts = ""
	for i in range(GameGraph.health): hearts += "♥️"
	if GameGraph.health >= GameGraph.max_health:
		hearts += " MAX"
	health_label.text = "INTEGRITY: %s" % hearts
	health_label.add_theme_font_size_override("font_size", int(16 * k))
	health_label.modulate = Color.ORANGE_RED
	health_label.position = Vector2(screen_size.x - 300 * k, 95 * k)
	graph_container.add_child(health_label)
	
	var total_levels = GameGraph.levels.size()
	var max_nodes_in_level = 0
	for level in GameGraph.levels:
		max_nodes_in_level = max(max_nodes_in_level, level.size())

	# --- Настройки сетки ---
	var step_x = 220.0 * k
	var step_y = 130.0 * k
	
	var level_names = ["SOURCE", "SUBNET A", "SUBNET B", "GATEWAY", "FIREWALL", "CORE", "END_NODE"]

	# Вычисляем габариты всего графа
	var total_graph_width = (total_levels - 1) * step_x
	var total_graph_height = (max_nodes_in_level - 1) * step_y

	# Точка старта, чтобы центр графа совпал с центром экрана
	var start_x = (screen_size.x - total_graph_width) / 2.0
	var start_y = (screen_size.y - total_graph_height) / 2.0
	
	# Рендерим заголовки уровней
	for i in range(total_levels):
		var l_label = Label.new()
		var l_name = level_names[i] if i < level_names.size() else "ZONE %02d" % i
		l_label.text = l_name
		l_label.add_theme_font_size_override("font_size", int(12 * k))
		l_label.modulate = Color(1, 1, 1, 0.15)
		l_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var lx = start_x + i * step_x
		l_label.position = Vector2(lx - 50 * k, start_y - 80 * k)
		l_label.custom_minimum_size = Vector2(100 * k, 20 * k)
		graph_container.add_child(l_label)

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

	var type_colors = {
		"SERVER": Color.CYAN,
		"DNS NODE": Color.LIME_GREEN,
		"FIREWALL": Color.ORANGE_RED,
		"GATEWAY": Color.GOLD,
		"ROUTER": Color.MAGENTA,
		"DATABASE": Color.MEDIUM_PURPLE,
		"UPLINK": Color.ALICE_BLUE
	}

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
				line.width = 3.0 * k
				line.default_color = Color(0.4, 1.0, 0.4, 0.8) if is_available else Color(0.4, 0.7, 1.0, 0.2)
				line.antialiased = true
				line.z_index = -1
				graph_container.add_child(line)
				
				# Создаем кнопку в центре соединения
				var midpoint = (p1 + p2) / 2.0
				var conn_btn = Button.new()
				conn_btn.text = conn.track_name + "\nDiff: %.1f" % conn.complexity
				conn_btn.custom_minimum_size = Vector2(80, 40) * k
				conn_btn.position = midpoint - (Vector2(40, 20) * k)
				conn_btn.add_theme_font_size_override("font_size", int(10 * k))
				
				# Блокируем кнопку если это не текущий путь
				conn_btn.disabled = !is_available
				
				# При клике - перемещаемся к следующему узлу
				conn_btn.pressed.connect(func():
					print("Selected connection: ", conn.track_name)
					GameGraph.current_connection = conn
					GameGraph.current_node = target_node
					GameGraph.start_level(conn)
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
			tex.width = int((40 if is_current else 32) * k)
			tex.height = int((40 if is_current else 32) * k)
			tex.fill = GradientTexture2D.FILL_RADIAL
			tex.fill_from = Vector2(0.5, 0.5)
			var grad = Gradient.new()
			
			# Подсвечиваем текущий узел золотым, а типы узлов — разными цветами
			var base_color = type_colors.get(node.node_type, Color.CYAN)
			var glow_color = Color.GOLD if is_current else base_color
			grad.set_color(0, glow_color)
			grad.set_color(1, Color(glow_color.r, glow_color.g, glow_color.b, 0))
			
			tex.gradient = grad
			node_sprite.texture = tex
			node_sprite.position = node_pos
			graph_container.add_child(node_sprite)
			
			# Подпись типа и IP под узлом
			var info_label = Label.new()
			info_label.text = "%s\n%s" % [node.node_type, node.ip_address]
			info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			info_label.add_theme_font_size_override("font_size", int(10 * k))
			info_label.modulate = base_color.lerp(Color.WHITE, 0.5)
			info_label.modulate.a = 0.8
			info_label.position = node_pos + Vector2(-60 * k, 25 * k)
			info_label.custom_minimum_size = Vector2(120 * k, 30 * k)
			graph_container.add_child(info_label)

			# Отображение награды (чуть ниже теперь)
			if node.reward_type != "none":
				var label = Label.new()
				var display_name = "Coins" if node.reward_type == "points" else node.reward_type.capitalize()
				label.text = "%s: +%d" % [display_name, node.reward_amount]
				label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				label.position = node_pos + (Vector2(-50, 60) * k)
				label.custom_minimum_size = Vector2(100, 20) * k
				label.add_theme_color_override("font_color", Color.YELLOW)
				label.add_theme_font_size_override("font_size", int(11 * k))
				graph_container.add_child(label)
