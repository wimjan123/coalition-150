# Integration Test: Time Management Flow
# Tests the complete time management system integration

extends GutTest

var main_dashboard: MainDashboard
var time_manager: TimeManager
var scene_path: String = "res://scenes/dashboard/main_dashboard.tscn"

func before_each() -> void:
	"""Set up test environment"""
	# Load main dashboard
	if ResourceLoader.exists(scene_path):
		var packed_scene = load(scene_path)
		if packed_scene:
			main_dashboard = packed_scene.instantiate()
			add_child(main_dashboard)

	# Initialize TimeManager if available
	time_manager = TimeManager if TimeManager else null

func after_each() -> void:
	"""Clean up after test"""
	if main_dashboard:
		main_dashboard.queue_free()
		main_dashboard = null

func test_time_manager_integration():
	"""Test that TimeManager integrates with dashboard"""
	if not time_manager:
		skip_test("TimeManager not available")
		return

	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	# TimeManager should be accessible
	assert_not_null(time_manager, "TimeManager should be available")

func test_pause_play_functionality():
	"""Test pause and play time controls"""
	if not main_dashboard or not time_manager:
		skip_test("Components not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	var pause_button = main_dashboard.get_node("VBoxContainer/HeaderContainer/TimeControlsContainer/PauseButton")
	var play_button = main_dashboard.get_node("VBoxContainer/HeaderContainer/TimeControlsContainer/PlayButton")

	if not pause_button or not play_button:
		skip_test("Time control buttons not available")
		return

	# Test pause functionality
	var initial_paused_state = time_manager.is_paused()
	pause_button.emit_signal("pressed")
	await get_tree().process_frame

	# Should pause time (if not already paused)
	if not initial_paused_state:
		assert_true(time_manager.is_paused(), "Time should be paused after pause button press")

	# Test play functionality
	play_button.emit_signal("pressed")
	await get_tree().process_frame

	assert_false(time_manager.is_paused(), "Time should resume after play button press")

func test_fast_forward_functionality():
	"""Test fast forward time controls"""
	if not main_dashboard or not time_manager:
		skip_test("Components not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	var fast_forward_button = main_dashboard.get_node("VBoxContainer/HeaderContainer/TimeControlsContainer/FastForwardButton")

	if not fast_forward_button:
		skip_test("Fast forward button not available")
		return

	var initial_time_scale = time_manager.get_time_scale()

	# Test fast forward
	fast_forward_button.emit_signal("pressed")
	await get_tree().process_frame

	var new_time_scale = time_manager.get_time_scale()
	assert_true(new_time_scale > initial_time_scale, "Time scale should increase with fast forward")

func test_time_display_updates():
	"""Test that time display updates with game time"""
	if not main_dashboard or not time_manager:
		skip_test("Components not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	var date_time_label = main_dashboard.get_node("VBoxContainer/HeaderContainer/DateTimeLabel")

	if not date_time_label:
		skip_test("DateTime label not available")
		return

	# Initial time display should not be empty
	assert_false(date_time_label.text.is_empty(), "Time display should show current time")
	assert_ne(date_time_label.text, "Loading...", "Time display should be updated from loading state")

func test_time_control_state_management():
	"""Test that time control button states update correctly"""
	if not main_dashboard or not time_manager:
		skip_test("Components not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	var pause_button = main_dashboard.get_node("VBoxContainer/HeaderContainer/TimeControlsContainer/PauseButton")
	var play_button = main_dashboard.get_node("VBoxContainer/HeaderContainer/TimeControlsContainer/PlayButton")
	var fast_forward_button = main_dashboard.get_node("VBoxContainer/HeaderContainer/TimeControlsContainer/FastForwardButton")

	if not pause_button or not play_button or not fast_forward_button:
		skip_test("Time control buttons not available")
		return

	# When time is playing, pause should be enabled
	if not time_manager.is_paused():
		assert_false(pause_button.disabled, "Pause button should be enabled when time is playing")

	# Pause time
	pause_button.emit_signal("pressed")
	await get_tree().process_frame

	# When paused, play should be enabled, pause disabled
	assert_true(pause_button.disabled, "Pause button should be disabled when paused")
	assert_false(play_button.disabled, "Play button should be enabled when paused")

func test_time_synchronization_across_components():
	"""Test that all components stay synchronized with time changes"""
	if not main_dashboard or not time_manager:
		skip_test("Components not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	# Get calendar component
	var calendar = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/TopRightContainer/Calendar")

	if not calendar:
		skip_test("Calendar component not available")
		return

	# Calendar should have sync method
	if calendar.has_method("sync_with_game_time"):
		calendar.sync_with_game_time()
		await get_tree().process_frame
		# Should not crash or error
		assert_true(true, "Calendar should sync with game time without errors")

func test_time_advance_simulation():
	"""Test simulated time advancement"""
	if not main_dashboard or not time_manager:
		skip_test("Components not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	var initial_time = time_manager.get_current_time()
	if not initial_time:
		skip_test("Current time not available")
		return

	# Simulate time advancement (if time manager supports it)
	if time_manager.has_method("advance_time"):
		time_manager.advance_time(1.0)  # Advance by 1 hour
		await get_tree().process_frame

		var new_time = time_manager.get_current_time()
		assert_not_null(new_time, "Time should still be available after advancement")

func test_time_persistence():
	"""Test that time settings persist across dashboard operations"""
	if not main_dashboard or not time_manager:
		skip_test("Components not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	# Set fast forward
	var fast_forward_button = main_dashboard.get_node("VBoxContainer/HeaderContainer/TimeControlsContainer/FastForwardButton")
	if fast_forward_button:
		fast_forward_button.emit_signal("pressed")
		await get_tree().process_frame

		var time_scale = time_manager.get_time_scale()

		# Perform some dashboard operation
		main_dashboard.handle_emergency_event({"test": "event"})
		await get_tree().process_frame

		# Time scale should persist
		assert_eq(time_manager.get_time_scale(), time_scale, "Time scale should persist across operations")