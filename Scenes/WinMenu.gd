extends Control

@onready var score_label = $CenterContainer/VBoxContainer/ScoreLabel
@onready var coins_label = $CenterContainer/VBoxContainer/CoinsLabel
@onready var title_label = $CenterContainer/VBoxContainer/TitleLabel
@onready var back_button = $CenterContainer/VBoxContainer/BackButton

func _ready():
	score_label.text = "TOTAL SCORE: %d" % GameGraph.score
	coins_label.text = "COINS COLLECTED: %d" % GameGraph.coins
	
	back_button.pressed.connect(_on_back_pressed)
	
	# Initial state for animation
	title_label.modulate.a = 0
	score_label.modulate.a = 0
	coins_label.modulate.a = 0
	back_button.modulate.a = 0
	
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(title_label, "modulate:a", 1.0, 1.0)
	tween.tween_property(score_label, "modulate:a", 1.0, 0.5)
	tween.tween_property(coins_label, "modulate:a", 1.0, 0.5)
	tween.tween_property(back_button, "modulate:a", 1.0, 0.5)

func _process(_delta):
	# Cyber-glow effect for title
	var pulse = (sin(Time.get_ticks_msec() * 0.005) + 1.0) * 0.5
	title_label.add_theme_color_override("font_color", Color.CYAN.lerp(Color.WHITE, pulse * 0.5))

func _on_back_pressed():
	GameGraph.reset_run()
	get_tree().change_scene_to_file("res://Scenes/intro.tscn")
