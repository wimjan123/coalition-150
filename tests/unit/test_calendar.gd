extends GutTest

# Test Calendar UI component
# Tests must FAIL before implementation exists

var calendar: Control

func before_each():
	var calendar_scene = preload("res://scenes/dashboard/components/calendar.tscn")
	if calendar_scene:
		calendar = calendar_scene.instantiate()
		add_child_autofree(calendar)

func test_calendar_scene_exists():
	var scene_path = "res://scenes/dashboard/components/calendar.tscn"
	assert_true(ResourceLoader.exists(scene_path), "Calendar scene should exist")

func test_calendar_has_basic_structure():
	if not calendar:
		skip_test("Calendar scene not available")
		return

	# Should have calendar grid and event list
	var calendar_grid = calendar.get_node("CalendarGrid")
	var event_list = calendar.get_node("EventsList")

	assert_not_null(calendar_grid, "Should have CalendarGrid")
	assert_not_null(event_list, "Should have EventsList")

func test_calendar_script_interface():
	if not calendar:
		skip_test("Calendar scene not available")
		return

	assert_has_method(calendar, "populate_events")
	assert_has_method(calendar, "add_event")
	assert_has_method(calendar, "remove_event")
	assert_has_method(calendar, "highlight_date")

func test_calendar_event_management():
	if not calendar:
		skip_test("Calendar scene not available")
		return

	var test_event = CalendarEvent.new()
	test_event.event_id = "EVENT-001"
	test_event.title = "Test Meeting"
	test_event.event_type = GameEnums.EventType.MEETING

	calendar.add_event(test_event)

	# Should display event on calendar
	var events = calendar.get_scheduled_events()
	assert_gt(events.size(), 0, "Should track events")

func test_calendar_date_navigation():
	if not calendar:
		skip_test("Calendar scene not available")
		return

	assert_has_method(calendar, "go_to_date")
	assert_has_method(calendar, "next_month")
	assert_has_method(calendar, "previous_month")

func test_calendar_conflict_detection():
	if not calendar:
		skip_test("Calendar scene not available")
		return

	assert_has_method(calendar, "check_conflicts")
	assert_has_method(calendar, "highlight_conflicts")

func test_calendar_signals():
	if not calendar:
		skip_test("Calendar scene not available")
		return

	watch_signals(calendar)

	assert_has_signal(calendar, "event_scheduled")
	assert_has_signal(calendar, "event_selected")
	assert_has_signal(calendar, "date_selected")

func test_calendar_time_integration():
	if not calendar:
		skip_test("Calendar scene not available")
		return

	# Should connect to TimeManager for current date highlighting
	assert_has_method(calendar, "update_current_date")
	assert_has_method(calendar, "sync_with_game_time")