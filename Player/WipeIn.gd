extends ColorRect

func _ready():
	# 1. Сразу делаем экран белым и растянутым
	material.set_shader_parameter("progress", 1.0)
	visible = true
	
	var tween = create_tween()
	
	# 2. Мгновенная пауза (замирание в гиперпространстве на 0.1 сек)
	tween.tween_interval(0.1)
	
	# 3. РЕЗКИЙ выход. Длительность 0.4 сек — это стандарт для "удара"
	# TRANS_EXPO делает выход из гиперпространства агрессивным
	tween.tween_property(material, "shader_parameter/progress", 0.0, 2.4)\
		 .set_trans(Tween.TRANS_EXPO)\
		 .set_ease(Tween.EASE_OUT)
	
	tween.finished.connect(func(): visible = false)
