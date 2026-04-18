extends Control

var pos
var s

func _ready() -> void:
	pos = self.position
	s = self.size
	var k = Settings.k.y
	self.position = pos * k
	self.size = s * k
