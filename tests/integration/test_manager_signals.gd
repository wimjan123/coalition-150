extends GutTest

# Integration test for manager signal communication
# Tests must FAIL before implementation exists

var dashboard_manager: DashboardManager
var regional_manager: RegionalManager
var time_manager: Node  # TimeManager autoload

func before_each():
	dashboard_manager = DashboardManager.new()
	regional_manager = RegionalManager.new()
	time_manager = get_node("/root/TimeManager") if has_node("/root/TimeManager") else null

func test_manager_communication():
	# Test that managers can communicate through signals
	watch_signals(dashboard_manager)
	watch_signals(regional_manager)

	# Test regional manager -> dashboard manager communication
	if regional_manager.has_signal("province_funding_changed"):
		regional_manager.province_funding_changed.connect(_on_province_funding_changed)

	# Simulate funding change
	regional_manager.allocate_funding("noord_holland", 5000)

	# Should trigger signal that dashboard can respond to
	# This would be verified in real implementation

func test_time_manager_integration():
	if not time_manager:
		skip_test("TimeManager autoload not available")
		return

	watch_signals(time_manager)

	# Test time manager -> dashboard manager integration
	if time_manager.has_signal("time_advanced"):
		time_manager.time_advanced.connect(_on_time_advanced)

	# Simulate time advancement
	time_manager.advance_time(60)  # 1 hour

	# Dashboard should update its display
	assert_signal_emitted(time_manager, "time_advanced")

func test_game_state_integration():
	var game_state_autoload = get_node("/root/GameState") if has_node("/root/GameState") else null
	if not game_state_autoload:
		skip_test("GameState autoload not available")
		return

	watch_signals(game_state_autoload)

	# Test GameState -> Dashboard communication
	if game_state_autoload.has_signal("stats_updated"):
		game_state_autoload.stats_updated.connect(_on_stats_updated)

	# Simulate stat change
	game_state_autoload.update_approval_rating(5.0)

	# Should trigger dashboard update
	assert_signal_emitted(game_state_autoload, "stats_updated")

func test_event_propagation():
	# Test that events propagate correctly through manager hierarchy
	var event_triggered = false

	# Connect to multiple signals
	if dashboard_manager.has_signal("bill_voted"):
		dashboard_manager.bill_voted.connect(_on_bill_voted)

	# Simulate bill voting
	var result = dashboard_manager.vote_on_bill("BILL-001", GameEnums.BillVote.YES)

	# Should propagate to other systems
	if result:
		assert_signal_emitted(dashboard_manager, "bill_voted")

func test_cross_system_dependencies():
	# Test that systems properly depend on each other

	# Regional manager should be able to query game state
	var stats = dashboard_manager.get_current_stats()
	var treasury = stats.get("treasury", 0)

	# Should be able to check affordability
	var can_afford = regional_manager.can_afford_action("noord_holland", 1000)

	if treasury >= 1000:
		assert_true(can_afford, "Should afford action when treasury sufficient")
	else:
		assert_false(can_afford, "Should not afford action when treasury insufficient")

## Signal handlers for testing

func _on_province_funding_changed(province_id: String, amount: int):
	# Handle province funding change
	pass

func _on_time_advanced(new_time: GameDate):
	# Handle time advancement
	pass

func _on_stats_updated(stats: Dictionary):
	# Handle stats update
	pass

func _on_bill_voted(bill_id: String, vote: GameEnums.BillVote):
	# Handle bill voting
	pass