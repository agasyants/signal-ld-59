extends Node

signal resolution_changed(res: Vector2)

var k = Vector2(1, 1)
var real_size

func _ready():
	real_size = Vector2(get_tree().root.content_scale_size)
	var render_size = DisplayServer.screen_get_size()
	set_resolution(render_size)

func set_resolution(res: Vector2):
	var root = get_tree().root
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	
	k = Vector2(res) / real_size
	root.content_scale_size = res
	
	# emit signal to update font sizes
	resolution_changed.emit(res)

func is_analytics():
	return false
