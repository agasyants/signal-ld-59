extends Node3D
class_name Player

@export var rotate_speed: float = 3.5
@export var tunnel_radius := 1.7
@export var inertia_friction: float = 5.0
@export var inertia_strength: float = 4.0
@export var free_move_speed: float = 5.0

@export var health: int = 3

var angular_velocity: float = 0.0
var current_angle: float = 0.0

var free_control: bool = false   # режим свободного полёта (Alt)

# радиальное движение (прыжок)
var radial_velocity: float = 0.0
var current_radius: float
@export var gravity: float = 20.0
@export var jump_force: float = 8.0

@onready var camera: Camera3D = $Camera3D
@onready var shader := $Camera3D/CanvasLayer/ColorRect
@onready var death_menu := $Camera3D/CanvasLayer/DeathMenu
@onready var health_label := $Camera3D/CanvasLayer/HealthLabel


func _ready():
	shader.trigger_hit()
	add_to_group("player")
	_update_health_ui()
	
	var area = Area3D.new()
	add_child(area)
	
	var shape = CollisionShape3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = 0.1
	shape.shape = sphere
	area.add_child(shape)


func _process(delta):
	var alt_pressed = Input.is_key_pressed(KEY_ALT)
	
	if alt_pressed and not free_control:
		# Переключились в свободный режим
		free_control = true
		angular_velocity = 0.0  # сбрасываем инерцию вращения
	elif not alt_pressed and free_control:
		# Вернулись к орбитальному движению – проецируем игрока на окружность
		free_control = false
		var angle = atan2(position.y, position.x)
		current_angle = angle
		position.x = cos(angle) * tunnel_radius
		position.y = sin(angle) * tunnel_radius
		angular_velocity = 0.0
	
	if free_control:
		# --- СВОБОДНОЕ УПРАВЛЕНИЕ WASD ---
		# Получаем ввод с клавиш W, A, S, D
		var input := Vector2(
			Input.get_axis("ui_left", "ui_right"),
			Input.get_axis("ui_down", "ui_up")
		)

		if input.length() > 0.0:
			input = input.normalized()

		# поворачиваем input в сторону взгляда игрока
		var rotated_input = input.rotated(rotation.z)
		
		var move_delta = rotated_input * free_move_speed * delta
		position.x += move_delta.x
		position.y += move_delta.y
		
		# Ограничиваем радиус – нельзя выходить за пределы туннеля
		current_radius = Vector2(position.x, position.y).length()
		if current_radius > tunnel_radius:
			var limited_pos = Vector2(position.x, position.y).normalized() * tunnel_radius
			position.x = limited_pos.x
			position.y = limited_pos.y
		
		# Обновляем угол для правильной ориентации (но current_angle не используется в движении)
		# Поворот игрока всегда вдоль касательной к окружности
	else:
		# --- ОРБИТАЛЬНОЕ ДВИЖЕНИЕ (СТРЕЛКИ) ---
		var input = Input.get_axis("ui_left", "ui_right")
		
		if input != 0:
			angular_velocity += input * rotate_speed * inertia_strength * delta
		else:
			angular_velocity = lerp(angular_velocity, 0.0, inertia_friction * delta)
		
		var max_velocity = rotate_speed * 1.5
		angular_velocity = clamp(angular_velocity, -max_velocity, max_velocity)
		
		current_angle += angular_velocity * delta
		
		position.x = cos(current_angle) * tunnel_radius * 0.8
		position.y = sin(current_angle) * tunnel_radius * 0.8
	
		var to_center = Vector2(position.x, position.y)
		rotation.z = atan2(to_center.y, to_center.x) + PI / 2.0
		# --- ПРЫЖОК ---
		if Input.is_action_just_pressed("Jump") and is_on_ground():
			radial_velocity = jump_force

		# --- ГРАВИТАЦИЯ К ЦЕНТРУ ---
		radial_velocity -= gravity * delta
		current_radius -= radial_velocity * delta

		# --- СТОЛКНОВЕНИЕ СО СТЕНКОЙ ---
		if current_radius >= tunnel_radius:
			current_radius = tunnel_radius
			radial_velocity = 0.0

		# позиция
		position.x = cos(current_angle) * current_radius
		position.y = sin(current_angle) * current_radius


func is_on_ground() -> bool:
	print(current_radius, tunnel_radius)
	return current_radius >= tunnel_radius - 0.01

var tween: Tween

func take_damage(delta: int):
	health += delta
	_update_health_ui()
	if health <= 0:
		print('end')
		shader.trigger_hit()
		apply_hit_stop()
		death_menu.show_death_screen()
		var root = get_tree().current_scene
		if root.has_method("player_died"):
			root.player_died()
	else:
		shader.trigger_hit()
		apply_hit_stop()
	if tween:
		tween.kill()
	
	# Создаем новый твин
	tween = create_tween().set_parallel(true)
	
	# Плавный возврат в ноль за duration
	tween.tween_property(Engine, "time_scale", 1.0, 3.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


var noise = FastNoiseLite.new()
var noise_y = 0.0

func apply_hit_stop(time_scale: float = 0.06, duration: float = 0.08):
	Engine.time_scale = time_scale
	await get_tree().create_timer(duration * time_scale).timeout # Учитываем замедление
	Engine.time_scale = 0.5

func _update_health_ui():
	var heart_text = ""
	for i in range(max(0, health)):
		heart_text += "❤"
	health_label.text = heart_text
