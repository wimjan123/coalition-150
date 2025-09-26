# Performance Validation Test: Dashboard Performance
# Tests performance requirements: 60 FPS, <50MB memory

extends GutTest

var main_dashboard: MainDashboard
var scene_path: String = "res://scenes/dashboard/main_dashboard.tscn"
var performance_monitor: PerformanceMonitor

class PerformanceMonitor:
	var fps_samples: Array[float] = []
	var memory_samples: Array[int] = []
	var frame_count: int = 0
	var total_time: float = 0.0

	func start_monitoring():
		fps_samples.clear()
		memory_samples.clear()
		frame_count = 0
		total_time = 0.0

	func update(delta: float):
		total_time += delta
		frame_count += 1

		# Sample every 10 frames
		if frame_count % 10 == 0:
			var current_fps = Engine.get_frames_per_second()
			var memory_usage = OS.get_static_memory_usage_by_type()
			var total_memory = 0

			for mem_type in memory_usage:
				total_memory += memory_usage[mem_type]

			fps_samples.append(current_fps)
			memory_samples.append(total_memory)

	func get_average_fps() -> float:
		if fps_samples.is_empty():
			return 0.0
		var sum = 0.0
		for fps in fps_samples:
			sum += fps
		return sum / fps_samples.size()

	func get_max_memory() -> int:
		if memory_samples.is_empty():
			return 0
		var max_mem = 0
		for mem in memory_samples:
			if mem > max_mem:
				max_mem = mem
		return max_mem

	func get_min_fps() -> float:
		if fps_samples.is_empty():
			return 0.0
		var min_fps = 999.0
		for fps in fps_samples:
			if fps < min_fps:
				min_fps = fps
		return min_fps

func before_all() -> void:
	"""Set up performance monitoring"""
	performance_monitor = PerformanceMonitor.new()

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

func test_dashboard_loads_within_performance_requirements():
	"""Test that dashboard loads and maintains performance requirements"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	performance_monitor.start_monitoring()

	# Wait for full initialization
	await get_tree().process_frame
	await get_tree().process_frame

	# Monitor performance for 3 seconds of operation
	var test_duration = 3.0
	var elapsed_time = 0.0

	while elapsed_time < test_duration:
		var delta = get_tree().process_frame
		await delta

		performance_monitor.update(get_process_delta_time())
		elapsed_time += get_process_delta_time()

		# Simulate some dashboard activity
		if elapsed_time > 1.0 and elapsed_time < 1.1:
			_simulate_dashboard_interaction()

	# Validate performance requirements
	var avg_fps = performance_monitor.get_average_fps()
	var min_fps = performance_monitor.get_min_fps()
	var max_memory_mb = performance_monitor.get_max_memory() / 1024 / 1024

	# Performance requirements
	assert_true(avg_fps >= 55.0, "Average FPS should be >= 55 (target: 60), got: %.1f" % avg_fps)
	assert_true(min_fps >= 45.0, "Minimum FPS should be >= 45, got: %.1f" % min_fps)
	assert_true(max_memory_mb <= 60.0, "Memory usage should be <= 60MB (target: <50MB), got: %.1f MB" % max_memory_mb)

func test_component_initialization_performance():
	"""Test that all dashboard components initialize within reasonable time"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	var start_time = Time.get_ticks_msec()

	# Wait for complete initialization
	await main_dashboard.dashboard_ready

	var initialization_time = Time.get_ticks_msec() - start_time

	# Should initialize within 2 seconds
	assert_true(initialization_time <= 2000, "Dashboard initialization should complete within 2000ms, took: %d ms" % initialization_time)

func test_ui_responsiveness_under_load():
	"""Test UI responsiveness when processing multiple events"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	performance_monitor.start_monitoring()

	# Simulate multiple rapid events
	for i in range(20):
		_simulate_news_update()
		_simulate_province_update()
		_simulate_time_update()

		await get_tree().process_frame
		performance_monitor.update(get_process_delta_time())

	var avg_fps = performance_monitor.get_average_fps()
	assert_true(avg_fps >= 50.0, "FPS should remain stable under load, got: %.1f" % avg_fps)

func test_memory_stability_over_time():
	"""Test that memory usage remains stable during extended operation"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	var initial_memory = OS.get_static_memory_usage_by_type()
	var initial_total = 0
	for mem_type in initial_memory:
		initial_total += initial_memory[mem_type]

	# Simulate 30 seconds of operation (compressed)
	for i in range(30):
		_simulate_dashboard_operations()
		await get_tree().process_frame

		# Force garbage collection every 10 iterations
		if i % 10 == 0:
			pass  # GDScript handles garbage collection automatically

	var final_memory = OS.get_static_memory_usage_by_type()
	var final_total = 0
	for mem_type in final_memory:
		final_total += final_memory[mem_type]

	var memory_growth = (final_total - initial_total) / 1024 / 1024  # MB

	# Memory growth should be minimal (< 10MB)
	assert_true(memory_growth <= 10.0, "Memory growth should be minimal, grew by: %.1f MB" % memory_growth)

