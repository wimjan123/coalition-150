# Performance Validator - Validates 60 FPS and <100ms scene transition requirements
# Validates system performance against Coalition 150 constitutional requirements

class_name PerformanceValidator
extends RefCounted

# Performance Requirements Constants
const TARGET_FPS: float = 60.0
const MAX_FRAME_TIME_MS: float = 16.67  # 1000ms / 60fps
const MAX_SCENE_TRANSITION_MS: float = 100.0
const MAX_UI_RESPONSE_MS: float = 16.0

# Performance Metrics
var performance_results: Dictionary = {}
var validation_passed: bool = false

signal performance_test_completed(results: Dictionary)

func _init():
	performance_results = {
		"fps_tests": [],
		"transition_tests": [],
		"ui_response_tests": [],
		"overall_passed": false,
		"timestamp": Time.get_datetime_string_from_system()
	}

# Main Validation Function
func validate_system_performance() -> Dictionary:
	print("Starting performance validation...")

	# Test 1: FPS Performance
	await _test_fps_performance()

	# Test 2: Scene Transition Performance
	await _test_scene_transition_performance()

	# Test 3: UI Responsiveness
	await _test_ui_responsiveness()

	# Evaluate overall results
	_evaluate_overall_performance()

	performance_test_completed.emit(performance_results)
	return performance_results

# FPS Performance Tests
func _test_fps_performance() -> void:
	print("Testing FPS performance...")

	var fps_tests: Array = []

	# Test 1: Idle FPS (baseline)
	var idle_fps: float = await _measure_idle_fps()
	fps_tests.append({
		"test_name": "Idle FPS",
		"measured_fps": idle_fps,
		"target_fps": TARGET_FPS,
		"passed": idle_fps >= TARGET_FPS,
		"notes": "Baseline FPS with minimal load"
	})

	# Test 2: Scene Rendering FPS
	var scene_fps: float = await _measure_scene_rendering_fps()
	fps_tests.append({
		"test_name": "Scene Rendering FPS",
		"measured_fps": scene_fps,
		"target_fps": TARGET_FPS,
		"passed": scene_fps >= TARGET_FPS,
		"notes": "FPS during active scene rendering"
	})

	# Test 3: UI Interaction FPS
	var ui_fps: float = await _measure_ui_interaction_fps()
	fps_tests.append({
		"test_name": "UI Interaction FPS",
		"measured_fps": ui_fps,
		"target_fps": TARGET_FPS,
		"passed": ui_fps >= TARGET_FPS,
		"notes": "FPS during UI interactions"
	})

	performance_results["fps_tests"] = fps_tests
	print("FPS testing completed")

func _measure_idle_fps() -> float:
	var frame_count: int = 0
	var start_time: float = Time.get_ticks_msec()
	var test_duration_ms: float = 1000.0  # 1 second

	while Time.get_ticks_msec() - start_time < test_duration_ms:
		await Engine.get_main_loop().process_frame
		frame_count += 1

	var elapsed_time: float = (Time.get_ticks_msec() - start_time) / 1000.0
	return frame_count / elapsed_time

func _measure_scene_rendering_fps() -> float:
	# Create a test scene with typical UI elements
	var test_scene: Control = Control.new()
	var container: VBoxContainer = VBoxContainer.new()

	# Add typical UI elements
	for i in range(10):
		var button: Button = Button.new()
		button.text = "Test Button " + str(i)
		container.add_child(button)

	test_scene.add_child(container)

	# Add to tree for rendering
	Engine.get_main_loop().current_scene.add_child(test_scene)

	# Measure FPS
	var frame_count: int = 0
	var start_time: float = Time.get_ticks_msec()
	var test_duration_ms: float = 1000.0

	while Time.get_ticks_msec() - start_time < test_duration_ms:
		await Engine.get_main_loop().process_frame
		frame_count += 1

	# Cleanup
	test_scene.queue_free()

	var elapsed_time: float = (Time.get_ticks_msec() - start_time) / 1000.0
	return frame_count / elapsed_time

