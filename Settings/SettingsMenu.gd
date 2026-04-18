extends Control

var setting_controls = {}  # Словарь для хранения ссылок на элементы управления
var categories = ["graphics", "debug", "controls", "gameplay"]  # Порядок категорий

func _ready():
	# Настройка кнопки возврата
	$BackButton.pressed.connect(_on_back_button_pressed)
	
	# Основной контейнер с вертикальным расположением
	var main_vbox = $VBoxContainer
	
	# Создаем ScrollContainer
	var scroll_container = ScrollContainer.new()
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_container.add_theme_constant_override("margin_right", 10)
	scroll_container.scroll_deadzone = 10
	main_vbox.add_child(scroll_container)
	
	# Контейнер для настроек внутри ScrollContainer
	var settings_container = VBoxContainer.new()
	settings_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_container.add_child(settings_container)
	
	# Генерируем элементы управления для каждой категории
	for category in categories:
		# Основной контейнер категории с отступами между категориями
		var outer_margin = MarginContainer.new()
		outer_margin.add_theme_constant_override("margin_top", 20 if categories.find(category) > 0 else 0)
		settings_container.add_child(outer_margin)

		# Создаем стиль для обводки всей категории
		var category_style = StyleBoxFlat.new()
		category_style.border_color = Color.WHITE
		category_style.set_border_width_all(1)
		category_style.set_corner_radius_all(5)
		category_style.bg_color = Color(0.1, 0.1, 0.1, 0.3)  # Слегка темный фон для контраста

		# Контейнер с обводкой (будет охватывать ВСЮ категорию)
		var bordered_panel = PanelContainer.new()
		bordered_panel.add_theme_stylebox_override("panel", category_style)
		outer_margin.add_child(bordered_panel)

		# Внутренний контейнер для содержимого категории
		var inner_vbox = VBoxContainer.new()
		inner_vbox.add_theme_constant_override("margin_left", 10)
		inner_vbox.add_theme_constant_override("margin_right", 10)
		inner_vbox.add_theme_constant_override("margin_top", 10)
		inner_vbox.add_theme_constant_override("margin_bottom", 10)
		bordered_panel.add_child(inner_vbox)

		# Добавляем заголовок категории
		var category_label = Label.new()
		category_label.text = category.capitalize()
		category_label.add_theme_font_size_override("font_size", 24)
		inner_vbox.add_child(category_label)
		
		# Генерируем настройки для текущей категории
		for setting_key in Settings.CONFIG[category]:
			var config = Settings.CONFIG[category][setting_key]
			var current_value = Settings.settings[setting_key]
			
			# Создаем контейнер для строки настройки
			var hbox = HBoxContainer.new()
			hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			settings_container.add_child(hbox)
			
			# Добавляем метку
			var label = Label.new()
			label.text = config["label"] + ":"
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			hbox.add_child(label)
			
			# Создаем элемент управления в зависимости от типа
			var control
			if config["type"] == "option":
				var option_button = OptionButton.new()
				for option in config["options"]:
					# Форматируем значение при необходимости
					var display_text = config.get("format_value", func(val): return str(val)).call(option)
					option_button.add_item(display_text)
				
				# Устанавливаем текущее значение
				var index = config["options"].find(current_value)
				if index >= 0:
					option_button.select(index)
				
				control = option_button
			elif config["type"] == "checkbox":
				var checkbox = CheckBox.new()
				checkbox.button_pressed = current_value
				control = checkbox
			elif config["type"] == "range":
				# Контейнер для слайдера и значения
				var slider_container = HBoxContainer.new()
				slider_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				
				var slider = HSlider.new()
				slider.min_value = config["min"]
				slider.max_value = config["max"]
				slider.step = config["step"]
				slider.value = current_value
				slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				slider_container.add_child(slider)
				
				var value_label = Label.new()
				value_label.text = str(slider.value)
				value_label.size_flags_horizontal = Control.SIZE_FILL
				slider_container.add_child(value_label)
				
				# Обновляем метку при изменении слайдера
				slider.value_changed.connect(func(value): value_label.text = str(value))
				
				control = slider_container
			
			# Сохраняем ссылку на элемент
			setting_controls[setting_key] = control
			hbox.add_child(control)
	
	# Добавляем кнопку сохранения
	var save_button = Button.new()
	save_button.text = "Save and Apply"
	save_button.pressed.connect(_on_save_and_apply_pressed)
	main_vbox.add_child(save_button)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back_button_pressed()

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/intro.tscn")

func _on_save_and_apply_pressed():
	# Обновляем настройки на основе элементов управления
	for setting_key in setting_controls:
		var control = setting_controls[setting_key]
		
		# Находим конфиг для этой настройки
		var config
		for category in Settings.CONFIG:
			if Settings.CONFIG[category].has(setting_key):
				config = Settings.CONFIG[category][setting_key]
				break
		
		if not config:
			continue
		
		# Обрабатываем разные типы элементов
		if config["type"] == "option" and control is OptionButton:
			var selected_index = control.selected
			Settings.settings[setting_key] = config["options"][selected_index]
		elif config["type"] == "checkbox" and control is CheckBox:
			Settings.settings[setting_key] = control.button_pressed
		elif config["type"] == "range" and control is HBoxContainer:
			# Для range берем значение из первого дочернего элемента (слайдера)
			var slider = control.get_child(0)
			if slider is HSlider:
				Settings.settings[setting_key] = slider.value
	
	# Сохраняем и применяем изменения
	Settings.save_settings()
	Settings.apply_settings()
	get_tree().reload_current_scene()
