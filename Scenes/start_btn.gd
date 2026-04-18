extends "res://Scaling/ScalingButton.gd"

func _ready() -> void:
	super._ready()
	self.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")
