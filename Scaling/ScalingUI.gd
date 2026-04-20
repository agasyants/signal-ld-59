extends Control

var pos
var s
var min_s

var _is_connected = false

func _ready() -> void:
	if pos == null:
		pos = self.position
		s = self.size
		min_s = self.custom_minimum_size
		
	if not _is_connected:
		Settings.resolution_changed.connect(_on_resolution_changed)
		_is_connected = true
		
	_on_resolution_changed(Vector2.ZERO)

func _on_resolution_changed(_res: Vector2) -> void:
	var k = Settings.k.y
	if not get_parent() is Container:
		self.position = pos * k
	self.size = s * k
	self.custom_minimum_size = min_s * k
