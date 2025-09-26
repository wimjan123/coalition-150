# MainDashboard Controller
# Main dashboard that coordinates all dashboard components

class_name MainDashboard
extends Control

signal dashboard_ready
signal component_error(component: String, error: String)

# Time controls
@onready var pause_button: Button = $VBoxContainer/HeaderContainer/TimeControlsContainer/PauseButton
@onready var play_button: Button = $VBoxContainer/HeaderContainer/TimeControlsContainer/PlayButton
@onready var fast_forward_button: Button = $VBoxContainer/HeaderContainer/TimeControlsContainer/FastForwardButton
@onready var date_time_label: Label = $VBoxContainer/HeaderContainer/DateTimeLabel

# Dashboard components
@onready var stats_panel: StatsPanel = $VBoxContainer/ContentContainer/LeftPanel/StatsPanel
@onready var news_feed: NewsFeed = $VBoxContainer/ContentContainer/LeftPanel/NewsFeed
@onready var netherlands_map: NetherlandsMap = $VBoxContainer/ContentContainer/RightPanel/TopRightContainer/NetherlandsMap
@onready var calendar: Calendar = $VBoxContainer/ContentContainer/RightPanel/TopRightContainer/Calendar
@onready var bills_list: BillsList = $VBoxContainer/ContentContainer/RightPanel/BillsList

var _is_initialized: bool = false
var _dashboard_manager: DashboardManager
var _regional_manager: RegionalManager

func _ready() -> void:
	"""Initialize main dashboard"""
	_setup_time_controls()
	_initialize_managers()
	_connect_component_signals()
	_sync_with_game_state()

	dashboard_ready.emit()
	_is_initialized = true

func _initialize_managers() -> void:
	"""Initialize manager references"""
	_dashboard_manager = DashboardManager.new()
	_regional_manager = RegionalManager.new()

	# Managers are RefCounted objects, not Nodes - no need to add to scene tree

func _setup_time_controls() -> void:
	"""Setup time control button connections"""
	pause_button.pressed.connect(_on_pause_pressed)
	play_button.pressed.connect(_on_play_pressed)
	fast_forward_button.pressed.connect(_on_fast_forward_pressed)

func _connect_component_signals() -> void:
	"""Connect signals between dashboard components and managers"""
	if not _is_node_valid():
		return

	# Stats panel connections
	if stats_panel:
		stats_panel.crisis_detected.connect(_on_crisis_detected)

	# News feed connections
	if news_feed:
		news_feed.news_response_selected.connect(_on_news_response_selected)
		news_feed.news_item_expanded.connect(_on_news_item_expanded)

	# Netherlands map connections
	if netherlands_map:
		netherlands_map.province_selected.connect(_on_province_selected)
		netherlands_map.province_hovered.connect(_on_province_hovered)
		netherlands_map.campaign_action_requested.connect(_on_campaign_action_requested)

	# Calendar connections
	if calendar:
		calendar.event_scheduled.connect(_on_event_scheduled)
		calendar.event_selected.connect(_on_event_selected)
		calendar.date_selected.connect(_on_date_selected)

	# Bills list connections
	if bills_list:
		bills_list.bill_vote_cast.connect(_on_bill_vote_cast)
		bills_list.bill_selected.connect(_on_bill_selected)

	# Manager connections
	if _dashboard_manager:
		_dashboard_manager.data_updated.connect(_on_dashboard_data_updated)
		_dashboard_manager.crisis_alert.connect(_on_crisis_alert)

	if _regional_manager:
		_regional_manager.province_data_changed.connect(_on_province_data_changed)

func _sync_with_game_state() -> void:
	"""Sync all components with current game state"""
	if not TimeManager or not GameState:
		push_error("TimeManager or GameState not available")
		return

	# Update time display
	_update_time_display()

	# Load initial data for all components
	_refresh_all_components()

