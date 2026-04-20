extends Node2D

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
	#self.visibility_mode = TouchScreenButton.VISIBILITY_ALWAYS

func _on_resolution_changed(_res: Vector2) -> void:
	var k = Settings.k.y
	if not get_parent() is Container:
		self.position = pos * k
	self.scale = sc * k
