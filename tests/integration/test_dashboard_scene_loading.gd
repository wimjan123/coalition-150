# Integration Test: Dashboard Scene Loading
# Tests that the main dashboard scene loads correctly with all components

extends GutTest

var main_scene: MainDashboard
var scene_path: String = "res://scenes/dashboard/main_dashboard.tscn"

func before_each() -> void:
	"""Set up test environment"""
	if ResourceLoader.exists(scene_path):
		var packed_scene = load(scene_path)
		if packed_scene:
			main_scene = packed_scene.instantiate()
			add_child(main_scene)

func after_each() -> void:
	"""Clean up after test"""
	if main_scene:
		main_scene.queue_free()
		main_scene = null

func test_main_dashboard_scene_loads():
	"""Test that main dashboard scene loads without errors"""
	if not ResourceLoader.exists(scene_path):
		skip_test("MainDashboard scene not found at " + scene_path)
		return

	assert_not_null(main_scene, "MainDashboard scene should instantiate")
	assert_true(main_scene is MainDashboard, "Scene should be MainDashboard type")

func test_all_required_components_present():
	"""Test that all required dashboard components are present"""
	if not main_scene:
		skip_test("MainDashboard scene not available")
		return

	# Wait for scene to be ready
	await get_tree().process_frame

	# Check for component references
	var components_status = main_scene.get_component_status()

	assert_true(components_status.get("stats_panel", false), "StatsPanel should be available")
	assert_true(components_status.get("news_feed", false), "NewsFeed should be available")
	assert_true(components_status.get("netherlands_map", false), "NetherlandsMap should be available")
	assert_true(components_status.get("calendar", false), "Calendar should be available")
	assert_true(components_status.get("bills_list", false), "BillsList should be available")

func test_managers_initialize():
	"""Test that dashboard and regional managers initialize"""
	if not main_scene:
		skip_test("MainDashboard scene not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	var components_status = main_scene.get_component_status()

	assert_true(components_status.get("dashboard_manager", false), "DashboardManager should be initialized")
	assert_true(components_status.get("regional_manager", false), "RegionalManager should be initialized")

func test_time_controls_present():
	"""Test that time control buttons are present and functional"""
	if not main_scene:
		skip_test("MainDashboard scene not available")
		return

	# Wait for scene to be ready
	await get_tree().process_frame

	var pause_button = main_scene.get_node("VBoxContainer/HeaderContainer/TimeControlsContainer/PauseButton")
	var play_button = main_scene.get_node("VBoxContainer/HeaderContainer/TimeControlsContainer/PlayButton")
	var fast_forward_button = main_scene.get_node("VBoxContainer/HeaderContainer/TimeControlsContainer/FastForwardButton")
	var date_time_label = main_scene.get_node("VBoxContainer/HeaderContainer/DateTimeLabel")

	assert_not_null(pause_button, "Pause button should be present")
	assert_not_null(play_button, "Play button should be present")
	assert_not_null(fast_forward_button, "Fast forward button should be present")
	assert_not_null(date_time_label, "Date/time label should be present")

func test_dashboard_ready_signal():
	"""Test that dashboard_ready signal is emitted during initialization"""
	if not main_scene:
		skip_test("MainDashboard scene not available")
		return

	var signal_received = false

	main_scene.dashboard_ready.connect(func(): signal_received = true)

	# Wait for initialization
	await get_tree().process_frame

	assert_true(signal_received, "dashboard_ready signal should be emitted")

func test_scene_hierarchy_structure():
	"""Test that the scene hierarchy matches expected structure"""
	if not main_scene:
		skip_test("MainDashboard scene not available")
		return

	# Check main container structure
	var vbox = main_scene.get_node("VBoxContainer")
	assert_not_null(vbox, "Main VBoxContainer should exist")

	var header = main_scene.get_node("VBoxContainer/HeaderContainer")
	assert_not_null(header, "HeaderContainer should exist")

	var content = main_scene.get_node("VBoxContainer/ContentContainer")
	assert_not_null(content, "ContentContainer should exist")

	var left_panel = main_scene.get_node("VBoxContainer/ContentContainer/LeftPanel")
	var right_panel = main_scene.get_node("VBoxContainer/ContentContainer/RightPanel")
	assert_not_null(left_panel, "LeftPanel should exist")
	assert_not_null(right_panel, "RightPanel should exist")

func test_component_error_handling():
	"""Test that component errors are handled gracefully"""
	if not main_scene:
		skip_test("MainDashboard scene not available")
		return

	var error_received = false
	var error_component = ""
	var error_message = ""

	main_scene.component_error.connect(func(component: String, error: String):
		error_received = true
		error_component = component
		error_message = error
	)

	# Trigger emergency event with missing data to test error handling
	main_scene.handle_emergency_event({"invalid": "data"})

	# Wait for processing
	await get_tree().process_frame

	# Error handling should prevent crashes even with invalid data
	assert_true(main_scene != null, "Dashboard should remain stable with invalid data")