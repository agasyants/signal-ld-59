extends Node2D

var pos
var sc

func _ready() -> void:
	pos = self.position
	sc = self.scale
	
	var k = Settings.k.y
	
	self.position = pos * k
	self.scale = sc * k
	#self.visibility_mode = TouchScreenButton.VISIBILITY_ALWAYS
