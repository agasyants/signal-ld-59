extends Control

@onready var label = $CenterContainer/VBoxContainer/Label
@onready var back_button = $CenterContainer/VBoxContainer/BackButton

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	back_button.pressed.connect(_on_back_pressed)
	hide()

func _process(delta):
	if visible:
		# Flashing effect
		var pulse = (sin(Time.get_ticks_msec() * 0.01) + 1.0) * 0.5
		label.add_theme_color_override("font_color", Color.RED.lerp(Color.DARK_RED, pulse))

func _on_back_pressed():
	get_tree().paused = false
	print("Death screen: Resetting and returning to systems...")
	GameGraph.reset_run()
	GameGraph.finish_level(false)

func show_death_screen():
	get_tree().paused = true
	show()
