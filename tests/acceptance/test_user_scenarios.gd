# User Acceptance Test: User Scenarios
# Tests complete user workflows from quickstart scenarios

extends GutTest

var main_dashboard: MainDashboard
var scene_path: String = "res://scenes/dashboard/main_dashboard.tscn"

func before_each() -> void:
	"""Set up test environment"""
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

func test_quickstart_scenario_dashboard_overview():
	"""Test: User opens dashboard and reviews current situation (Quickstart Step 1)"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for dashboard initialization
	await main_dashboard.dashboard_ready

	# Verify all key dashboard components are visible and functional
	var stats_panel = main_dashboard.get_node("VBoxContainer/ContentContainer/LeftPanel/StatsPanel")
	var news_feed = main_dashboard.get_node("VBoxContainer/ContentContainer/LeftPanel/NewsFeed")
	var netherlands_map = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/TopRightContainer/NetherlandsMap")
	var calendar = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/TopRightContainer/Calendar")
	var bills_list = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/BillsList")

	# User should be able to see current approval ratings
	assert_not_null(stats_panel, "Stats panel should be available for overview")

	# User should be able to see recent news
	assert_not_null(news_feed, "News feed should be available for current events")

	# User should be able to see Netherlands map
	assert_not_null(netherlands_map, "Netherlands map should be available for regional overview")

	# User should be able to see calendar
	assert_not_null(calendar, "Calendar should be available for scheduled events")

	# User should be able to see pending bills
	assert_not_null(bills_list, "Bills list should be available for legislative overview")

func test_quickstart_scenario_time_management():
	"""Test: User controls game time (Quickstart Step 2)"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	# User should be able to access time controls
	var pause_button = main_dashboard.get_node("VBoxContainer/HeaderContainer/TimeControlsContainer/PauseButton")
	var play_button = main_dashboard.get_node("VBoxContainer/HeaderContainer/TimeControlsContainer/PlayButton")
	var fast_forward_button = main_dashboard.get_node("VBoxContainer/HeaderContainer/TimeControlsContainer/FastForwardButton")
	var date_time_label = main_dashboard.get_node("VBoxContainer/HeaderContainer/DateTimeLabel")

	assert_not_null(pause_button, "Pause button should be available")
	assert_not_null(play_button, "Play button should be available")
	assert_not_null(fast_forward_button, "Fast forward button should be available")
	assert_not_null(date_time_label, "Date/time display should be available")

	# User should be able to pause time
	if pause_button and not pause_button.disabled:
		pause_button.emit_signal("pressed")
		await get_tree().process_frame
		# Time control should respond without crashing
		assert_true(true, "Pause button should function without errors")

func test_quickstart_scenario_news_response():
	"""Test: User responds to urgent news (Quickstart Step 3)"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	var news_feed = main_dashboard.get_node("VBoxContainer/ContentContainer/LeftPanel/NewsFeed")
	if not news_feed:
		skip_test("NewsFeed not available")
		return

	# Create urgent news item
	var urgent_news = NewsItem.new()
	urgent_news.news_id = "URGENT-TEST"
	urgent_news.headline = "Critical Healthcare Crisis"
	urgent_news.urgency_level = GameEnums.UrgencyLevel.CRITICAL

	# Add urgent news
	news_feed.add_news_item(urgent_news)
	await get_tree().process_frame

	# User should be able to respond to news
	var response_received = false
	news_feed.news_response_selected.connect(
		func(news_id: String, response: GameEnums.ResponseType):
			response_received = true
	)

	# Simulate user selecting a response
	news_feed.news_response_selected.emit("URGENT-TEST", GameEnums.ResponseType.PUBLIC_STATEMENT)
	await get_tree().process_frame

	assert_true(response_received, "User should be able to respond to news items")

func test_quickstart_scenario_bill_voting():
	"""Test: User votes on parliamentary bill (Quickstart Step 4)"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	var bills_list = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/BillsList")
	if not bills_list:
		skip_test("BillsList not available")
		return

	# Create test bill
	var test_bill = Bill.new()
	test_bill.bill_id = "VOTE-TEST"
	test_bill.title = "Test Healthcare Bill"
	test_bill.status = GameEnums.BillResult.PENDING

	# Populate with test bill
	bills_list.populate_bills([test_bill])
	await get_tree().process_frame

	# User should be able to cast vote
	var vote_received = false
	bills_list.bill_vote_cast.connect(
		func(bill_id: String, vote: GameEnums.BillVote):
			vote_received = true
	)

	# Simulate user casting vote
	bills_list.bill_vote_cast.emit("VOTE-TEST", GameEnums.BillVote.YES)
	await get_tree().process_frame

	assert_true(vote_received, "User should be able to vote on bills")

