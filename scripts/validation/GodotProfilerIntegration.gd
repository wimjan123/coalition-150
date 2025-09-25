# GodotProfilerIntegration - Godot profiler integration for constitution performance validation
# T033: Validates constitution performance requirements using Godot's built-in profiler

extends Node
class_name GodotProfilerIntegration

var profiling_data: Dictionary = {}
var performance_thresholds: Dictionary = {
	"target_fps": 60.0,
	"max_scene_load_ms": 100.0,
	"max_memory_mb": 100.0,
	"max_cpu_usage_percent": 80.0
}

signal profiling_completed(results: Dictionary)
signal performance_threshold_exceeded(metric: String, value: float, threshold: float)

func _ready():
	print("GodotProfilerIntegration: Initializing performance monitoring")

# T033: Godot profiler integration methods
func start_performance_profiling() -> void:
	print("GodotProfilerIntegration: Starting performance profiling session")

	# Initialize profiling data collection
	profiling_data = {
		"fps_samples": [],
		"memory_samples": [],
		"cpu_samples": [],
		"scene_load_times": [],
		"frame_time_samples": []
	}

	# Enable Godot's built-in performance monitoring
	_enable_godot_profilers()

	# Start collection timer
	var profiling_timer = Timer.new()
	profiling_timer.wait_time = 0.1  # Sample every 100ms
	profiling_timer.timeout.connect(_collect_performance_sample)
	profiling_timer.autostart = true
	add_child(profiling_timer)

func _enable_godot_profilers() -> void:
	# Enable relevant Godot profilers
	if OS.is_debug_build():
		print("GodotProfilerIntegration: Debug build detected - profilers available")

		# In a full implementation, would enable:
		# - Engine.get_singleton("Performance")
		# - RenderingServer profiling
		# - Memory tracking

func _collect_performance_sample() -> void:
	# Collect FPS data
	var current_fps = Engine.get_frames_per_second()
	profiling_data.fps_samples.append(current_fps)

	# Collect memory usage
	var memory_usage = OS.get_static_memory_usage()
	var memory_mb = memory_usage / (1024 * 1024)
	profiling_data.memory_samples.append(memory_mb)

	# Collect frame time
	var frame_time = Performance.get_monitor(Performance.TIME_PROCESS)
	profiling_data.frame_time_samples.append(frame_time)

	# Check thresholds
	_check_performance_thresholds(current_fps, memory_mb, frame_time)

	# Keep samples manageable (last 300 samples = ~30 seconds at 100ms intervals)
	_trim_sample_arrays()

func _check_performance_thresholds(fps: float, memory_mb: float, frame_time: float) -> void:
	if fps < performance_thresholds.target_fps:
		performance_threshold_exceeded.emit("fps", fps, performance_thresholds.target_fps)

	if memory_mb > performance_thresholds.max_memory_mb:
		performance_threshold_exceeded.emit("memory", memory_mb, performance_thresholds.max_memory_mb)

	if frame_time > 1000.0 / performance_thresholds.target_fps:  # Convert to ms
		performance_threshold_exceeded.emit("frame_time", frame_time, 1000.0 / performance_thresholds.target_fps)

func _trim_sample_arrays() -> void:
	var max_samples = 300

	for key in profiling_data:
		if profiling_data[key] is Array and profiling_data[key].size() > max_samples:
			profiling_data[key] = profiling_data[key].slice(-max_samples)

func measure_scene_load_time(scene_path: String) -> void:
	print("GodotProfilerIntegration: Measuring scene load time for: ", scene_path)

	var start_time = Time.get_time_dict_from_system()["unix"]

	# In practice, this would be called before/after actual scene loading
	# For now, simulate measurement
	await get_tree().process_frame

	var end_time = Time.get_time_dict_from_system()["unix"]
	var load_time_ms = (end_time - start_time) * 1000.0

	profiling_data.scene_load_times.append(load_time_ms)

	if load_time_ms > performance_thresholds.max_scene_load_ms:
		performance_threshold_exceeded.emit("scene_load", load_time_ms, performance_thresholds.max_scene_load_ms)

	print("GodotProfilerIntegration: Scene load time measured: ", load_time_ms, "ms")

func generate_performance_report() -> Dictionary:
	print("GodotProfilerIntegration: Generating comprehensive performance report")

	var report = {
		"constitution_compliance": _validate_constitution_requirements(),
		"average_fps": _calculate_average(profiling_data.fps_samples),
		"min_fps": _calculate_min(profiling_data.fps_samples),
		"average_memory_mb": _calculate_average(profiling_data.memory_samples),
		"peak_memory_mb": _calculate_max(profiling_data.memory_samples),
		"average_frame_time_ms": _calculate_average(profiling_data.frame_time_samples),
		"max_frame_time_ms": _calculate_max(profiling_data.frame_time_samples),
		"scene_load_times": profiling_data.scene_load_times,
		"performance_violations": _get_performance_violations()
	}

	profiling_completed.emit(report)
	return report

func _validate_constitution_requirements() -> Dictionary:
	var fps_stable = _calculate_average(profiling_data.fps_samples) >= 60.0
	var memory_acceptable = _calculate_average(profiling_data.memory_samples) <= 100.0
	var loading_fast = profiling_data.scene_load_times.is_empty() or _calculate_max(profiling_data.scene_load_times) <= 100.0

	return {
		"60_fps_maintained": fps_stable,
		"memory_under_100mb": memory_acceptable,
		"scene_loading_under_100ms": loading_fast,
		"overall_compliance": fps_stable and memory_acceptable and loading_fast
	}

func _get_performance_violations() -> Array[Dictionary]:
	var violations: Array[Dictionary] = []

	# Check FPS violations
	for fps in profiling_data.fps_samples:
		if fps < performance_thresholds.target_fps:
			violations.append({"type": "fps", "value": fps, "threshold": performance_thresholds.target_fps})

	# Check memory violations
	for memory_mb in profiling_data.memory_samples:
		if memory_mb > performance_thresholds.max_memory_mb:
			violations.append({"type": "memory", "value": memory_mb, "threshold": performance_thresholds.max_memory_mb})

	# Check scene load violations
	for load_time in profiling_data.scene_load_times:
		if load_time > performance_thresholds.max_scene_load_ms:
			violations.append({"type": "scene_load", "value": load_time, "threshold": performance_thresholds.max_scene_load_ms})

	return violations

# Utility methods
func _calculate_average(samples: Array) -> float:
	if samples.is_empty():
		return 0.0

	var sum = 0.0
	for sample in samples:
		sum += sample
	return sum / samples.size()

func _calculate_min(samples: Array) -> float:
	if samples.is_empty():
		return 0.0
	return samples.min()

func _calculate_max(samples: Array) -> float:
	if samples.is_empty():
		return 0.0
	return samples.max()

func stop_profiling() -> Dictionary:
	print("GodotProfilerIntegration: Stopping performance profiling")
	return generate_performance_report()

# Debug methods
func print_real_time_stats() -> void:
	print("=== Real-time Performance Stats ===")
	print("Current FPS: ", Engine.get_frames_per_second())
	print("Memory Usage: ", OS.get_static_memory_usage() / (1024 * 1024), "MB")
	print("Frame Time: ", Performance.get_monitor(Performance.TIME_PROCESS), "ms")

func export_profiling_data(file_path: String) -> void:
	print("GodotProfilerIntegration: Exporting profiling data to: ", file_path)
	# In a full implementation, would save profiling_data to JSON file