func _measure_ui_interaction_fps() -> float:
	# Create interactive UI for testing
	var test_scene: Control = Control.new()
	var button: Button = Button.new()
	button.text = "Click Test"

	test_scene.add_child(button)
	Engine.get_main_loop().current_scene.add_child(test_scene)

	# Simulate UI interactions
	var frame_count: int = 0
	var start_time: float = Time.get_ticks_msec()
	var test_duration_ms: float = 1000.0

	while Time.get_ticks_msec() - start_time < test_duration_ms:
		# Simulate button interaction
		if frame_count % 10 == 0:
			button.grab_focus()

		await Engine.get_main_loop().process_frame
		frame_count += 1

	# Cleanup
	test_scene.queue_free()

	var elapsed_time: float = (Time.get_ticks_msec() - start_time) / 1000.0
	return frame_count / elapsed_time

# Scene Transition Performance Tests
func _test_scene_transition_performance() -> void:
	print("Testing scene transition performance...")

	var transition_tests: Array = []

	# Test each major scene transition
	var scene_pairs: Array = [
		{
			"from": "MainMenu",
			"to": "CharacterPartySelection",
			"scene_path": "res://scenes/player/CharacterPartySelection.tscn"
		},
		{
			"from": "CharacterPartySelection",
			"to": "CharacterPartyCreation",
			"scene_path": "res://scenes/player/CharacterPartyCreation.tscn"
		},
		{
			"from": "CharacterPartyCreation",
			"to": "MediaInterview",
			"scene_path": "res://scenes/player/MediaInterview.tscn"
		}
	]

	for scene_pair in scene_pairs:
		var transition_time: float = await _measure_scene_transition_time(scene_pair)
		transition_tests.append({
			"transition": scene_pair.from + " -> " + scene_pair.to,
			"measured_time_ms": transition_time,
			"target_time_ms": MAX_SCENE_TRANSITION_MS,
			"passed": transition_time <= MAX_SCENE_TRANSITION_MS,
			"notes": "Scene loading and initialization time"
		})

	performance_results["transition_tests"] = transition_tests
	print("Scene transition testing completed")

func _measure_scene_transition_time(scene_info: Dictionary) -> float:
	var start_time: float = Time.get_ticks_msec()

	# Load and instantiate scene
	var scene_resource: PackedScene = load(scene_info.scene_path)
	var scene_instance: Node = scene_resource.instantiate()

	# Add to tree (simulates actual transition)
	Engine.get_main_loop().current_scene.add_child(scene_instance)

	# Wait for ready signal
	await Engine.get_main_loop().process_frame

	var end_time: float = Time.get_ticks_msec()

	# Cleanup
	scene_instance.queue_free()

	return end_time - start_time

# UI Responsiveness Tests
func _test_ui_responsiveness() -> void:
	print("Testing UI responsiveness...")

	var ui_tests: Array = []

	# Test 1: Button Response Time
	var button_response: float = await _measure_button_response_time()
	ui_tests.append({
		"test_name": "Button Response Time",
		"measured_time_ms": button_response,
		"target_time_ms": MAX_UI_RESPONSE_MS,
		"passed": button_response <= MAX_UI_RESPONSE_MS,
		"notes": "Time from input to visual feedback"
	})

	# Test 2: Text Input Response
	var text_response: float = await _measure_text_input_response()
	ui_tests.append({
		"test_name": "Text Input Response",
		"measured_time_ms": text_response,
		"target_time_ms": MAX_UI_RESPONSE_MS,
		"passed": text_response <= MAX_UI_RESPONSE_MS,
		"notes": "Text input field responsiveness"
	})

	# Test 3: Color Picker Response
	var color_response: float = await _measure_color_picker_response()
	ui_tests.append({
		"test_name": "Color Picker Response",
		"measured_time_ms": color_response,
		"target_time_ms": MAX_UI_RESPONSE_MS * 2,  # More complex UI
		"passed": color_response <= MAX_UI_RESPONSE_MS * 2,
		"notes": "Color picker interaction responsiveness"
	})

	performance_results["ui_response_tests"] = ui_tests
	print("UI responsiveness testing completed")

func _measure_button_response_time() -> float:
	# Create test button
	var test_button: Button = Button.new()
	test_button.text = "Test Button"
	Engine.get_main_loop().current_scene.add_child(test_button)

	# Measure response time
	var start_time: float = Time.get_ticks_msec()

	# Simulate button press
	test_button.grab_focus()
	test_button.button_pressed = true
	await Engine.get_main_loop().process_frame
	test_button.button_pressed = false

	var end_time: float = Time.get_ticks_msec()

	# Cleanup
	test_button.queue_free()

	return end_time - start_time