func _update_time_display() -> void:
	"""Update the date/time display"""
	if not TimeManager or not date_time_label:
		return

	var current_time = TimeManager.get_current_time()
	if current_time:
		date_time_label.text = current_time.to_display_string()
	else:
		date_time_label.text = "Time Unavailable"

func _refresh_all_components() -> void:
	"""Refresh data in all dashboard components"""
	if not _dashboard_manager:
		return

	var dashboard_data = _dashboard_manager.get_dashboard_data()

	# Update stats panel
	if stats_panel and dashboard_data.has("stats"):
		var stats = dashboard_data["stats"]
		stats_panel.set_approval_rating(stats.get("approval", 0.0))
		stats_panel.set_popularity_rating(stats.get("popularity", 0.0))
		stats_panel.set_economic_rating(stats.get("economy", 0.0))
		stats_panel.set_crisis_level(stats.get("crisis_level", 0))

	# Update news feed
	if news_feed and dashboard_data.has("news"):
		var news_items = dashboard_data["news"]
		news_feed.populate_news(news_items)

	# Update Netherlands map
	if netherlands_map and _regional_manager:
		var province_data = _regional_manager.get_all_province_data()
		netherlands_map.update_province_display(province_data)

	# Update calendar
	if calendar and dashboard_data.has("events"):
		var events = dashboard_data["events"]
		calendar.populate_events(events)

	# Update bills list
	if bills_list and dashboard_data.has("bills"):
		var bills = dashboard_data["bills"]
		bills_list.populate_bills(bills)

func _is_node_valid() -> bool:
	"""Check if all required nodes are available"""
	var required_nodes = [stats_panel, news_feed, netherlands_map, calendar, bills_list]

	for node in required_nodes:
		if not node:
			push_warning("Dashboard component not available: " + str(node))
			return false

	return true

func get_component_status() -> Dictionary:
	"""Get status of all dashboard components"""
	return {
		"stats_panel": stats_panel != null,
		"news_feed": news_feed != null,
		"netherlands_map": netherlands_map != null,
		"calendar": calendar != null,
		"bills_list": bills_list != null,
		"dashboard_manager": _dashboard_manager != null,
		"regional_manager": _regional_manager != null
	}

func handle_emergency_event(event_data: Dictionary) -> void:
	"""Handle emergency events that require immediate dashboard updates"""
	if not _is_initialized:
		return

	# Update stats panel if critical
	if event_data.get("affects_approval", false) and stats_panel:
		var new_approval = event_data.get("new_approval", 0.0)
		stats_panel.set_approval_rating(new_approval)

	# Add to news feed if newsworthy
	if event_data.has("news_item") and news_feed:
		news_feed.add_news_item(event_data["news_item"])

	# Update map if regional
	if event_data.has("province_id") and netherlands_map:
		var province_id = event_data["province_id"]
		netherlands_map.highlight_province(province_id, true)

## Time Control Signal Handlers

func _on_pause_pressed() -> void:
	"""Handle pause button press"""
	if TimeManager:
		TimeManager.pause_time()
		_update_time_control_states()

func _on_play_pressed() -> void:
	"""Handle play button press"""
	if TimeManager:
		TimeManager.resume_time()
		_update_time_control_states()

func _on_fast_forward_pressed() -> void:
	"""Handle fast forward button press"""
	if TimeManager:
		TimeManager.set_time_scale(3.0)  # 3x speed
		_update_time_control_states()

func _update_time_control_states() -> void:
	"""Update time control button states"""
	if not TimeManager:
		return

	var is_paused = TimeManager.is_paused()
	var time_scale = TimeManager.get_time_scale()

	pause_button.disabled = is_paused
	play_button.disabled = not is_paused and time_scale == 1.0
	fast_forward_button.disabled = not is_paused and time_scale > 1.0

## Component Signal Handlers

func _on_crisis_detected() -> void:
	"""Handle crisis detection from stats panel"""
	if _dashboard_manager:
		_dashboard_manager.handle_crisis_alert("Approval rating crisis detected")

