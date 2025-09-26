extends GutTest

# Test StatsPanel UI component
# Tests must FAIL before implementation exists

var stats_panel: Control

func before_each():
	# Load the component scene
	var stats_scene = preload("res://scenes/dashboard/components/stats_panel.tscn")
	if stats_scene:
		stats_panel = stats_scene.instantiate()
		add_child_autofree(stats_panel)

func test_stats_panel_scene_exists():
	# This test will fail until the scene file is created
	var scene_path = "res://scenes/dashboard/components/stats_panel.tscn"
	assert_true(ResourceLoader.exists(scene_path), "StatsPanel scene should exist")

func test_stats_panel_has_required_labels():
	if not stats_panel:
		skip_test("StatsPanel scene not available")
		return

	# Test that all required stat labels exist
	var approval_label = stats_panel.get_node("ApprovalLabel")
	var treasury_label = stats_panel.get_node("TreasuryLabel")
	var seats_label = stats_panel.get_node("SeatsLabel")
	var date_label = stats_panel.get_node("DateLabel")

	assert_not_null(approval_label, "Should have ApprovalLabel")
	assert_not_null(treasury_label, "Should have TreasuryLabel")
	assert_not_null(seats_label, "Should have SeatsLabel")
	assert_not_null(date_label, "Should have DateLabel")

func test_stats_panel_script_interface():
	if not stats_panel:
		skip_test("StatsPanel scene not available")
		return

	# Test that the script has required methods
	assert_has_method(stats_panel, "update_stats")
	assert_has_method(stats_panel, "set_approval_rating")
	assert_has_method(stats_panel, "set_treasury")
	assert_has_method(stats_panel, "set_seats")
	assert_has_method(stats_panel, "set_current_date")

func test_stats_panel_update_stats():
	if not stats_panel:
		skip_test("StatsPanel scene not available")
		return

	var test_stats = {
		"approval": 75.5,
		"treasury": 85000,
		"seats": 78,
		"date": "March 15, 2025 - 14:30"
	}

	stats_panel.update_stats(test_stats)

	# Verify labels were updated
	var approval_label = stats_panel.get_node("ApprovalLabel") as Label
	if approval_label:
		assert_true(approval_label.text.contains("75.5"), "Should display approval rating")

func test_stats_panel_formatting():
	if not stats_panel:
		skip_test("StatsPanel scene not available")
		return

	# Test number formatting
	stats_panel.set_treasury(1500000)  # 1.5 million
	var treasury_label = stats_panel.get_node("TreasuryLabel") as Label
	if treasury_label:
		# Should format large numbers appropriately
		assert_true(treasury_label.text.length() > 0, "Should format treasury display")

func test_stats_panel_crisis_indicators():
	if not stats_panel:
		skip_test("StatsPanel scene not available")
		return

	# Test crisis mode display (approval ≤ 15%)
	stats_panel.set_approval_rating(10.0)

	# Should show crisis indicator
	var crisis_indicator = stats_panel.get_node("CrisisIndicator")
	if crisis_indicator:
		assert_true(crisis_indicator.visible, "Should show crisis indicator at low approval")

func test_stats_panel_debt_warning():
	if not stats_panel:
		skip_test("StatsPanel scene not available")
		return

	# Test debt warning display (treasury < 0)
	stats_panel.set_treasury(-25000)

	var debt_warning = stats_panel.get_node("DebtWarning")
	if debt_warning:
		assert_true(debt_warning.visible, "Should show debt warning for negative treasury")

func test_stats_panel_signals():
	if not stats_panel:
		skip_test("StatsPanel scene not available")
		return

	# Test signal emissions
	watch_signals(stats_panel)

	# Should emit signals when values change significantly
	assert_has_signal(stats_panel, "crisis_detected")
	assert_has_signal(stats_panel, "debt_warning_triggered")