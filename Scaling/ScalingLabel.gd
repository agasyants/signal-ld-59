extends Label

var pos
var s
var f

func _ready() -> void:
	var k = Settings.k.y
	
	var font_size = 48 * k
	add_theme_font_size_override("font_size", font_size)
	
	pos = self.position
	s = self.size
	
	self.position = pos * k
	self.size = s * k
