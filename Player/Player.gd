extends Node3D
class_name Player
@export var rotate_speed: float = 3.8
@export var tunnel_radius := 1.7
@export var inertia_friction: float = 10.0
@export var inertia_strength: float = 4.6
@export var health: int = 3
@export var coins: int = 0
var angular_velocity: float = 0.0
var current_angle: float = 0.0
var radial_velocity: float = 0.0
var current_radius: float
@export var gravity: float = 15.0
@export var jump_cut_multiplier: float = 0.8
var is_jumping: bool = false
@onready var camera: Camera3D = $Camera3D
@onready var shader := $Camera3D/CanvasLayer/ColorRect
@onready var death_menu := $Camera3D/CanvasLayer/DeathMenu
@onready var health_label := $Camera3D/CanvasLayer/HealthLabel
@onready var coin_label := $Camera3D/CanvasLayer/CoinLabel
@onready var move_sound: AudioStreamPlayer = $MoveSound

func _ready():
	# Инициализация параметров из глобального состояния
	health = GameGraph.health
	coins = 0
	
	if move_sound and move_sound.stream is AudioStreamWAV:
		move_sound.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	
	if move_sound:
		move_sound.play()
	
	shader.trigger_hit()
	add_to_group("player")
	current_radius = tunnel_radius
	_update_health_ui()
	_update_coins_ui()
	var area = Area3D.new()
	add_child(area)
	var shape = CollisionShape3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = 0.1
	shape.shape = sphere
	area.add_child(shape)

@export var turn_responsiveness: float = 5 # Множитель "резкости" разворота

func _process(delta):
	var input = Input.get_axis("ui_left", "ui_right")
	var max_velocity = rotate_speed * 1.5
	
	if input != 0:
		var turn_factor = 1.0
		
		# Проверяем, меняет ли игрок направление (знаки разные)
		# abs > 0.1 нужно, чтобы не срабатывало, когда скорость около нуля
		if sign(angular_velocity) != sign(input) and abs(angular_velocity) > 0.1:
			turn_factor = turn_responsiveness
			
		# Умножаем ускорение на этот фактор
		angular_velocity += input * rotate_speed * inertia_strength * turn_factor * delta
	else:
		# Стандартное затухание
		angular_velocity = lerp(angular_velocity, 0.0, inertia_friction * delta)
		
	angular_velocity = clamp(angular_velocity, -max_velocity, max_velocity)
	current_angle += angular_velocity * delta

	# --- ЗВУК ДВИЖЕНИЯ ---
	if move_sound:
		var target_pitch = 1.1 + abs(angular_velocity) * 0.1
		move_sound.pitch_scale = lerp(move_sound.pitch_scale, target_pitch, 5.0 * delta)
		
		# Немного увеличиваем громкость при движении
		var target_vol = -17.0 + abs(angular_velocity) * 2.0
		move_sound.volume_db = lerp(move_sound.volume_db, target_vol, 5.0 * delta)

	# --- ПРЫЖОК ---
	if Input.is_action_just_pressed("Jump") and is_on_ground():
		radial_velocity = tunnel_radius * 4
		is_jumping = true

	# Отпустили кнопку раньше — срезаем скорость вверх
	if is_jumping and Input.is_action_just_released("Jump"):
		if radial_velocity > 0:
			radial_velocity *= jump_cut_multiplier
		is_jumping = false

	# --- ГРАВИТАЦИЯ К СТЕНКЕ ---
	radial_velocity -= gravity * delta
	current_radius -= radial_velocity * delta

	# --- СТОЛКНОВЕНИЕ СО СТЕНКОЙ ---
	if current_radius >= tunnel_radius:
		current_radius = tunnel_radius
		radial_velocity = 0.0
		is_jumping = false

	# --- ПОЗИЦИЯ И ОРИЕНТАЦИЯ ---
	position.x = cos(current_angle) * current_radius
	position.y = sin(current_angle) * current_radius
	var to_center = Vector2(position.x, position.y)
	rotation.z = atan2(to_center.y, to_center.x) + PI / 2.0

