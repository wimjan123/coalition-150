# PerformanceValidator - Validates 60 FPS and <100ms scene loading requirements
# T031: Performance validation implementation

extends Node
class_name PerformanceValidator

var fps_samples: Array[float] = []
var scene_load_times: Array[float] = []
var memory_usage_samples: Array[float] = []

signal performance_issue_detected(issue_type: String, value: float)
signal performance_validation_passed()

func _ready():
	set_process(true)

func _process(_delta: float) -> void:
	_collect_fps_sample()
	_collect_memory_sample()

# T031: Performance validation methods
func validate_fps_requirement() -> bool:
	var current_fps = Engine.get_frames_per_second()
	fps_samples.append(current_fps)

	# Keep only recent samples (last 60 samples = ~1 second)
	if fps_samples.size() > 60:
		fps_samples.pop_front()

	var average_fps = _calculate_average(fps_samples)

	if average_fps < 60.0:
		performance_issue_detected.emit("fps", average_fps)
		print("PerformanceValidator: FPS below 60: ", average_fps)
		return false

	return true

func validate_scene_loading_time(start_time: float, end_time: float) -> bool:
	var load_time_ms = (end_time - start_time) * 1000.0
	scene_load_times.append(load_time_ms)

	print("PerformanceValidator: Scene load time: ", load_time_ms, "ms")

	if load_time_ms > 100.0:
		performance_issue_detected.emit("scene_load", load_time_ms)
		print("PerformanceValidator: Scene loading exceeded 100ms: ", load_time_ms)
		return false

	return true

func validate_memory_usage() -> bool:
	var memory_mb = OS.get_static_memory_usage() / (1024 * 1024)

	if memory_mb > 200.0:  # Conservative limit
		performance_issue_detected.emit("memory", memory_mb)
		print("PerformanceValidator: Memory usage high: ", memory_mb, "MB")
		return false

	return true

func _collect_fps_sample() -> void:
	validate_fps_requirement()

func _collect_memory_sample() -> void:
	validate_memory_usage()

func _calculate_average(samples: Array[float]) -> float:
	if samples.is_empty():
		return 0.0

	var sum = 0.0
	for sample in samples:
		sum += sample
	return sum / samples.size()

func get_performance_report() -> Dictionary:
	return {
		"average_fps": _calculate_average(fps_samples),
		"average_scene_load_ms": _calculate_average(scene_load_times),
		"current_memory_mb": OS.get_static_memory_usage() / (1024 * 1024),
		"fps_stable": _calculate_average(fps_samples) >= 60.0,
		"scene_loading_fast": scene_load_times.is_empty() or scene_load_times.max() <= 100.0
	}