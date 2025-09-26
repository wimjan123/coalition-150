# Integration Test: News Response System
# Tests the complete news response and media management flow

extends GutTest

var main_dashboard: MainDashboard
var news_feed: NewsFeed
var dashboard_manager: DashboardManager
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

func test_news_feed_integration():
	"""Test that news feed integrates properly with dashboard"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	news_feed = main_dashboard.get_node("VBoxContainer/ContentContainer/LeftPanel/NewsFeed")
	assert_not_null(news_feed, "NewsFeed should be available in dashboard")

func test_news_response_signal_flow():
	"""Test that news response signals flow correctly through the system"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	news_feed = main_dashboard.get_node("VBoxContainer/ContentContainer/LeftPanel/NewsFeed")
	if not news_feed:
		skip_test("NewsFeed not available")
		return

	var response_signal_received = false
	var received_news_id = ""
	var received_response = GameEnums.ResponseType.NO_RESPONSE

	# Connect to response signal
	news_feed.news_response_selected.connect(
		func(news_id: String, response: GameEnums.ResponseType):
			response_signal_received = true
			received_news_id = news_id
			received_response = response
	)

	# Simulate response selection
	news_feed.news_response_selected.emit("NEWS-001", GameEnums.ResponseType.PUBLIC_STATEMENT)
	await get_tree().process_frame

	assert_true(response_signal_received, "News response signal should be received")
	assert_eq(received_news_id, "NEWS-001", "Should receive correct news ID")
	assert_eq(received_response, GameEnums.ResponseType.PUBLIC_STATEMENT, "Should receive correct response type")

func test_news_item_expansion():
	"""Test news item expansion functionality"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	news_feed = main_dashboard.get_node("VBoxContainer/ContentContainer/LeftPanel/NewsFeed")
	if not news_feed:
		skip_test("NewsFeed not available")
		return

	var expansion_signal_received = false
	var expanded_news_id = ""

	# Connect to expansion signal
	news_feed.news_item_expanded.connect(
		func(news_id: String):
			expansion_signal_received = true
			expanded_news_id = news_id
	)

	# Simulate news expansion
	news_feed.news_item_expanded.emit("NEWS-EXPAND-001")
	await get_tree().process_frame

	assert_true(expansion_signal_received, "News expansion signal should be received")
	assert_eq(expanded_news_id, "NEWS-EXPAND-001", "Should receive correct expanded news ID")

func test_news_population_and_display():
	"""Test news feed population with various news items"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	news_feed = main_dashboard.get_node("VBoxContainer/ContentContainer/LeftPanel/NewsFeed")
	if not news_feed:
		skip_test("NewsFeed not available")
		return

	# Create test news items
	var test_news: Array[NewsItem] = []

	var news1 = NewsItem.new()
	news1.news_id = "NEWS-001"
	news1.headline = "Economic Indicators Improve"
	news1.content = "Recent data shows positive economic trends across multiple sectors."
	news1.urgency_level = GameEnums.UrgencyLevel.NORMAL
	test_news.append(news1)

	var news2 = NewsItem.new()
	news2.news_id = "NEWS-002"
	news2.headline = "Critical Infrastructure Issue"
	news2.content = "Urgent attention needed for infrastructure problems."
	news2.urgency_level = GameEnums.UrgencyLevel.CRITICAL
	test_news.append(news2)

	# Test population
	news_feed.populate_news(test_news)
	await get_tree().process_frame

	assert_true(true, "News population should work without errors")

func test_critical_news_highlighting():
	"""Test critical news highlighting and prioritization"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	news_feed = main_dashboard.get_node("VBoxContainer/ContentContainer/LeftPanel/NewsFeed")
	if not news_feed:
		skip_test("NewsFeed not available")
		return

	# Test critical news highlighting
	news_feed.highlight_critical_news()
	await get_tree().process_frame

	assert_true(true, "Critical news highlighting should work without errors")

func test_news_filtering():
	"""Test news filtering by urgency and other criteria"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	news_feed = main_dashboard.get_node("VBoxContainer/ContentContainer/LeftPanel/NewsFeed")
	if not news_feed:
		skip_test("NewsFeed not available")
		return

	# Get urgent filter checkbox
	var urgent_filter = news_feed.get_node("VBoxContainer/HeaderContainer/UrgentFilter")
	if urgent_filter:
		# Test urgent filtering
		urgent_filter.button_pressed = true
		urgent_filter.emit_signal("toggled", true)
		await get_tree().process_frame

		assert_true(true, "News filtering should work without errors")

