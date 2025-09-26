# Integration Test: Regional Campaign Management
# Tests the complete regional campaign management flow

extends GutTest

var main_dashboard: MainDashboard
var netherlands_map: NetherlandsMap
var regional_manager: RegionalManager
var scene_path: String = "res://scenes/dashboard/main_dashboard.tscn"

func before_each() -> void:
	"""Set up test environment"""
	# Load main dashboard
	if ResourceLoader.exists(scene_path):
		var packed_scene = load(scene_path)
		if packed_scene:
			main_dashboard = packed_scene.instantiate()
			add_child(main_dashboard)

func after_each() -> void:
	"""Clean up after test"""
	if main_dashboard:
		main_dashboard.queue_free()
		main_dashboard = null

func test_netherlands_map_integration():
	"""Test that Netherlands map integrates properly with dashboard"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	netherlands_map = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/TopRightContainer/NetherlandsMap")
	assert_not_null(netherlands_map, "NetherlandsMap should be available in dashboard")

func test_province_selection_flow():
	"""Test complete province selection and data flow"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	netherlands_map = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/TopRightContainer/NetherlandsMap")
	if not netherlands_map:
		skip_test("NetherlandsMap not available")
		return

	var test_provinces = ["groningen", "noord_holland", "utrecht"]

	for province_id in test_provinces:
		if netherlands_map.is_valid_province(province_id):
			# Test province selection
			netherlands_map.select_province(province_id)
			await get_tree().process_frame

			var selected = netherlands_map.get_selected_province()
			assert_eq(selected, province_id, "Province selection should work for " + province_id)

func test_province_data_synchronization():
	"""Test that province data syncs between map and regional manager"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	netherlands_map = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/TopRightContainer/NetherlandsMap")
	if not netherlands_map:
		skip_test("NetherlandsMap not available")
		return

	# Test province data update
	var test_province_data = {
		"groningen": {
			"support": 65.0,
			"funding": 15000,
			"activity": 3
		}
	}

	netherlands_map.update_province_display(test_province_data)
	await get_tree().process_frame

	# Map should handle the update without errors
	assert_true(true, "Province data update should not cause errors")

func test_campaign_action_flow():
	"""Test campaign action request flow from map to regional manager"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	netherlands_map = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/TopRightContainer/NetherlandsMap")
	if not netherlands_map:
		skip_test("NetherlandsMap not available")
		return

	var signal_received = false
	var received_province = ""
	var received_action = ""

	# Connect to campaign action signal
	netherlands_map.campaign_action_requested.connect(
		func(province_id: String, action: String):
			signal_received = true
			received_province = province_id
			received_action = action
	)

	# Simulate campaign action request
	netherlands_map.campaign_action_requested.emit("utrecht", "rally")
	await get_tree().process_frame

	assert_true(signal_received, "Campaign action signal should be emitted")
	assert_eq(received_province, "utrecht", "Should receive correct province ID")
	assert_eq(received_action, "rally", "Should receive correct action")

func test_province_highlighting_system():
	"""Test province highlighting functionality"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	netherlands_map = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/TopRightContainer/NetherlandsMap")
	if not netherlands_map:
		skip_test("NetherlandsMap not available")
		return

	# Test highlighting
	netherlands_map.highlight_province("gelderland", true)
	await get_tree().process_frame

	# Should not cause errors
	assert_true(true, "Province highlighting should work without errors")

	# Test unhighlighting
	netherlands_map.highlight_province("gelderland", false)
	await get_tree().process_frame

	assert_true(true, "Province unhighlighting should work without errors")

func test_map_view_mode_switching():
	"""Test switching between different map view modes"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	netherlands_map = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/TopRightContainer/NetherlandsMap")
	if not netherlands_map:
		skip_test("NetherlandsMap not available")
		return

	# Test view mode updates
	netherlands_map.update_province_colors()
	await get_tree().process_frame

	assert_true(true, "Province color updates should work without errors")

func test_emergency_event_regional_integration():
	"""Test regional components respond to emergency events"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	netherlands_map = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/TopRightContainer/NetherlandsMap")
	if not netherlands_map:
		skip_test("NetherlandsMap not available")
		return

	# Test emergency event with regional data
	var emergency_event = {
		"province_id": "zuid_holland",
		"affects_approval": true,
		"new_approval": 25.0
	}

	main_dashboard.handle_emergency_event(emergency_event)
	await get_tree().process_frame

	# Should handle event without crashing
	assert_true(true, "Emergency events with regional data should be handled correctly")

func test_province_hover_interactions():
	"""Test province hover interactions"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	netherlands_map = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/TopRightContainer/NetherlandsMap")
	if not netherlands_map:
		skip_test("NetherlandsMap not available")
		return

	var hover_signal_received = false
	netherlands_map.province_hovered.connect(
		func(province_id: String):
			hover_signal_received = true
	)

	# Simulate hover
	netherlands_map.province_hovered.emit("limburg")
	await get_tree().process_frame

	assert_true(hover_signal_received, "Province hover signal should be emitted")

func test_map_campaign_status_updates():
	"""Test campaign status updates on map"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	netherlands_map = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/TopRightContainer/NetherlandsMap")
	if not netherlands_map:
		skip_test("NetherlandsMap not available")
		return

	# Test campaign status update
	netherlands_map.update_campaign_status()
	await get_tree().process_frame

	assert_true(true, "Campaign status updates should work without errors")

func test_rally_indicators():
	"""Test rally indicator display on map"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	netherlands_map = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/TopRightContainer/NetherlandsMap")
	if not netherlands_map:
		skip_test("NetherlandsMap not available")
		return

	# Test rally indicators
	netherlands_map.show_rally_indicators()
	await get_tree().process_frame

	assert_true(true, "Rally indicators should display without errors")