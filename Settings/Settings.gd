extends Node

var k = Vector2(1, 1)
var real_size

func _ready():
	real_size = Vector2(get_tree().root.content_scale_size)
	var render_size = DisplayServer.screen_get_size()
	
	var root = get_tree().root
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	
	k = Vector2(render_size) / real_size
	root.content_scale_size = render_size

func is_analytics():
	return false
