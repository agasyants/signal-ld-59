# track_data.gd
class_name TrackData
extends Resource

@export var track_name: String = ""
@export var music: AudioStream
# 0 = брать из длины аудио автоматически
@export var total_duration: float = 0.0

@export var sections: Array[TrackSection] = []

func get_duration() -> float:
	if total_duration > 0.0:
		return total_duration
	if music:
		return music.get_length()
	return 120.0

# Вычисляет примерную длину трассы в метрах исходя из скорости по секциям
func get_total_length(session_speed: float) -> float:
	if sections.is_empty():
		return session_speed * get_duration()
	var length = 0.0
	var duration = get_duration()
	for i in range(sections.size()):
		var a = sections[i]
		var t_start = a.time
		var t_end = duration if i == sections.size() - 1 else sections[i + 1].time
		var dt = t_end - t_start
		var avg_k = (a.speed_curve.x + a.speed_curve.y) * 0.5
		length += dt * session_speed * avg_k
	return length

# Вычисляет время, в которое игрок окажется на заданном расстоянии от старта
func get_time_at_dist(target_dist: float, session_speed: float) -> float:
	if sections.is_empty():
		return target_dist / session_speed
	
	var current_dist = 0.0
	var duration = get_duration()
	
	for i in range(sections.size()):
		var a = sections[i]
		var t_start = a.time
		var t_end = duration if i == sections.size() - 1 else sections[i + 1].time
		var dt = t_end - t_start
		var avg_k = (a.speed_curve.x + a.speed_curve.y) * 0.5
		var section_len = dt * session_speed * avg_k
		
		if current_dist + section_len >= target_dist:
			var remaining_dist = target_dist - current_dist
			var speed_in_section = session_speed * avg_k
			return t_start + (remaining_dist / speed_in_section if speed_in_section > 0 else 0.0)
		
		current_dist += section_len
	
	return duration
