extends ColorRect

var tween: Tween

func trigger_hit(strength: float = 0.05, duration: float = 0.5):
	self.visible = true
	# Если твин уже идет, убиваем его, чтобы не было конфликтов
	if tween:
		tween.kill()
	
	# Создаем новый твин
	tween = create_tween().set_parallel(true)
	
	# Устанавливаем пиковые значения
	material.set_shader_parameter("shake_intensity", strength)
	material.set_shader_parameter("glitch_intensity", 0.6)
	
	# Плавный возврат в ноль за duration
	tween.tween_property(material, "shader_parameter/shake_intensity", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(material, "shader_parameter/glitch_intensity", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	tween.finished.connect(func(): self.visible = false, CONNECT_ONE_SHOT)