func _on_news_response_selected(news_id: String, response: GameEnums.ResponseType) -> void:
	"""Handle news response selection"""
	if _dashboard_manager:
		_dashboard_manager.handle_news_response(news_id, response)

func _on_news_item_expanded(news_id: String) -> void:
	"""Handle news item expansion"""
	# Could trigger detailed view or additional data loading
	pass

func _on_province_selected(province_id: String) -> void:
	"""Handle province selection on map"""
	if _regional_manager:
		var province_data = _regional_manager.get_province_data(province_id)
		# Update other components with province context
		_update_province_context(province_id, province_data)

func _on_province_hovered(province_id: String) -> void:
	"""Handle province hover on map"""
	# Could show preview information
	pass

func _on_campaign_action_requested(province_id: String, action: String) -> void:
	"""Handle campaign action request"""
	if _regional_manager:
		_regional_manager.execute_campaign_action(province_id, action)

func _on_event_scheduled(event: CalendarEvent) -> void:
	"""Handle event scheduling"""
	if _dashboard_manager:
		_dashboard_manager.schedule_event(event)

func _on_event_selected(event: CalendarEvent) -> void:
	"""Handle event selection"""
	# Could show event details or trigger related updates
	pass

func _on_date_selected(date: GameDate) -> void:
	"""Handle date selection"""
	# Could filter other components by date or show day details
	pass

func _on_bill_vote_cast(bill_id: String, vote: GameEnums.BillVote) -> void:
	"""Handle bill vote casting"""
	if _dashboard_manager:
		_dashboard_manager.cast_vote(bill_id, vote)

func _on_bill_selected(bill: ParliamentaryBill) -> void:
	"""Handle bill selection"""
	# Could show bill details or update related components
	pass

## Manager Signal Handlers

func _on_dashboard_data_updated(data_type: String) -> void:
	"""Handle dashboard data updates"""
	match data_type:
		"stats":
			_refresh_stats_panel()
		"news":
			_refresh_news_feed()
		"bills":
			_refresh_bills_list()
		"events":
			_refresh_calendar()
		_:
			_refresh_all_components()

func _on_crisis_alert(alert_type: String, message: String) -> void:
	"""Handle crisis alerts from dashboard manager"""
	component_error.emit("crisis_system", alert_type + ": " + message)

func _on_province_data_changed(province_id: String, data: Dictionary) -> void:
	"""Handle province data changes"""
	if netherlands_map:
		var province_data = {}
		province_data[province_id] = data
		netherlands_map.update_province_display(province_data)

## Helper Methods

func _update_province_context(province_id: String, province_data: Dictionary) -> void:
	"""Update other components with selected province context"""
	# Filter news for province-relevant items
	# Highlight province-related calendar events
	# Show province-specific bills
	pass

func _refresh_stats_panel() -> void:
	"""Refresh only the stats panel"""
	if not stats_panel or not _dashboard_manager:
		return

	var stats_data = _dashboard_manager.get_stats_data()
	stats_panel.set_approval_rating(stats_data.get("approval", 0.0))
	stats_panel.set_popularity_rating(stats_data.get("popularity", 0.0))
	stats_panel.set_economic_rating(stats_data.get("economy", 0.0))

func _refresh_news_feed() -> void:
	"""Refresh only the news feed"""
	if not news_feed or not _dashboard_manager:
		return

	var news_data = _dashboard_manager.get_news_data()
	news_feed.populate_news(news_data)

func _refresh_bills_list() -> void:
	"""Refresh only the bills list"""
	if not bills_list or not _dashboard_manager:
		return

	var bills_data = _dashboard_manager.get_bills_data()
	bills_list.populate_bills(bills_data)

func _refresh_calendar() -> void:
	"""Refresh only the calendar"""
	if not calendar or not _dashboard_manager:
		return

	var events_data = _dashboard_manager.get_events_data()
	calendar.populate_events(events_data)