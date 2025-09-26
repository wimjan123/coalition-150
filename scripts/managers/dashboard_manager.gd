# DashboardManager
# Central controller for the main dashboard system

class_name DashboardManager
extends RefCounted

## Signal contracts for dashboard events
signal stats_updated(approval: float, treasury: int, seats: int, date: String)
signal time_speed_changed(speed: GameEnums.TimeSpeed)
signal time_paused(is_paused: bool)
signal province_selected(province_id: String)
signal bill_voted(bill_id: String, vote: GameEnums.BillVote)
signal event_scheduled(event: CalendarEvent)
signal news_responded(news_id: String, response: GameEnums.ResponseType)

var _regional_manager: RegionalManager
var _event_subscribers: Dictionary = {}  # Object -> Array[String]

func _init():
	"""Initialize dashboard manager"""
	_regional_manager = RegionalManager.new()
	_connect_to_autoloads()

## Stats Display Interface

func get_current_stats() -> Dictionary:
	"""Returns current game stats"""
	if GameState:
		return GameState.get_stats_dictionary()
	return {"approval": 50.0, "treasury": 100000, "seats": 75, "date": "Unknown"}

func update_stats_display(stats: Dictionary) -> void:
	"""Update stats display - emits signal for UI"""
	var approval = stats.get("approval", 0.0)
	var treasury = stats.get("treasury", 0)
	var seats = stats.get("seats", 0)
	var date = stats.get("date", "Unknown")

	stats_updated.emit(approval, treasury, seats, date)

## Map Interaction Interface

func get_province_data(province_id: String) -> RegionalData:
	"""Get data for specific province"""
	if _regional_manager:
		return _regional_manager.get_province_data(province_id)
	return null

func select_province(province_id: String) -> void:
	"""Select a province on the map"""
	province_selected.emit(province_id)

func highlight_province(province_id: String, highlight: bool) -> void:
	"""Highlight/unhighlight province on map"""
	# This would be handled by the map component
	pass

## Parliamentary Bills Interface

func get_active_bills() -> Array[ParliamentaryBill]:
	"""Get current parliamentary bills"""
	# In full implementation, this would query a bills manager
	# For now, return empty array
	var bills: Array[ParliamentaryBill] = []
	return bills

func vote_on_bill(bill_id: String, vote: GameEnums.BillVote) -> bool:
	"""Vote on a parliamentary bill"""
	# In full implementation, this would:
	# 1. Find the bill by ID
	# 2. Check if voting is allowed
	# 3. Cast the vote
	# 4. Apply consequences
	# 5. Update game state

	# For now, emit signal
	bill_voted.emit(bill_id, vote)
	return true

func get_bill_details(bill_id: String) -> ParliamentaryBill:
	"""Get detailed information about a bill"""
	# Implementation would query bills manager
	return null

## Calendar Interface

func get_scheduled_events(date_range: Array[GameDate]) -> Array[CalendarEvent]:
	"""Get events in date range"""
	var events: Array[CalendarEvent] = []
	return events

func schedule_event(event: CalendarEvent) -> bool:
	"""Schedule a new event"""
	if not event or not event.is_valid():
		return false

	# In full implementation, would:
	# 1. Check for conflicts
	# 2. Validate cost against treasury
	# 3. Add to calendar system
	# 4. Deduct cost from treasury

	event_scheduled.emit(event)
	return true

func check_schedule_conflicts(event: CalendarEvent) -> Array[CalendarEvent]:
	"""Check for scheduling conflicts"""
	var conflicts: Array[CalendarEvent] = []
	return conflicts

## News Feed Interface

func get_active_news() -> Array[NewsItem]:
	"""Get active news items"""
	var news_items: Array[NewsItem] = []
	return news_items

func respond_to_news(news_id: String, response: GameEnums.ResponseType) -> bool:
	"""Respond to a news item"""
	# In full implementation would:
	# 1. Find news item by ID
	# 2. Validate response option
	# 3. Apply consequences
	# 4. Update game state

	news_responded.emit(news_id, response)
	return true

func get_news_response_options(news_id: String) -> Array[ResponseOption]:
	"""Get available response options for news item"""
	var options: Array[ResponseOption] = []
	return options

## Time Management Interface

func pause_time() -> void:
	"""Pause game time"""
	if TimeManager:
		TimeManager.pause_time()

func resume_time() -> void:
	"""Resume game time"""
	if TimeManager:
		TimeManager.resume_time()

func set_time_speed(speed: GameEnums.TimeSpeed) -> void:
	"""Set time progression speed"""
	if TimeManager:
		TimeManager.set_time_speed(speed)

func get_current_time() -> GameDate:
	"""Get current game time"""
	if TimeManager:
		return TimeManager.get_current_time()
	return GameDate.new()

func is_time_paused() -> bool:
	"""Check if time is paused"""
	if TimeManager:
		return TimeManager.is_paused()
	return false

## Character Relationships Interface

func get_character_relationships() -> Array[Character]:
	"""Get all characters and their relationships"""
	var characters: Array[Character] = []
	return characters

func get_character_trust_level(character_id: String) -> float:
	"""Get trust level with specific character"""
	return 50.0  # Default neutral trust

func update_character_display() -> void:
	"""Update character display - handled by UI components"""
	pass

## Event Notifications Interface

func register_for_events(subscriber: Object, event_types: Array[String]) -> void:
	"""Register object for specific event types"""
	_event_subscribers[subscriber] = event_types

func unregister_from_events(subscriber: Object) -> void:
	"""Unregister object from events"""
	_event_subscribers.erase(subscriber)

func trigger_event_update(event_type: String, data: Dictionary) -> void:
	"""Trigger event update for registered subscribers"""
	for subscriber in _event_subscribers:
		var subscribed_events = _event_subscribers[subscriber] as Array[String]
		if subscribed_events.has(event_type):
			# In full implementation, would call subscriber method
			pass

## Regional Management Integration

func get_regional_manager() -> RegionalManager:
	"""Get regional manager instance"""
	return _regional_manager

## Private Methods

func _connect_to_autoloads() -> void:
	"""Connect to autoload signals"""
	if GameState:
		GameState.stats_updated.connect(_on_stats_updated)
		GameState.crisis_mode_triggered.connect(_on_crisis_triggered)
		GameState.special_opportunities_available.connect(_on_special_opportunities)

	if TimeManager:
		TimeManager.time_speed_changed.connect(_on_time_speed_changed)
		TimeManager.time_paused.connect(_on_time_paused)
		TimeManager.time_resumed.connect(_on_time_resumed)

func _on_stats_updated(stats: Dictionary) -> void:
	"""Handle stats update from GameState"""
	update_stats_display(stats)

func _on_crisis_triggered() -> void:
	"""Handle crisis mode activation"""
	trigger_event_update("crisis_mode", {"active": true})

func _on_special_opportunities() -> void:
	"""Handle special opportunities activation"""
	trigger_event_update("special_opportunities", {"available": true})

func _on_time_speed_changed(speed: GameEnums.TimeSpeed) -> void:
	"""Handle time speed change"""
	time_speed_changed.emit(speed)

func _on_time_paused() -> void:
	"""Handle time pause"""
	time_paused.emit(true)

func _on_time_resumed() -> void:
	"""Handle time resume"""
	time_paused.emit(false)