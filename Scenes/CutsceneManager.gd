extends Control

@export var phrases = [
	["Packet Racer", 3],
	["The digital frontier. Streams of data surge across the globe at breakneck speed.", 4.5],
	["Here, information is power—and delivering it is the lifeblood of the world.",4.5],
	["Enter the Packet Racers: elite couriers who weave through gridlock and bypass every firewall.", 4.5],
	["No obstacles. No delays. Just the signal.", 3],
	["Become the ultimate.", 4.5],
	["Become the Packet Racer.", 10],
]

@onready var label = $CenterContainer/AnimatedLabel
var current_phrase_idx = 0
var timer = 0.0

func _ready():
	_show_next_phrase()

func _process(delta):
	timer += delta
	
	if Input.is_action_just_pressed("Jump") or timer >= phrases[current_phrase_idx][1]:
		timer = 0.0
		current_phrase_idx += 1
		if current_phrase_idx < phrases.size():
			_show_next_phrase()
		else:
			get_tree().change_scene_to_file("res://Scenes/GameGraph.tscn")

func _show_next_phrase():
	label.text = phrases[current_phrase_idx][0]
	label.reset_animation() # Re-trigger animation safely