func test_large_data_handling_performance():
	"""Test performance with large amounts of data"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	performance_monitor.start_monitoring()

	# Load large amounts of data
	_simulate_large_news_load()
	_simulate_large_bills_load()
	_simulate_large_events_load()

	# Monitor for a few frames
	for i in range(10):
		await get_tree().process_frame
		performance_monitor.update(get_process_delta_time())

	var avg_fps = performance_monitor.get_average_fps()
	assert_true(avg_fps >= 45.0, "Should maintain decent FPS with large data loads, got: %.1f" % avg_fps)

func test_concurrent_operations_performance():
	"""Test performance during concurrent dashboard operations"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	performance_monitor.start_monitoring()

	# Simulate concurrent operations
	for i in range(10):
		# Multiple simultaneous updates
		_simulate_news_update()
		_simulate_bill_update()
		_simulate_stats_update()
		_simulate_map_update()

		await get_tree().process_frame
		performance_monitor.update(get_process_delta_time())

	var min_fps = performance_monitor.get_min_fps()
	assert_true(min_fps >= 40.0, "Should handle concurrent operations without major FPS drops, minimum: %.1f" % min_fps)

## Helper Methods

func _simulate_dashboard_interaction():
	"""Simulate user interaction with dashboard"""
	if not main_dashboard:
		return

	# Simulate province selection
	var netherlands_map = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/TopRightContainer/NetherlandsMap")
	if netherlands_map and netherlands_map.has_method("select_province"):
		netherlands_map.select_province("utrecht")

func _simulate_news_update():
	"""Simulate news feed update"""
	if not main_dashboard:
		return

	var news_feed = main_dashboard.get_node("VBoxContainer/ContentContainer/LeftPanel/NewsFeed")
	if news_feed and news_feed.has_method("add_news_item"):
		var news_item = NewsItem.new()
		news_item.news_id = "PERF-TEST-" + str(Time.get_ticks_msec())
		news_item.headline = "Performance Test News"
		news_feed.add_news_item(news_item)

func _simulate_province_update():
	"""Simulate province data update"""
	if not main_dashboard:
		return

	var netherlands_map = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/TopRightContainer/NetherlandsMap")
	if netherlands_map and netherlands_map.has_method("update_province_display"):
		var province_data = {"groningen": {"support": 45.0, "funding": 12000}}
		netherlands_map.update_province_display(province_data)

func _simulate_time_update():
	"""Simulate time management update"""
	if main_dashboard and main_dashboard.has_method("_update_time_display"):
		# This would normally be called by TimeManager
		pass

func _simulate_dashboard_operations():
	"""Simulate various dashboard operations"""
	_simulate_news_update()
	_simulate_province_update()

	# Simulate emergency event
	if main_dashboard:
		main_dashboard.handle_emergency_event({"test": "performance"})

func _simulate_large_news_load():
	"""Simulate loading large number of news items"""
	var news_feed = main_dashboard.get_node("VBoxContainer/ContentContainer/LeftPanel/NewsFeed") if main_dashboard else null
	if not news_feed:
		return

	var large_news: Array[NewsItem] = []
	for i in range(50):  # Simulate 50 news items
		var news = NewsItem.new()
		news.news_id = "LOAD-TEST-" + str(i)
		news.headline = "Load Test News Item " + str(i)
		news.content = "This is a performance test news item with some content to simulate real data loading."
		large_news.append(news)

	if news_feed.has_method("populate_news"):
		news_feed.populate_news(large_news)

func _simulate_large_bills_load():
	"""Simulate loading large number of bills"""
	var bills_list = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/BillsList") if main_dashboard else null
	if not bills_list:
		return

	var large_bills: Array[ParliamentaryBill] = []
	for i in range(25):  # Simulate 25 bills
		var bill = Bill.new()
		bill.bill_id = "PERF-BILL-" + str(i)
		bill.title = "Performance Test Bill " + str(i)
		large_bills.append(bill)

	if bills_list.has_method("populate_bills"):
		bills_list.populate_bills(large_bills)

func _simulate_large_events_load():
	"""Simulate loading large number of calendar events"""
	var calendar = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/TopRightContainer/Calendar") if main_dashboard else null
	if not calendar:
		return

	var large_events: Array[CalendarEvent] = []
	for i in range(30):  # Simulate 30 events
		var event = CalendarEvent.new()
		event.event_id = "PERF-EVENT-" + str(i)
		event.title = "Performance Test Event " + str(i)
		large_events.append(event)

	if calendar.has_method("populate_events"):
		calendar.populate_events(large_events)

func _simulate_bill_update():
	"""Simulate bill data update"""
	var bills_list = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/BillsList") if main_dashboard else null
	if bills_list and bills_list.has_method("highlight_urgent_bills"):
		bills_list.highlight_urgent_bills()

func _simulate_stats_update():
	"""Simulate stats panel update"""
	var stats_panel = main_dashboard.get_node("VBoxContainer/ContentContainer/LeftPanel/StatsPanel") if main_dashboard else null
	if stats_panel and stats_panel.has_method("set_approval_rating"):
		stats_panel.set_approval_rating(50.0 + randf_range(-5.0, 5.0))

func _simulate_map_update():
	"""Simulate map display update"""
	var netherlands_map = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/TopRightContainer/NetherlandsMap") if main_dashboard else null
	if netherlands_map and netherlands_map.has_method("update_province_colors"):
		netherlands_map.update_province_colors()