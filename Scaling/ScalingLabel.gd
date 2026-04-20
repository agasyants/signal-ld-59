extends Label

var pos
var s
var min_s
var orig_font_size

var _is_connected = false

func _ready() -> void:
	if pos == null:
		pos = self.position
		s = self.size
		min_s = self.custom_minimum_size
		orig_font_size = get_theme_font_size("font_size")

	if not _is_connected:
		Settings.resolution_changed.connect(_on_resolution_changed)
		_is_connected = true
	
	_on_resolution_changed(Vector2.ZERO)

func _on_resolution_changed(_res: Vector2) -> void:
	var k = Settings.k.y

	var font_size = int(orig_font_size * k)
	add_theme_font_size_override("font_size", font_size)

	if not get_parent() is Container:
		self.position = pos * k
	self.size = s * k
	self.custom_minimum_size = min_s * k
