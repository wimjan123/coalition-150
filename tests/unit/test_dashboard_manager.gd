extends GutTest

# Test DashboardManager interface
# Tests must FAIL before implementation exists

var dashboard_manager: DashboardManager

func before_each():
	dashboard_manager = DashboardManager.new()

func test_dashboard_manager_exists():
	assert_not_null(dashboard_manager, "DashboardManager should be creatable")

func test_dashboard_manager_implements_interface():
	# Stats display interface
	assert_has_method(dashboard_manager, "get_current_stats")
	assert_has_method(dashboard_manager, "update_stats_display")

	# Map interaction interface
	assert_has_method(dashboard_manager, "get_province_data")
	assert_has_method(dashboard_manager, "select_province")

	# Bills interface
	assert_has_method(dashboard_manager, "get_active_bills")
	assert_has_method(dashboard_manager, "vote_on_bill")

	# Time management interface
	assert_has_method(dashboard_manager, "pause_time")
	assert_has_method(dashboard_manager, "set_time_speed")

func test_dashboard_manager_stats_display():
	var stats = dashboard_manager.get_current_stats()
	assert_not_null(stats, "Should return stats dictionary")
	assert_true(stats.has("approval"), "Should have approval rating")
	assert_true(stats.has("treasury"), "Should have treasury")
	assert_true(stats.has("seats"), "Should have seats")
	assert_true(stats.has("date"), "Should have current date")

func test_dashboard_manager_province_interaction():
	var province_data = dashboard_manager.get_province_data("noord_holland")
	assert_not_null(province_data, "Should return province data")

	# Test province selection
	dashboard_manager.select_province("noord_holland")
	# Would emit signal in real implementation

func test_dashboard_manager_bill_management():
	var active_bills = dashboard_manager.get_active_bills()
	assert_not_null(active_bills, "Should return bills array")

	# Test voting (would fail until implementation exists)
	var result = dashboard_manager.vote_on_bill("BILL-001", GameEnums.BillVote.YES)
	assert_true(result, "Should allow voting on valid bill")

func test_dashboard_manager_time_controls():
	dashboard_manager.pause_time()
	# Should call TimeManager.pause_time()

	dashboard_manager.set_time_speed(GameEnums.TimeSpeed.FAST)
	# Should call TimeManager.set_time_speed()

func test_dashboard_manager_signals():
	# Test signal emissions
	watch_signals(dashboard_manager)

	# This would be tested with actual signal emissions
	assert_has_signal(dashboard_manager, "stats_updated")
	assert_has_signal(dashboard_manager, "province_selected")
	assert_has_signal(dashboard_manager, "bill_voted")

func test_dashboard_manager_character_relationships():
	var characters = dashboard_manager.get_character_relationships()
	assert_not_null(characters, "Should return character array")

	var trust_level = dashboard_manager.get_character_trust_level("CHAR-001")
	assert_ge(trust_level, 0.0, "Trust level should be non-negative")
	assert_le(trust_level, 100.0, "Trust level should not exceed 100")

func test_dashboard_manager_event_registration():
	# Test event system integration
	var subscriber = RefCounted.new()
	var event_types = ["bill_deadline", "rally_scheduled"]

	dashboard_manager.register_for_events(subscriber, event_types)
	# Should add subscriber to event system

	dashboard_manager.unregister_from_events(subscriber)
	# Should remove subscriber from event system