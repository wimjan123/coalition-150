# Rally Resource
# Represents a political rally event

class_name Rally
extends Resource

@export var rally_id: String
@export var event_date: GameDate
@export var location: String
@export var expected_attendance: int
@export var cost: int
@export var approval_impact: float  # Expected impact
@export var status: GameEnums.RallyStatus = GameEnums.RallyStatus.SCHEDULED

func get_rally_id() -> String:
	return rally_id

func set_rally_id(value: String) -> void:
	rally_id = value

func is_valid() -> bool:
	"""Validate rally values"""
	if cost < 0:
		return false

	if expected_attendance < 0:
		return false

	if rally_id.is_empty() or location.is_empty():
		return false

	return true

func get_status_description() -> String:
	"""Get descriptive rally status"""
	match status:
		GameEnums.RallyStatus.SCHEDULED: return "Scheduled"
		GameEnums.RallyStatus.IN_PROGRESS: return "In Progress"
		GameEnums.RallyStatus.COMPLETED: return "Completed"
		GameEnums.RallyStatus.CANCELLED: return "Cancelled"
		_: return "Unknown"