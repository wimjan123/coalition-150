# TimeManager Autoload
# Global time management system for the game

extends Node

# Time progression signals
signal time_advanced(new_time: GameDate)
signal time_speed_changed(new_speed: GameEnums.TimeSpeed)
signal time_paused()
signal time_resumed()
signal day_changed(new_date: GameDate)
signal hour_changed(new_time: GameDate)

var _current_time: GameDate
var _time_speed: GameEnums.TimeSpeed = GameEnums.TimeSpeed.NORMAL
var _is_paused: bool = false
var _scheduled_events: Array[Dictionary] = []
var _time_accumulator: float = 0.0

# Time progression settings (in seconds of real time)
const MINUTE_DURATION: float = 1.0  # 1 real second = 1 game minute at normal speed
const HOUR_DURATION: float = 60.0   # 60 seconds = 1 game hour

func _ready():
	"""Initialize time management system"""
	_current_time = GameDate.new()
	set_process(true)

func _process(delta: float):
	"""Handle automatic time progression"""
	if _is_paused:
		return

	# Accumulate time based on speed multiplier
	_time_accumulator += delta * _time_speed

	# Advance time when enough real time has passed
	if _time_accumulator >= MINUTE_DURATION:
		var minutes_to_advance = int(_time_accumulator / MINUTE_DURATION)
		_time_accumulator -= minutes_to_advance * MINUTE_DURATION

		advance_time(minutes_to_advance)

## Core time management

func get_current_time() -> GameDate:
	"""Get current game time"""
	return _current_time

func advance_time(minutes: int) -> void:
	"""Advance game time by specified minutes"""
	if minutes <= 0:
		return

	var old_hour = _current_time.hour
	var old_day = _current_time.day

	_current_time.advance_time(minutes)

	# Emit signals for time changes
	time_advanced.emit(_current_time)

	if _current_time.hour != old_hour:
		hour_changed.emit(_current_time)

	if _current_time.day != old_day:
		day_changed.emit(_current_time)

	# Process scheduled events
	_process_scheduled_events()

func set_time_speed(speed: GameEnums.TimeSpeed) -> void:
	"""Set time progression speed"""
	if speed == _time_speed:
		return

	_time_speed = speed
	time_speed_changed.emit(_time_speed)

func get_time_speed() -> GameEnums.TimeSpeed:
	"""Get current time speed"""
	return _time_speed

## Pause/Resume functionality

func pause_time() -> void:
	"""Pause time progression"""
	if _is_paused:
		return

	_is_paused = true
	time_paused.emit()

func resume_time() -> void:
	"""Resume time progression"""
	if not _is_paused:
		return

	_is_paused = false
	time_resumed.emit()

func is_paused() -> bool:
	"""Check if time is paused"""
	return _is_paused

func toggle_pause() -> void:
	"""Toggle pause state"""
	if _is_paused:
		resume_time()
	else:
		pause_time()

## Event scheduling integration

func schedule_time_event(target_time: GameDate, callback: Callable) -> void:
	"""Schedule an event to trigger at specific time"""
	if not target_time or not callback.is_valid():
		return

	var event_data = {
		"target_time": target_time,
		"callback": callback
	}

	_scheduled_events.append(event_data)

func cancel_time_event(target_time: GameDate, callback: Callable) -> void:
	"""Cancel a scheduled time event"""
	for i in range(_scheduled_events.size() - 1, -1, -1):
		var event = _scheduled_events[i]
		if event["target_time"].compare(target_time) == 0 and event["callback"] == callback:
			_scheduled_events.remove_at(i)

func get_upcoming_events(hours_ahead: int = 24) -> Array[Dictionary]:
	"""Get events scheduled within specified hours"""
	var upcoming: Array[Dictionary] = []
	var cutoff_time = GameDate.new()
	cutoff_time.year = _current_time.year
	cutoff_time.month = _current_time.month
	cutoff_time.day = _current_time.day
	cutoff_time.hour = _current_time.hour
	cutoff_time.minute = _current_time.minute
	cutoff_time.advance_time(hours_ahead * 60)

	for event in _scheduled_events:
		var event_time = event["target_time"] as GameDate
		if event_time.compare(_current_time) >= 0 and event_time.compare(cutoff_time) <= 0:
			upcoming.append(event)

	return upcoming

## Time utilities

func format_time(time: GameDate, format: String = "default") -> String:
	"""Format time for display"""
	if not time:
		return "Unknown"

	match format:
		"short":
			return "%02d:%02d" % [time.hour, time.minute]
		"date_only":
			return "%d/%d/%d" % [time.month, time.day, time.year]
		_:
			return time.to_display_string()

func calculate_time_until(target: GameDate) -> int:
	"""Calculate minutes until target time"""
	if not target:
		return 0

	# Simplified calculation - assumes target is after current time
	var current_minutes = _current_time.hour * 60 + _current_time.minute
	var target_minutes = target.hour * 60 + target.minute

	return target_minutes - current_minutes

func is_business_hours(time: GameDate = null) -> bool:
	"""Check if specified time (or current time) is business hours"""
	var check_time = time if time else _current_time
	if not check_time:
		return false

	return check_time.hour >= 9 and check_time.hour <= 17

func get_next_business_day(from_date: GameDate = null) -> GameDate:
	"""Get next business day (simplified - no weekends)"""
	var base_date = from_date if from_date else _current_time
	if not base_date:
		return null

	var next_day = GameDate.new()
	next_day.year = base_date.year
	next_day.month = base_date.month
	next_day.day = base_date.day + 1
	next_day.hour = 9
	next_day.minute = 0

	return next_day

## Private methods

func _process_scheduled_events() -> void:
	"""Process any scheduled events that should trigger"""
	for i in range(_scheduled_events.size() - 1, -1, -1):
		var event = _scheduled_events[i]
		var event_time = event["target_time"] as GameDate

		if event_time.compare(_current_time) <= 0:
			# Event time has passed or is current
			var callback = event["callback"] as Callable
			if callback.is_valid():
				callback.call()

			_scheduled_events.remove_at(i)