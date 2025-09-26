# CalendarEvent Resource
# Represents a scheduled political event

class_name CalendarEvent
extends Resource

@export var event_id: String
@export var title: String
@export var description: String
@export var event_type: GameEnums.EventType
@export var scheduled_date: GameDate
@export var duration_hours: int = 1
@export var cost: int = 0
@export var requirements: Array[String] = []  # Prerequisites
@export var conflicts_with: Array[String] = [] # Conflicting events
@export var status: GameEnums.EventStatus = GameEnums.EventStatus.SCHEDULED

func get_title() -> String:
	return title

func set_title(value: String) -> void:
	title = value

func is_valid() -> bool:
	"""Validate event values"""
	if cost < 0:
		return false

	if duration_hours <= 0:
		return false

	if title.is_empty() or event_id.is_empty():
		return false

	if not scheduled_date:
		return false

	return true

func get_end_time() -> GameDate:
	"""Calculate event end time"""
	if not scheduled_date:
		return null

	var end_time = GameDate.new()
	end_time.year = scheduled_date.year
	end_time.month = scheduled_date.month
	end_time.day = scheduled_date.day
	end_time.hour = scheduled_date.hour
	end_time.minute = scheduled_date.minute

	# Add duration
	end_time.advance_time(duration_hours * 60)
	return end_time

func conflicts_with_event(other_event: CalendarEvent) -> bool:
	"""Check if this event conflicts with another"""
	if not other_event or not scheduled_date or not other_event.scheduled_date:
		return false

	# Check explicit conflicts list
	if conflicts_with.has(other_event.event_id):
		return true

	# Check time overlap
	var this_start = scheduled_date
	var this_end = get_end_time()
	var other_start = other_event.scheduled_date
	var other_end = other_event.get_end_time()

	if not this_end or not other_end:
		return false

	# Events conflict if they overlap in time
	return not (this_end.compare(other_start) <= 0 or other_end.compare(this_start) <= 0)

func get_type_description() -> String:
	"""Get descriptive event type"""
	match event_type:
		GameEnums.EventType.MEETING: return "Meeting"
		GameEnums.EventType.RALLY: return "Rally"
		GameEnums.EventType.INTERVIEW: return "Interview"
		GameEnums.EventType.TRAVEL: return "Travel"
		_: return "Unknown"

func get_status_description() -> String:
	"""Get descriptive event status"""
	match status:
		GameEnums.EventStatus.SCHEDULED: return "Scheduled"
		GameEnums.EventStatus.IN_PROGRESS: return "In Progress"
		GameEnums.EventStatus.COMPLETED: return "Completed"
		GameEnums.EventStatus.CANCELLED: return "Cancelled"
		_: return "Unknown"

func can_be_cancelled() -> bool:
	"""Check if event can be cancelled"""
	return status == GameEnums.EventStatus.SCHEDULED

func cancel_event() -> bool:
	"""Cancel this event"""
	if not can_be_cancelled():
		return false

	status = GameEnums.EventStatus.CANCELLED
	return true