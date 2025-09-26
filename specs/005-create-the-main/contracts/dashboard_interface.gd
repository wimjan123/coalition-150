# Dashboard Interface Contract
# Defines the public interface for the main dashboard system

class_name IDashboardManager
extends RefCounted

## Signal contracts for dashboard events
signal stats_updated(approval: float, treasury: int, seats: int, date: String)
signal time_speed_changed(speed: TimeSpeed)
signal time_paused(is_paused: bool)
signal province_selected(province_id: String)
signal bill_voted(bill_id: String, vote: BillVote)
signal event_scheduled(event: CalendarEvent)
signal news_responded(news_id: String, response: ResponseType)

## Stats Display Interface
## FR-001: System MUST display four key stats prominently and persistently
func get_current_stats() -> Dictionary:
	# Returns: {"approval": float, "treasury": int, "seats": int, "date": String}
	assert(false, "Must be implemented by concrete class")
	return {}

func update_stats_display(stats: Dictionary) -> void:
	assert(false, "Must be implemented by concrete class")

## Map Interaction Interface
## FR-002: System MUST provide interactive map for regional campaign management
func get_province_data(province_id: String) -> RegionalData:
	assert(false, "Must be implemented by concrete class")
	return null

func select_province(province_id: String) -> void:
	assert(false, "Must be implemented by concrete class")

func highlight_province(province_id: String, highlight: bool) -> void:
	assert(false, "Must be implemented by concrete class")

## Parliamentary Bills Interface
## FR-003: System MUST present list of current parliamentary bills
func get_active_bills() -> Array[ParliamentaryBill]:
	assert(false, "Must be implemented by concrete class")
	return []

func vote_on_bill(bill_id: String, vote: BillVote) -> bool:
	assert(false, "Must be implemented by concrete class")
	return false

func get_bill_details(bill_id: String) -> ParliamentaryBill:
	assert(false, "Must be implemented by concrete class")
	return null

## Calendar Interface
## FR-004: System MUST include calendar interface for scheduling
func get_scheduled_events(date_range: Array[GameDate]) -> Array[CalendarEvent]:
	assert(false, "Must be implemented by concrete class")
	return []

func schedule_event(event: CalendarEvent) -> bool:
	assert(false, "Must be implemented by concrete class")
	return false

func check_schedule_conflicts(event: CalendarEvent) -> Array[CalendarEvent]:
	assert(false, "Must be implemented by concrete class")
	return []

## News Feed Interface
## FR-005: System MUST display news feed with response options
func get_active_news() -> Array[NewsItem]:
	assert(false, "Must be implemented by concrete class")
	return []

func respond_to_news(news_id: String, response: ResponseType) -> bool:
	assert(false, "Must be implemented by concrete class")
	return false

func get_news_response_options(news_id: String) -> Array[ResponseOption]:
	assert(false, "Must be implemented by concrete class")
	return []

## Time Management Interface
## FR-006, FR-007, FR-008: Time progression controls
func pause_time() -> void:
	assert(false, "Must be implemented by concrete class")

func resume_time() -> void:
	assert(false, "Must be implemented by concrete class")

func set_time_speed(speed: TimeSpeed) -> void:
	assert(false, "Must be implemented by concrete class")

func get_current_time() -> GameDate:
	assert(false, "Must be implemented by concrete class")
	return null

func is_time_paused() -> bool:
	assert(false, "Must be implemented by concrete class")
	return false

## Character Relationships Interface
## FR-010: System MUST show character relationships
func get_character_relationships() -> Array[Character]:
	assert(false, "Must be implemented by concrete class")
	return []

func get_character_trust_level(character_id: String) -> float:
	assert(false, "Must be implemented by concrete class")
	return 0.0

func update_character_display() -> void:
	assert(false, "Must be implemented by concrete class")

## Event Notifications Interface
## FR-009: Event-driven dashboard updates
func register_for_events(subscriber: Object, event_types: Array[String]) -> void:
	assert(false, "Must be implemented by concrete class")

func unregister_from_events(subscriber: Object) -> void:
	assert(false, "Must be implemented by concrete class")

func trigger_event_update(event_type: String, data: Dictionary) -> void:
	assert(false, "Must be implemented by concrete class")