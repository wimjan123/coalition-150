extends GutTest

# Test RegionalManager interface
# Tests must FAIL before implementation exists

var regional_manager: RegionalManager

func before_each():
	regional_manager = RegionalManager.new()

func test_regional_manager_exists():
	assert_not_null(regional_manager, "RegionalManager should be creatable")

func test_regional_manager_implements_interface():
	# Province management
	assert_has_method(regional_manager, "get_province_data")
	assert_has_method(regional_manager, "get_all_provinces")
	assert_has_method(regional_manager, "get_province_names")

	# Campaign funding
	assert_has_method(regional_manager, "allocate_funding")
	assert_has_method(regional_manager, "get_total_funding_allocated")

	# Candidate management
	assert_has_method(regional_manager, "get_available_candidates")
	assert_has_method(regional_manager, "select_candidate")

	# Strategy management
	assert_has_method(regional_manager, "set_campaign_strategy")
	assert_has_method(regional_manager, "get_campaign_strategy")

func test_regional_manager_province_management():
	var province_data = regional_manager.get_province_data("noord_holland")
	assert_not_null(province_data, "Should return province data")

	var all_provinces = regional_manager.get_all_provinces()
	assert_eq(all_provinces.size(), 12, "Should have 12 Dutch provinces")

	var province_names = regional_manager.get_province_names()
	assert_true(province_names.has("Noord-Holland"), "Should include Noord-Holland")

func test_regional_manager_funding():
	# Test funding allocation
	var result = regional_manager.allocate_funding("noord_holland", 10000)
	assert_true(result, "Should allocate funding successfully")

	var total_funding = regional_manager.get_total_funding_allocated()
	assert_ge(total_funding, 10000, "Should track total funding")

	var province_funding = regional_manager.get_funding_by_province("noord_holland")
	assert_eq(province_funding, 10000, "Should track province funding")

func test_regional_manager_candidates():
	var candidates = regional_manager.get_available_candidates("noord_holland")
	assert_not_null(candidates, "Should return candidates array")

	# Test candidate selection
	if candidates.size() > 0:
		var candidate = candidates[0]
		var result = regional_manager.select_candidate("noord_holland", candidate)
		assert_true(result, "Should select candidate successfully")

		var selected = regional_manager.get_selected_candidate("noord_holland")
		assert_eq(selected, candidate, "Should return selected candidate")

func test_regional_manager_strategies():
	var strategies = regional_manager.get_available_strategies()
	assert_not_null(strategies, "Should return strategies array")

	if strategies.size() > 0:
		var strategy = strategies[0]
		var result = regional_manager.set_campaign_strategy("noord_holland", strategy)
		assert_true(result, "Should set strategy successfully")

		var current_strategy = regional_manager.get_campaign_strategy("noord_holland")
		assert_eq(current_strategy, strategy, "Should return current strategy")

func test_regional_manager_rallies():
	var rallies = regional_manager.get_scheduled_rallies("noord_holland")
	assert_not_null(rallies, "Should return rallies array")

	# Test rally scheduling
	var rally = Rally.new()
	rally.rally_id = "RALLY-001"
	rally.location = "Amsterdam"
	rally.cost = 5000

	var result = regional_manager.schedule_rally("noord_holland", rally)
	assert_true(result, "Should schedule rally successfully")

	var cost = regional_manager.get_rally_cost("noord_holland", "large")
	assert_gt(cost, 0, "Should return rally cost")

func test_regional_manager_support_tracking():
	var support = regional_manager.get_support_level("noord_holland")
	assert_ge(support, 0.0, "Support should be non-negative")
	assert_le(support, 100.0, "Support should not exceed 100")

	var trends = regional_manager.get_support_trends("noord_holland", 30)
	assert_not_null(trends, "Should return trends array")

func test_regional_manager_validation():
	# Test resource validation
	var can_afford = regional_manager.can_afford_action("noord_holland", 1000)
	assert_ne(can_afford, null, "Should return affordability check")

	var conflicts = regional_manager.validate_schedule_conflicts("noord_holland", CalendarEvent.new())
	assert_not_null(conflicts, "Should return conflicts array")

func test_regional_manager_signals():
	# Test signal emissions
	watch_signals(regional_manager)

	assert_has_signal(regional_manager, "province_funding_changed")
	assert_has_signal(regional_manager, "candidate_selected")
	assert_has_signal(regional_manager, "strategy_updated")
	assert_has_signal(regional_manager, "rally_scheduled")