extends Control

@export var phrases: Array[String] = [
	"Packet Racer",
	"The digital frontier. Streams of data surge across the globe at breakneck speed.",
	"Here, information is power—and delivering it is the lifeblood of the world.","Enter the Packet Racers: elite couriers who weave through gridlock and bypass every firewall.",
	"No obstacles. No delays. Just the signal.",
	"Become the ultimate Packet Racer."
]

@onready var label = $CenterContainer/AnimatedLabel
var current_phrase_idx = 0
var timer = 0.0
@export var phrase_duration = 5.0

func _ready():
	_show_next_phrase()

func _process(delta):
	timer += delta
	
	if Input.is_action_just_pressed("Jump") or timer >= phrase_duration:
		timer = 0.0
		current_phrase_idx += 1
		if current_phrase_idx < phrases.size():
			_show_next_phrase()
		else:
			get_tree().change_scene_to_file("res://Scenes/GameGraph.tscn")

func _show_next_phrase():
	label.text = phrases[current_phrase_idx]
	label._ready() # Re-trigger animation
