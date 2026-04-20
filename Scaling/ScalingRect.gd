extends TextureRect

var pos
var sc

var _is_connected = false

func _ready() -> void:
	if pos == null:
		pos = self.position
		sc = self.scale
		
	if not _is_connected:
		Settings.resolution_changed.connect(_on_resolution_changed)
		_is_connected = true
		
	_on_resolution_changed(Vector2.ZERO)

func _on_resolution_changed(_res: Vector2) -> void:
	var k = Settings.k.y
	self.position = pos * k
	self.scale = sc * k