func _measure_text_input_response() -> float:
	# Create test text field
	var test_field: LineEdit = LineEdit.new()
	test_field.placeholder_text = "Test Input"
	Engine.get_main_loop().current_scene.add_child(test_field)

	# Measure response time
	var start_time: float = Time.get_ticks_msec()

	# Simulate text input
	test_field.grab_focus()
	test_field.text = "Test"
	test_field.text_changed.emit("Test")
	await Engine.get_main_loop().process_frame

	var end_time: float = Time.get_ticks_msec()

	# Cleanup
	test_field.queue_free()

	return end_time - start_time

func _measure_color_picker_response() -> float:
	# Create test color picker
	var test_picker: ColorPickerButton = ColorPickerButton.new()
	Engine.get_main_loop().current_scene.add_child(test_picker)

	# Measure response time
	var start_time: float = Time.get_ticks_msec()

	# Simulate color change
	test_picker.color = Color.RED
	test_picker.color_changed.emit(Color.RED)
	await Engine.get_main_loop().process_frame

	var end_time: float = Time.get_ticks_msec()

	# Cleanup
	test_picker.queue_free()

	return end_time - start_time

# Results Evaluation
func _evaluate_overall_performance() -> void:
	var all_tests_passed: bool = true

	# Check FPS tests
	for fps_test in performance_results["fps_tests"]:
		if not fps_test["passed"]:
			all_tests_passed = false
			break

	# Check transition tests
	if all_tests_passed:
		for transition_test in performance_results["transition_tests"]:
			if not transition_test["passed"]:
				all_tests_passed = false
				break

	# Check UI response tests
	if all_tests_passed:
		for ui_test in performance_results["ui_response_tests"]:
			if not ui_test["passed"]:
				all_tests_passed = false
				break

	performance_results["overall_passed"] = all_tests_passed
	validation_passed = all_tests_passed

	if all_tests_passed:
		print("✅ Performance validation PASSED - All requirements met")
	else:
		print("❌ Performance validation FAILED - Some requirements not met")

# Utility Functions
func get_performance_report() -> String:
	var report: String = "# Coalition 150 Performance Validation Report\n\n"
	report += "Generated: " + performance_results["timestamp"] + "\n\n"

	# FPS Results
	report += "## FPS Performance Tests\n"
	for fps_test in performance_results["fps_tests"]:
		var status: String = "✅ PASS" if fps_test["passed"] else "❌ FAIL"
		report += "- **%s**: %.2f FPS (target: %.2f) %s\n" % [
			fps_test["test_name"],
			fps_test["measured_fps"],
			fps_test["target_fps"],
			status
		]

	# Transition Results
	report += "\n## Scene Transition Tests\n"
	for transition_test in performance_results["transition_tests"]:
		var status: String = "✅ PASS" if transition_test["passed"] else "❌ FAIL"
		report += "- **%s**: %.2f ms (target: %.2f ms) %s\n" % [
			transition_test["transition"],
			transition_test["measured_time_ms"],
			transition_test["target_time_ms"],
			status
		]

	# UI Response Results
	report += "\n## UI Responsiveness Tests\n"
	for ui_test in performance_results["ui_response_tests"]:
		var status: String = "✅ PASS" if ui_test["passed"] else "❌ FAIL"
		report += "- **%s**: %.2f ms (target: %.2f ms) %s\n" % [
			ui_test["test_name"],
			ui_test["measured_time_ms"],
			ui_test["target_time_ms"],
			status
		]

	# Overall Result
	report += "\n## Overall Result\n"
	var overall_status: String = "✅ PASSED" if performance_results["overall_passed"] else "❌ FAILED"
	report += "**Performance Validation: %s**\n\n" % overall_status

	if not performance_results["overall_passed"]:
		report += "### Recommendations:\n"
		report += "- Review failed tests above\n"
		report += "- Optimize scene loading and UI responsiveness\n"
		report += "- Consider reducing visual complexity if FPS targets not met\n"

	return report

func save_performance_report(file_path: String) -> bool:
	var report: String = get_performance_report()
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)

	if file:
		file.store_string(report)
		file.close()
		print("Performance report saved to: " + file_path)
		return true
	else:
		push_error("Failed to save performance report to: " + file_path)
		return false

# Static utility function for quick validation
static func run_performance_validation() -> Dictionary:
	var validator: PerformanceValidator = PerformanceValidator.new()
	return await validator.validate_system_performance()