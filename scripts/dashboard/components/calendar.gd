# Calendar Component
# Event scheduling and calendar display

class_name Calendar
extends Control

signal event_scheduled(event: CalendarEvent)
signal event_selected(event: CalendarEvent)
signal date_selected(date: GameDate)

@onready var prev_button: Button = $VBoxContainer/HeaderContainer/PrevButton
@onready var next_button: Button = $VBoxContainer/HeaderContainer/NextButton
@onready var month_label: Label = $VBoxContainer/HeaderContainer/MonthLabel
@onready var calendar_grid: GridContainer = $VBoxContainer/CalendarGrid
@onready var events_container: VBoxContainer = $VBoxContainer/EventsList/EventsScroll/EventsContainer

var _current_date: GameDate
var _display_month: int = 1
var _display_year: int = 2025
var _events: Array[CalendarEvent] = []
var _day_buttons: Array[Button] = []

func _ready() -> void:
	"""Initialize calendar"""
	_current_date = GameDate.new()
	_display_month = _current_date.month
	_display_year = _current_date.year

	prev_button.pressed.connect(_on_prev_month)
	next_button.pressed.connect(_on_next_month)

	_setup_calendar_grid()
	_populate_sample_events()
	update_current_date()

func populate_events(events: Array[CalendarEvent]) -> void:
	"""Populate calendar with events"""
	_events = events
	_refresh_display()

func add_event(event: CalendarEvent) -> void:
	"""Add event to calendar"""
	if not event or not event.is_valid():
		return

	_events.append(event)
	_refresh_display()
	event_scheduled.emit(event)

func remove_event(event_id: String) -> void:
	"""Remove event from calendar"""
	for i in range(_events.size()):
		if _events[i].event_id == event_id:
			_events.remove_at(i)
			_refresh_display()
			break

func highlight_date(date: GameDate) -> void:
	"""Highlight specific date"""
	if not date:
		return

	# Find and highlight the day button
	for button in _day_buttons:
		if button.get_meta("day", 0) == date.day:
			button.modulate = Color.YELLOW

func get_scheduled_events() -> Array[CalendarEvent]:
	"""Get all scheduled events"""
	return _events.duplicate()

func go_to_date(date: GameDate) -> void:
	"""Navigate to specific date"""
	if not date:
		return

	_display_month = date.month
	_display_year = date.year
	_refresh_calendar_display()

func next_month() -> void:
	"""Navigate to next month"""
	_display_month += 1
	if _display_month > 12:
		_display_month = 1
		_display_year += 1
	_refresh_calendar_display()

func previous_month() -> void:
	"""Navigate to previous month"""
	_display_month -= 1
	if _display_month < 1:
		_display_month = 12
		_display_year -= 1
	_refresh_calendar_display()

func check_conflicts(event: CalendarEvent) -> Array[CalendarEvent]:
	"""Check for scheduling conflicts"""
	var conflicts: Array[CalendarEvent] = []

	if not event or not event.scheduled_date:
		return conflicts

	for existing_event in _events:
		if existing_event.conflicts_with_event(event):
			conflicts.append(existing_event)

	return conflicts

func highlight_conflicts() -> void:
	"""Highlight days with scheduling conflicts"""
	# Implementation would check for overlapping events
	pass

func update_current_date() -> void:
	"""Update current date highlighting"""
	if TimeManager:
		_current_date = TimeManager.get_current_time()
		_refresh_calendar_display()

func sync_with_game_time() -> void:
	"""Sync calendar with game time"""
	update_current_date()

## Private Methods

func _setup_calendar_grid() -> void:
	"""Set up the calendar grid with day headers"""
	# Day headers
	var day_names = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
	for day_name in day_names:
		var label = Label.new()
		label.text = day_name
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		calendar_grid.add_child(label)

	# Create day buttons (42 total for 6 weeks)
	for i in range(42):
		var button = Button.new()
		button.custom_minimum_size = Vector2(40, 40)
		button.pressed.connect(_on_day_selected.bind(button))
		calendar_grid.add_child(button)
		_day_buttons.append(button)

func _refresh_display() -> void:
	"""Refresh both calendar and events display"""
	_refresh_calendar_display()
	_refresh_events_display()

