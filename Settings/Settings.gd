extends Node

var CONFIG = {
	"graphics": {
		"render_resolution": {
			"label": "Resolution",
			"type": "option",
			"options": ["360p", "480p", "720p", "fullhd", "native"]
		},
		"aa": {
			"label": "GPU Antialising",
			"type": "option",
			"options": ["off", "on"]
		},
		"target_fps": {
			"label": "FPS Cap",
			"type": "option",
			"options": ["30", "60", "240"],
		},
		"vsync_enabled": {
			"label": "VSync",
			"type": "checkbox"
		}
	},
	
	"gameplay": {
		"difficulty": {
			"label": "Difficulty",
			"type": "option",
			"options": ["easy", "normal", "hard"]
		},
		#"camera_shake": {
			#"label": "Camera Shake",
			#"type": "checkbox"
		#},
	},
	
	"controls": {
		#"mouse_sensitivity": {
			#"label": "Mouse Sensitivity",
			#"type": "range",
			#"min": 0.1,
			#"max": 5.0,
			#"step": 0.1
		#},
		#"invert_y_axis": {
			#"label": "Invert Y Axis",
			#"type": "checkbox"
		#}
	},
	
	"debug": {
		"shader": {
			"label": "Shader Debug",
			"type": "checkbox"
		},
		"diying": {
			"label": "Can You Die",
			"type": "checkbox"
		},
		"fps": {
			"label": "Show FPS",
			"type": "checkbox"
		},
		"state": {
			"label": "Show Player State",
			"type": "checkbox"
		},
	}
}

const DEFAULTS = {
	# Graphics
	"render_resolution": "native",
	"target_fps": "60",
	"vsync_enabled": true,
	"aa": "on",
	
	# Gameplay
	"difficulty": "normal",
	#"auto_aim": false,
	#"camera_shake": true,
	
	# Controls
	#"mouse_sensitivity": 1.0,
	#"invert_y_axis": false,
	
	# Debug
	"shader": false,
	"fps": false,
	"state": false,
	"diying": true,
}

var settings = DEFAULTS.duplicate(true)
var _loaded := false

var k
var real_size

func _ready():
	real_size = Vector2(get_tree().root.content_scale_size)
	load_settings()
	apply_settings()

func load_settings():
	var path = "user://settings.cfg"
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var text = file.get_as_text()
		var parsed = JSON.parse_string(text)
		if typeof(parsed) == TYPE_DICTIONARY:
			settings = DEFAULTS.duplicate(true)
			for key in parsed:
				if settings.has(key):
					settings[key] = parsed[key]
		print(settings)
	_loaded = true

func save_settings():
	var file = FileAccess.open("user://settings.cfg", FileAccess.WRITE)
	file.store_string(JSON.stringify(settings, "\t"))

func apply_settings():
	if not _loaded:
		return
	
	apply_graphics_settings()
	apply_gameplay_settings()
	apply_controls_settings()
	
func apply_graphics_settings():
	# FPS cap
	print(int(settings["target_fps"]))
	Engine.max_fps = int(settings["target_fps"])
	# VSync
	if settings["vsync_enabled"]:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

	var root = get_tree().root
	var render_size
	
	# Render resolution (requires viewport stretch mode)
	var res = settings["render_resolution"]
	match res:
		"360p":
			render_size = Vector2i(630, 360)
		"480p":
			render_size = Vector2i(854, 480)
		"720p":
			render_size = Vector2i(1280, 720)
		"fullhd":
			render_size = Vector2i(1920, 1080)
		"native":
			render_size = DisplayServer.screen_get_size()
		_:
			render_size = DisplayServer.screen_get_size()
	
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	
	k = Vector2(render_size) / real_size
	root.content_scale_size = render_size
	print(k)


func set_resolution(mode:String, ascpect:String):
	ProjectSettings.set_setting("display/window/stretch/mode", mode)
	ProjectSettings.set_setting("display/window/stretch/aspect", ascpect)

func apply_gameplay_settings():
	pass  # Здесь будет логика применения игровых настроек

func apply_controls_settings():
	pass  # Здесь будет логика применения настроек управления

func get_setting(key: String):
	return settings[key]

func is_analytics():
	return false
