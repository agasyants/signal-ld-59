# debug_hud.gd
extends CanvasLayer

var _generator: TunnelGenerator
var _track_player: TrackPlayer
var _player: Node3D
var _label: RichTextLabel

func setup(gen: TunnelGenerator, tp: TrackPlayer, p: Node3D) -> void:
	_generator = gen
	_track_player = tp
	_player = p

func _ready() -> void:
	_label = RichTextLabel.new()
	_label.bbcode_enabled = true
	_label.fit_content = true
	_label.position = Vector2(10, 10)
	_label.size = Vector2(340, 600)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_label)

func _process(_delta: float) -> void:
	if not _generator or not _track_player:
		return

	var p := _track_player.current_params
	var elapsed := _track_player.elapsed
	var duration := _track_player.track.get_duration()
	var progress_pct := clampf(elapsed / duration * 100.0, 0.0, 100.0)
	var baked_len := _generator.curve.get_baked_length() if _generator.curve else 0.0
	var follow_progress := _generator._follow.progress if _generator._follow else 0.0
	var dist_pct := clampf(follow_progress / baked_len * 100.0, 0.0, 100.0) if baked_len > 0.0 else 0.0
	var t := clampf(follow_progress / baked_len, 0.0, 1.0) if baked_len > 0.0 else 0.0
	var current_radius := _generator.get_radius_at_t(t)

	var health_str := ""
	if _player and "health" in _player:
		health_str = "[b]Health:[/b] %d\n" % _player.health

	_label.text = (
		"[color=#00f5ff][b]═══ DEBUG HUD ═══[/b][/color]\n"
		+ "\n[color=#aaffaa][b]── TRACK ──[/b][/color]\n"
		+ "[b]Track:[/b] %s\n" % _track_player.track.track_name
		+ "[b]Time:[/b] %.1fs / %.1fs\n" % [elapsed, duration]
		+ "[b]Track progress:[/b] %.1f%%\n" % progress_pct
		+ "[b]Distance:[/b] %.1fm / %.1fm (%.1f%%)\n" % [follow_progress, baked_len, dist_pct]
		+ "\n[color=#aaffaa][b]── SESSION ──[/b][/color]\n"
		+ "[b]Speed:[/b] %.1f u/s\n" % _generator._current_speed
		+ "[b]Difficulty:[/b] %.2f\n" % p.get("difficulty", 0.0)
		+ "[b]Density:[/b] %.2f\n" % p.get("density", 0.0)
		+ "\n[color=#aaffaa][b]── TUNNEL ──[/b][/color]\n"
		+ "[b]Radius (current):[/b] %.2f\n" % current_radius
		+ "\n[color=#aaffaa][b]── PLAYER ──[/b][/color]\n"
		+ health_str
		+ "\n[color=#aaffaa][b]── OBSTACLES ──[/b][/color]\n"
		+ "[b]Types:[/b] %s\n" % _obstacle_types_str(p.get("obstacle_types", 0))
		+ "[b]Rotating:[/b] %s\n" % str(p.get("allow_rotating", false))
		+ "[b]Sliding:[/b] %s\n" % str(p.get("allow_sliding", false))
		+ "[b]Bonuses:[/b] %s\n" % _bonus_types_str(p.get("bonus_types", 0))
	)

func _obstacle_types_str(mask: int) -> String:
	var types: Array[String] = []
	if mask & 1: types.append("Wall")
	if mask & 2: types.append("Pillar")
	if mask & 4: types.append("Ring")
	return ", ".join(types) if not types.is_empty() else "none"

func _bonus_types_str(mask: int) -> String:
	var types: Array[String] = []
	if mask & 1: types.append("Health")
	if mask & 2: types.append("Shield")
	if mask & 4: types.append("Slow")
	return ", ".join(types) if not types.is_empty() else "none"
