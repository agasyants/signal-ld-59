extends Node3D

func _input(event: InputEvent) -> void:
	# ESC - выход
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().quit()
	
	# R - перезапуск текущей сцены
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		get_tree().reload_current_scene()
