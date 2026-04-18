extends TextureRect

var pos
var sc
var f

func _ready() -> void:
	pos = self.position
	sc = self.scale
	
	var k = Settings.k.y
	
	self.position = pos * k
	self.scale = sc * k
