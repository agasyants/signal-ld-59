extends "res://Scaling/ScalingLabel.gd"

var is_animated = false
var elapsed_time = 0.0
var initial_text = ""
var animation_duration = 1.0
var characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*"

func _ready() -> void:
	super._ready()
	reset_animation()

func reset_animation() -> void:
	initial_text = text
	is_animated = true
	elapsed_time = 0.0
	
func _process(delta: float) -> void:
	if is_animated:
		elapsed_time += delta
		
		# Calculate progress from 0.0 to 1.0
		var progress = min(elapsed_time / animation_duration, 1.0)
		
		# Determine how many characters are "finished"
		var finished_count = int(initial_text.length() * progress)
		
		var new_text = ""
		
		for i in range(initial_text.length()):
			if i < finished_count:
				# Use the original character
				new_text += initial_text[i]
			else:
				# Use a random character (keeping spaces as spaces usually looks cleaner)
				if initial_text[i] == " ":
					new_text += " "
				else:
					var random_char = characters[randi() % characters.length()]
					new_text += random_char
		
		text = new_text
		
		# Stop animating once we reach 100%
		if progress >= 1.0:
			is_animated = false
			text = initial_text # Final safety set to ensure exact text
