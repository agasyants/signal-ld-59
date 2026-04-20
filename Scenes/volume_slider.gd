extends HSlider

var pos: Vector2
var s: Vector2
var min_s: Vector2

var _is_connected = false

func _ready():
	# Scaling logic
	if pos == Vector2.ZERO:
		pos = self.position
		s = self.size
		min_s = self.custom_minimum_size
	
	if not _is_connected:
		Settings.resolution_changed.connect(_on_resolution_changed)
		_is_connected = true
		
	_on_resolution_changed(Vector2.ZERO)
	
	# Audio logic
	var bus_index = AudioServer.get_bus_index("Master")
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	value_changed.connect(_on_value_changed)

func _on_resolution_changed(_res: Vector2) -> void:
	var k = Settings.k.y
	if not get_parent() is Container:
		self.position = pos * k
	self.size = s * k
	self.custom_minimum_size = min_s * k

func _on_value_changed(new_value):
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(new_value))