func is_on_ground() -> bool:
	return current_radius >= tunnel_radius - 0.01

var tween: Tween
@onready var hit_sound: AudioStreamPlayer = $HitSound
@onready var bonus_sound: AudioStreamPlayer = $BonusSound

func take_damage(delta: int):
	if delta < 0: # Damage
		if GameGraph.coins > 0:
			GameGraph.coins -= 1
			show_popup_info("-1 COIN", Color.ORANGE_RED)
		_update_coins_ui()
	
	health += delta
	GameGraph.health = health # Синхронизируем с глобальным состоянием
	_update_health_ui()
	if health <= 0:
		print('end')
		shader.trigger_hit()
		apply_hit_stop()
		death_menu.show_death_screen()
		var root = get_tree().current_scene
		hit_sound.pitch_scale = 0.5
		hit_sound.play()
		if root.has_method("player_died"):
			root.player_died()
	else:
		hit_sound.pitch_scale = randf_range(0.9, 1.1)
		hit_sound.play()
		shader.trigger_hit()
		apply_hit_stop()
	if tween:
		tween.kill()
	tween = create_tween().set_parallel(true)
	tween.tween_property(Engine, "time_scale", 1.0, 3.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func apply_hit_stop(time_scale: float = 0.06, duration: float = 0.1):
	Engine.time_scale = time_scale
	await get_tree().create_timer(duration * time_scale).timeout
	Engine.time_scale = 0.5

func _update_health_ui():
	var heart_text = ""
	for i in range(max(0, health)):
		heart_text += "♥️"
	
	if health >= 5:
		heart_text += " MAX"
	
	health_label.text = heart_text

func _update_coins_ui():
	if coin_label:
		# Показываем ОБЩЕЕ количество монет (уже собранные + текущий уровень)
		coin_label.text = "COINS: %d" % (GameGraph.coins + coins)

func apply_bonus(type: Bonus.BonusType) -> void:
	bonus_sound.play()
	match type:
		Bonus.BonusType.HEALTH:
			if health >= 5:
				show_popup_info("HEALTH MAX", Color.ORANGE)
			else:
				health = min(health + 1, 5)
				GameGraph.health = health # Синхронизируем
				_update_health_ui()
				show_popup_info("+♥️", Color.RED)
			# Ускорение — через рут сцену
			var root = get_tree().current_scene
			if root.has_method("set_speed_boost"):
				root.set_speed_boost(1.4, 5.0) # множитель, длительность

		Bonus.BonusType.COIN:
			coins += 1
			_update_coins_ui()
			show_popup_info("+1 COIN", Color.GOLD)

		Bonus.BonusType.SLOW:
			_apply_slow()

func _apply_slow(scal: float = 0.6, duration: float = 8.0) -> void:
	if tween:
		tween.kill()
	Engine.time_scale = scal
	tween = create_tween().set_parallel(true)
	tween.tween_property(Engine, "time_scale", 1.0, duration) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func show_popup_info(text: String, color: Color):
	var label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Style
	label.add_theme_font_size_override("font_size", 64)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 12)
	
	# Add to HUD layer
	var hud_layer = $Camera3D/CanvasLayer
	hud_layer.add_child(label)
	
	# Center it
	var screen_size = get_viewport().get_visible_rect().size
	label.custom_minimum_size = Vector2(400, 100)
	label.position = (screen_size - label.custom_minimum_size) / 2.0
	label.pivot_offset = label.custom_minimum_size / 2.0
	
	# Animation
	label.scale = Vector2.ZERO
	label.modulate.a = 1.0
	
	var ptween = create_tween().set_parallel(false)
	# Pop in
	ptween.tween_property(label, "scale", Vector2.ONE * 1.2, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	ptween.tween_property(label, "scale", Vector2.ONE, 0.1)
	# Wait
	ptween.tween_interval(0.6)
	# Fade and float up
	var drift_tween = create_tween().set_parallel(true)
	drift_tween.tween_property(label, "modulate:a", 0.0, 0.4)
	drift_tween.tween_property(label, "position:y", label.position.y - 150, 0.4)
	drift_tween.finished.connect(label.queue_free)
