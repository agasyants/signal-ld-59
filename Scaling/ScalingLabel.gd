extends Label

var pos
var s
var f

func _ready() -> void:
	pos = self.position
	s = self.size
	f = self.label_settings.font_size
	
	var k = Settings.k.y
	
	self.position = pos * k
	self.size = s * k
	self.label_settings.font_size = f * k
