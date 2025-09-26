extends GutTest

# Test CalendarEvent resource class
# Tests must FAIL before implementation exists

func before_each():
	pass

func test_calendar_event_resource_exists():
	# This test will fail until CalendarEvent class is implemented
	var event = CalendarEvent.new()
	assert_not_null(event, "CalendarEvent resource should be creatable")

func test_calendar_event_has_required_fields():
	var event = CalendarEvent.new()

	# Test field existence
	assert_has_method(event, "get_title")
	assert_has_method(event, "set_title")

	# Test default values
	assert_eq(event.duration_hours, 1, "Default duration should be 1 hour")
	assert_eq(event.cost, 0, "Default cost should be 0")
	assert_eq(event.status, EventStatus.SCHEDULED, "Default status should be scheduled")
	assert_eq(event.requirements.size(), 0, "Should start with no requirements")

func test_calendar_event_setup():
	var event = CalendarEvent.new()
	event.event_id = "EVENT-001"
	event.title = "Town Hall Meeting"
	event.event_type = EventType.MEETING

	assert_eq(event.event_id, "EVENT-001", "Should store event ID")
	assert_eq(event.title, "Town Hall Meeting", "Should store title")
	assert_eq(event.event_type, EventType.MEETING, "Should store event type")

func test_calendar_event_scheduling():
	var event = CalendarEvent.new()
	var date = GameDate.new()
	date.hour = 14
	event.scheduled_date = date
	event.duration_hours = 2

	assert_eq(event.scheduled_date.hour, 14, "Should store scheduled time")
	assert_eq(event.duration_hours, 2, "Should store duration")

func test_calendar_event_conflicts():
	var event = CalendarEvent.new()
	event.conflicts_with.append("RALLY-001")
	event.conflicts_with.append("INTERVIEW-002")

	assert_eq(event.conflicts_with.size(), 2, "Should store conflict list")
	assert_true(event.conflicts_with.has("RALLY-001"), "Should contain conflict")

func test_calendar_event_validation():
	var event = CalendarEvent.new()

	# Test cost validation
	event.cost = -100
	assert_false(event.is_valid(), "Negative cost should be invalid")

	event.cost = 1000
	assert_true(event.is_valid(), "Positive cost should be valid")