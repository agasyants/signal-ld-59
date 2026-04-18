extends Camera3D

@export var move_speed : float = 10.0
@export var sprint_speed : float = 20.0
@export var mouse_sensitivity : float = 0.002
@export var acceleration : float = 8.0
@export var friction : float = 10.0

var velocity : Vector3 = Vector3.ZERO
var current_speed : float

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		rotate_x(-event.relative.y * mouse_sensitivity)
		rotation.x = clamp(rotation.x, -1.57, 1.57)

func _process(delta):
	# Выбор скорости (спринт по Shift)
	current_speed = sprint_speed if Input.is_key_pressed(KEY_SHIFT) else move_speed
	
	# Получение ввода
	var input_dir = Vector3()
	var camera_basis = global_transform.basis
	
	if Input.is_key_pressed(KEY_W):
		input_dir -= camera_basis.z
	if Input.is_key_pressed(KEY_S):
		input_dir += camera_basis.z
	if Input.is_key_pressed(KEY_A):
		input_dir -= camera_basis.x
	if Input.is_key_pressed(KEY_D):
		input_dir += camera_basis.x
	if Input.is_key_pressed(KEY_Q):
		input_dir.y -= 1
	if Input.is_key_pressed(KEY_E):
		input_dir.y += 1
	
	input_dir = input_dir.normalized()
	
	# Движение с ускорением
	var target_velocity = input_dir * current_speed
	
	if input_dir != Vector3.ZERO:
		velocity = velocity.lerp(target_velocity, acceleration * delta)
	else:
		velocity = velocity.lerp(Vector3.ZERO, friction * delta)
	
	global_translate(velocity * delta)
	
	# ESC для выхода
	if Input.is_key_pressed(KEY_ESCAPE):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Клик для захвата мыши
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
