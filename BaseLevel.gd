# level.gd
# Прикрепить к корневому узлу level.tscn
extends Node3D

@export var player_scene: PackedScene
@export var fallback_track: TrackData  # используется если у connection нет track

var _generator: TunnelGenerator
var _elapsed: float = 0.0
var _connection: MyGraphConnection

func _ready() -> void:
	_connection = GameGraph.current_connection
	assert(_connection != null, "Level: GameState.current_connection не задан")

	var track := _connection.track if _connection.track else fallback_track
	assert(track != null, "Level: нет TrackData ни в connection, ни в fallback_track")

	_generator = TunnelGenerator.new()
	_generator.track = track
	_generator.player_scene = player_scene
	add_child(_generator)
	_generator.generate_from_session(_connection.session)

	# Слушаем окончание трека
	_generator.track_finished.connect(_on_track_finished)

	# HUD
	var hud := preload("res://debug_hud.gd").new()
	add_child(hud)
	hud.setup(_generator, _generator._track_player, _generator.player)

func _process(delta: float) -> void:
	_elapsed += delta

func _on_track_finished() -> void:
	var coins_collected = 0
	if _generator and _generator.player:
		coins_collected = _generator.player.coins
		
	GameGraph.finish_level(true, {
		"score": _calculate_score(),
		"time":  _elapsed,
		"coins": coins_collected,
	})

func _calculate_score() -> int:
	# Базовый счёт за прохождение + бонус за сложность
	return int(1000.0 * _connection.complexity)

# Вызывается если игрок умер
func player_died() -> void:
	# Просто сохраняем состояние, но сцену не меняем — это сделает кнопка на экране смерти
	print("Level: Player died, waiting for interaction")
