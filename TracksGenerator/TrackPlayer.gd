# track_player.gd
class_name TrackPlayer
extends Node

signal params_changed(params: Dictionary)
signal track_finished

var track: TrackData
var session: Dictionary

var is_playing: bool = false
var elapsed: float = 0.0
var current_params: Dictionary = {}

var _sampler: TrackSampler
var _audio: AudioStreamPlayer

func setup(t: TrackData, s: Dictionary) -> void:
	track = t
	session = s
	_sampler = TrackSampler.new()
	_sampler.setup(track, session, session.get("seed", 0))

func start() -> void:
	# Аудио
	_audio = AudioStreamPlayer.new()
	add_child(_audio)
	_audio.stream = track.music
	_audio.play()
	is_playing = true

func stop() -> void:
	is_playing = false
	if _audio:
		_audio.stop()

func _process(delta: float) -> void:
	if not is_playing or _audio == null:
		return

	# delta уже масштабирован — elapsed идёт в игровом времени
	elapsed += delta
	_audio.pitch_scale = Engine.time_scale

	var duration := track.get_duration()
	if elapsed >= duration:
		is_playing = false
		track_finished.emit()
		return

	current_params = _sampler.sample(elapsed)
	params_changed.emit(current_params)

func get_current_params() -> Dictionary:
	return current_params
