extends "res://Scaling/ScalingButton.gd"

func _ready() -> void:
	super._ready()
	self.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	GameGraph.current_connection = GameGraph.levels[0][0].connections[0]
	get_tree().change_scene_to_file("res://Scenes/Cut.tscn")