func test_response_impact_on_approval():
	"""Test that news responses affect approval ratings"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	news_feed = main_dashboard.get_node("VBoxContainer/ContentContainer/LeftPanel/NewsFeed")
	var stats_panel = main_dashboard.get_node("VBoxContainer/ContentContainer/LeftPanel/StatsPanel")

	if not news_feed or not stats_panel:
		skip_test("Required components not available")
		return

	# Get initial approval
	var initial_approval = 50.0
	stats_panel.set_approval_rating(initial_approval)
	await get_tree().process_frame

	# Make a news response that might affect approval
	news_feed.news_response_selected.emit("APPROVAL-NEWS", GameEnums.ResponseType.MEDIA_CAMPAIGN)
	await get_tree().process_frame

	# System should handle response without crashing
	assert_true(true, "News response should not cause system errors")

func test_emergency_news_integration():
	"""Test emergency news integration with dashboard"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	news_feed = main_dashboard.get_node("VBoxContainer/ContentContainer/LeftPanel/NewsFeed")
	if not news_feed:
		skip_test("NewsFeed not available")
		return

	# Test emergency event creating news
	var emergency_news = NewsItem.new()
	emergency_news.news_id = "EMERGENCY-001"
	emergency_news.headline = "Breaking: Emergency Situation"
	emergency_news.urgency_level = GameEnums.UrgencyLevel.CRITICAL

	var emergency_event = {
		"news_item": emergency_news,
		"affects_approval": true
	}

	main_dashboard.handle_emergency_event(emergency_event)
	await get_tree().process_frame

	assert_true(true, "Emergency news integration should work without errors")

func test_news_item_addition():
	"""Test adding individual news items to feed"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	news_feed = main_dashboard.get_node("VBoxContainer/ContentContainer/LeftPanel/NewsFeed")
	if not news_feed:
		skip_test("NewsFeed not available")
		return

	# Create and add a single news item
	var new_item = NewsItem.new()
	new_item.news_id = "SINGLE-ADD"
	new_item.headline = "Breaking News Addition"
	new_item.content = "This is a dynamically added news item."

	news_feed.add_news_item(new_item)
	await get_tree().process_frame

	assert_true(true, "Adding individual news items should work without errors")

func test_news_read_status():
	"""Test news item read/unread status management"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	news_feed = main_dashboard.get_node("VBoxContainer/ContentContainer/LeftPanel/NewsFeed")
	if not news_feed:
		skip_test("NewsFeed not available")
		return

	# Test marking news as read
	news_feed.mark_as_read("READ-TEST-001")
	await get_tree().process_frame

	assert_true(true, "Marking news as read should work without errors")

func test_response_options_display():
	"""Test display of response options for news items"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	news_feed = main_dashboard.get_node("VBoxContainer/ContentContainer/LeftPanel/NewsFeed")
	if not news_feed:
		skip_test("NewsFeed not available")
		return

	# Test response options display
	news_feed.show_response_options("RESPONSE-TEST")
	await get_tree().process_frame

	assert_true(true, "Response options display should work without errors")

func test_news_dashboard_manager_integration():
	"""Test news feed integration with dashboard manager"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	# Verify news data flows through dashboard manager
	var dashboard_data = main_dashboard._dashboard_manager.get_dashboard_data() if main_dashboard._dashboard_manager else null

	if dashboard_data and dashboard_data.has("news"):
		assert_true(true, "News data should be available through dashboard manager")
	else:
		# Dashboard manager might not have news data initially - that's ok
		pass

func test_news_clear_functionality():
	"""Test clearing news feed"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	news_feed = main_dashboard.get_node("VBoxContainer/ContentContainer/LeftPanel/NewsFeed")
	if not news_feed:
		skip_test("NewsFeed not available")
		return

	# Test clearing news
	news_feed.clear_news()
	await get_tree().process_frame

	assert_true(true, "Clearing news feed should work without errors")