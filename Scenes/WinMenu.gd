extends Control

@onready var coins_label = $CenterContainer/VBoxContainer/CoinsLabel
@onready var title_label = $CenterContainer/VBoxContainer/TitleLabel
@onready var back_button = $CenterContainer/VBoxContainer/BackButton

func _ready():
	print("WinMenu: _ready() START")
	print("WinMenu: GameGraph.coins = %d" % GameGraph.coins)
	print("WinMenu: Settings.k = ", Settings.k)
	
	if coins_label:
		coins_label.text = "COINS COLLECTED: %d" % GameGraph.coins
		print("WinMenu: Updated coins_label text")
	else:
		print("WinMenu: ERROR - coins_label is NULL")
		
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
		print("WinMenu: Connected back_button")
	else:
		print("WinMenu: ERROR - back_button is NULL")
	
	# Force visibility - no more transparency for now to be 100% safe
	title_label.modulate.a = 1.0
	coins_label.modulate.a = 1.0
	back_button.modulate.a = 1.0
	
	print("WinMenu: _ready() FINISHED")

func _process(_delta):
	# Cyber-glow effect for title
	var pulse = (sin(Time.get_ticks_msec() * 0.005) + 1.0) * 0.5
	title_label.add_theme_color_override("font_color", Color.CYAN.lerp(Color.WHITE, pulse * 0.5))

func _on_back_pressed():
	GameGraph.reset_run()
	get_tree().change_scene_to_file("res://Scenes/intro.tscn")