func _refresh_calendar_display() -> void:
	"""Refresh the calendar grid display"""
	# Update month label
	var month_names = ["", "January", "February", "March", "April", "May", "June",
		"July", "August", "September", "October", "November", "December"]
	month_label.text = "%s %d" % [month_names[_display_month], _display_year]

	# Calculate first day of month and days in month
	var first_day_of_week = 1  # Simplified - would calculate actual day of week
	var days_in_month = _get_days_in_month(_display_month, _display_year)

	# Reset all buttons
	for i in range(_day_buttons.size()):
		var button = _day_buttons[i]
		button.text = ""
		button.disabled = true
		button.modulate = Color.WHITE
		button.set_meta("day", 0)

	# Fill in the days
	for day in range(1, days_in_month + 1):
		var button_index = first_day_of_week + day - 1
		if button_index < _day_buttons.size():
			var button = _day_buttons[button_index]
			button.text = str(day)
			button.disabled = false
			button.set_meta("day", day)

			# Highlight current day
			if day == _current_date.day and _display_month == _current_date.month and _display_year == _current_date.year:
				button.modulate = Color.LIGHT_BLUE

			# Mark days with events
			if _has_events_on_day(day):
				button.modulate = Color.LIGHT_GREEN

func _refresh_events_display() -> void:
	"""Refresh the events list display"""
	# Clear existing event items
	for child in events_container.get_children():
		child.queue_free()

	# Show events for current month
	var month_events = _get_events_for_month(_display_month, _display_year)
	for event in month_events:
		_create_event_item(event)

func _create_event_item(event: CalendarEvent) -> void:
	"""Create UI item for event"""
	var event_container = HBoxContainer.new()

	# Event date
	var date_label = Label.new()
	if event.scheduled_date:
		date_label.text = "%d/%d" % [event.scheduled_date.month, event.scheduled_date.day]
	date_label.custom_minimum_size = Vector2(60, 0)
	event_container.add_child(date_label)

	# Event title and type
	var info_label = Label.new()
	info_label.text = "%s (%s)" % [event.title, event.get_type_description()]
	info_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	event_container.add_child(info_label)

	# Event time
	var time_label = Label.new()
	if event.scheduled_date:
		time_label.text = "%02d:%02d" % [event.scheduled_date.hour, event.scheduled_date.minute]
	event_container.add_child(time_label)

	events_container.add_child(event_container)

func _get_days_in_month(month: int, year: int) -> int:
	"""Get number of days in month"""
	var days_per_month = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

	if month == 2 and _is_leap_year(year):
		return 29

	return days_per_month[month]

func _is_leap_year(year: int) -> bool:
	"""Check if year is leap year"""
	return year % 4 == 0 and (year % 100 != 0 or year % 400 == 0)

func _has_events_on_day(day: int) -> bool:
	"""Check if day has events"""
	for event in _events:
		if event.scheduled_date and event.scheduled_date.day == day and event.scheduled_date.month == _display_month and event.scheduled_date.year == _display_year:
			return true
	return false

func _get_events_for_month(month: int, year: int) -> Array[CalendarEvent]:
	"""Get events for specific month"""
	var month_events: Array[CalendarEvent] = []

	for event in _events:
		if event.scheduled_date and event.scheduled_date.month == month and event.scheduled_date.year == year:
			month_events.append(event)

	return month_events

func _populate_sample_events() -> void:
	"""Populate with sample events for testing"""
	var sample_events: Array[CalendarEvent] = []

	# Sample event 1
	var event1 = CalendarEvent.new()
	event1.event_id = "EVENT-001"
	event1.title = "Cabinet Meeting"
	event1.event_type = GameEnums.EventType.MEETING
	event1.scheduled_date = GameDate.new()
	event1.scheduled_date.day = 15
	sample_events.append(event1)

	# Sample event 2
	var event2 = CalendarEvent.new()
	event2.event_id = "EVENT-002"
	event2.title = "Public Rally - Amsterdam"
	event2.event_type = GameEnums.EventType.RALLY
	event2.scheduled_date = GameDate.new()
	event2.scheduled_date.day = 22
	sample_events.append(event2)

	populate_events(sample_events)

## Signal Handlers

func _on_prev_month() -> void:
	"""Handle previous month button"""
	previous_month()

func _on_next_month() -> void:
	"""Handle next month button"""
	next_month()

func _on_day_selected(button: Button) -> void:
	"""Handle day selection"""
	var day = button.get_meta("day", 0)
	if day > 0:
		var selected_date = GameDate.new()
		selected_date.year = _display_year
		selected_date.month = _display_month
		selected_date.day = day

		date_selected.emit(selected_date)