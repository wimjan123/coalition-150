# Time Manager Interface Contract
# Defines the interface for the global time management system

class_name ITimeManager
extends RefCounted

## Time progression signals
signal time_advanced(new_time: GameDate)
signal time_speed_changed(new_speed: TimeSpeed)
signal time_paused()
signal time_resumed()
signal day_changed(new_date: GameDate)
signal hour_changed(new_time: GameDate)

## Core time management
func get_current_time() -> GameDate:
	assert(false, "Must be implemented by concrete class")
	return null

func advance_time(minutes: int) -> void:
	assert(false, "Must be implemented by concrete class")

func set_time_speed(speed: TimeSpeed) -> void:
	assert(false, "Must be implemented by concrete class")

func get_time_speed() -> TimeSpeed:
	assert(false, "Must be implemented by concrete class")
	return TimeSpeed.NORMAL

## Pause/Resume functionality
func pause_time() -> void:
	assert(false, "Must be implemented by concrete class")

func resume_time() -> void:
	assert(false, "Must be implemented by concrete class")

func is_paused() -> bool:
	assert(false, "Must be implemented by concrete class")
	return false

func toggle_pause() -> void:
	assert(false, "Must be implemented by concrete class")

## Event scheduling integration
func schedule_time_event(target_time: GameDate, callback: Callable) -> void:
	assert(false, "Must be implemented by concrete class")

func cancel_time_event(target_time: GameDate, callback: Callable) -> void:
	assert(false, "Must be implemented by concrete class")

func get_upcoming_events(hours_ahead: int = 24) -> Array[Dictionary]:
	assert(false, "Must be implemented by concrete class")
	return []

## Time utilities
func format_time(time: GameDate, format: String = "default") -> String:
	assert(false, "Must be implemented by concrete class")
	return ""

func calculate_time_until(target: GameDate) -> int:
	assert(false, "Must be implemented by concrete class")
	return 0

func is_business_hours(time: GameDate = null) -> bool:
	assert(false, "Must be implemented by concrete class")
	return false

func get_next_business_day(from_date: GameDate = null) -> GameDate:
	assert(false, "Must be implemented by concrete class")
	return null