extends OptionButton

var resolutions = [
	Vector2(2560, 1440),
	Vector2(1920, 1080),
	Vector2(1600, 900),
	Vector2(1366, 768),
	Vector2(1280, 720),
	Vector2(1024, 576),
	Vector2(960, 540)
]

var pos: Vector2
var s: Vector2
var min_s: Vector2
var orig_font_size: int
var _is_connected = false

func _ready():
	# Scaling logic
	if pos == Vector2.ZERO:
		pos = self.position
		s = self.size
		min_s = self.custom_minimum_size
		orig_font_size = get_theme_font_size("font_size")
	
	if not _is_connected:
		Settings.resolution_changed.connect(_on_resolution_changed)
		_is_connected = true
	
	_on_resolution_changed(Vector2.ZERO)

	var current_res = Settings.get_tree().root.content_scale_size
	
	if not resolutions.has(current_res):
		resolutions.append(current_res)
		resolutions.sort_custom(func(a, b): return a.x > b.x)
		
	for res in resolutions:
		# convert to int
		add_item(str(int(res.x)) + "x" + str(int(res.y)))
		
	var idx = resolutions.find(current_res)
	if idx != -1:
		select(idx)
		
	item_selected.connect(_on_item_selected)

func _on_item_selected(index):
	var res = resolutions[index]
	Settings.set_resolution(res)

func _on_resolution_changed(_res: Vector2) -> void:
	var k = Settings.k.y
	if not get_parent() is Container:
		self.position = pos * k
	self.size = s * k
	self.custom_minimum_size = min_s * k
	add_theme_font_size_override("font_size", int(orig_font_size * k))