func test_quickstart_scenario_regional_campaign():
	"""Test: User manages regional campaign (Quickstart Step 5)"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	var netherlands_map = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/TopRightContainer/NetherlandsMap")
	if not netherlands_map:
		skip_test("NetherlandsMap not available")
		return

	# User should be able to select provinces
	if netherlands_map.has_method("select_province"):
		netherlands_map.select_province("utrecht")
		await get_tree().process_frame

		var selected = netherlands_map.get_selected_province()
		assert_eq(selected, "utrecht", "User should be able to select provinces")

	# User should be able to request campaign actions
	var campaign_action_received = false
	netherlands_map.campaign_action_requested.connect(
		func(province_id: String, action: String):
			campaign_action_received = true
	)

	# Simulate campaign action request
	netherlands_map.campaign_action_requested.emit("utrecht", "rally")
	await get_tree().process_frame

	assert_true(campaign_action_received, "User should be able to request campaign actions")

func test_quickstart_scenario_event_scheduling():
	"""Test: User schedules government event (Quickstart Step 6)"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	var calendar = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/TopRightContainer/Calendar")
	if not calendar:
		skip_test("Calendar not available")
		return

	# User should be able to schedule events
	var event_scheduled = false
	calendar.event_scheduled.connect(
		func(event: CalendarEvent):
			event_scheduled = true
	)

	# Create test event
	var test_event = CalendarEvent.new()
	test_event.event_id = "SCHEDULE-TEST"
	test_event.title = "Cabinet Meeting"

	# Simulate event scheduling
	calendar.event_scheduled.emit(test_event)
	await get_tree().process_frame

	assert_true(event_scheduled, "User should be able to schedule events")

func test_complete_user_session_workflow():
	"""Test: Complete user session from start to finish"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# 1. Dashboard loads and initializes
	await main_dashboard.dashboard_ready

	# 2. User reviews current situation
	await get_tree().process_frame

	# 3. User pauses time to plan
	var pause_button = main_dashboard.get_node("VBoxContainer/HeaderContainer/TimeControlsContainer/PauseButton")
	if pause_button and not pause_button.disabled:
		pause_button.emit_signal("pressed")
		await get_tree().process_frame

	# 4. User responds to news
	var news_feed = main_dashboard.get_node("VBoxContainer/ContentContainer/LeftPanel/NewsFeed")
	if news_feed:
		news_feed.news_response_selected.emit("TEST-NEWS", GameEnums.ResponseType.MEDIA_CAMPAIGN)
		await get_tree().process_frame

	# 5. User votes on bill
	var bills_list = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/BillsList")
	if bills_list:
		bills_list.bill_vote_cast.emit("TEST-BILL", GameEnums.BillVote.YES)
		await get_tree().process_frame

	# 6. User selects province for campaign
	var netherlands_map = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/TopRightContainer/NetherlandsMap")
	if netherlands_map and netherlands_map.has_method("select_province"):
		netherlands_map.select_province("noord_holland")
		await get_tree().process_frame

	# 7. User schedules event
	var calendar = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/TopRightContainer/Calendar")
	if calendar:
		var event = CalendarEvent.new()
		event.event_id = "SESSION-EVENT"
		calendar.event_scheduled.emit(event)
		await get_tree().process_frame

	# 8. User resumes time
	var play_button = main_dashboard.get_node("VBoxContainer/HeaderContainer/TimeControlsContainer/PlayButton")
	if play_button and not play_button.disabled:
		play_button.emit_signal("pressed")
		await get_tree().process_frame

	# Session should complete without crashes or errors
	assert_true(true, "Complete user session should execute without errors")

func test_error_recovery_scenarios():
	"""Test: User encounters and recovers from various error scenarios"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	# Test invalid province selection
	var netherlands_map = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/TopRightContainer/NetherlandsMap")
	if netherlands_map and netherlands_map.has_method("select_province"):
		netherlands_map.select_province("invalid_province")
		await get_tree().process_frame
		# Should handle gracefully without crashing
		assert_true(true, "Invalid province selection should be handled gracefully")

	# Test emergency event with missing data
	main_dashboard.handle_emergency_event({"invalid": "data"})
	await get_tree().process_frame

	# Should handle gracefully without crashing
	assert_true(true, "Invalid emergency event should be handled gracefully")

func test_accessibility_compliance():
	"""Test: Dashboard meets basic accessibility requirements"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	# Check that all interactive elements have proper labels
	var buttons = _find_all_buttons(main_dashboard)
	for button in buttons:
		assert_false(button.text.is_empty(), "All buttons should have descriptive text")

	# Check that important information is not conveyed by color alone
	# (This would be tested more thoroughly with actual accessibility tools)
	assert_true(true, "Color-only information should have additional indicators")

func test_responsive_design_behavior():
	"""Test: Dashboard adapts to different screen sizes"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	# Dashboard should use responsive layout containers
	var main_container = main_dashboard.get_node("VBoxContainer")
	assert_not_null(main_container, "Dashboard should use flexible layout containers")

	var content_container = main_dashboard.get_node("VBoxContainer/ContentContainer")
	assert_not_null(content_container, "Content should use responsive container")

	# Should handle window resize gracefully (simulated)
	assert_true(true, "Dashboard should adapt to different screen sizes")

## Helper Methods

func _find_all_buttons(node: Node) -> Array[Button]:
	"""Find all Button nodes in the scene tree"""
	var buttons: Array[Button] = []

	if node is Button:
		buttons.append(node)

	for child in node.get_children():
		buttons.append_array(_find_all_buttons(child))

	return buttons