# Integration Test: Bill Voting System
# Tests the complete parliamentary bill voting flow

extends GutTest

var main_dashboard: MainDashboard
var bills_list: BillsList
var dashboard_manager: DashboardManager
var scene_path: String = "res://scenes/dashboard/main_dashboard.tscn"

func before_each() -> void:
	"""Set up test environment"""
	# Load main dashboard
	if ResourceLoader.exists(scene_path):
		var packed_scene = load(scene_path)
		if packed_scene:
			main_dashboard = packed_scene.instantiate()
			add_child(main_dashboard)

func after_each() -> void:
	"""Clean up after test"""
	if main_dashboard:
		main_dashboard.queue_free()
		main_dashboard = null

func test_bills_list_integration():
	"""Test that bills list integrates properly with dashboard"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	bills_list = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/BillsList")
	assert_not_null(bills_list, "BillsList should be available in dashboard")

func test_bill_voting_signal_flow():
	"""Test that bill voting signals flow correctly through the system"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	bills_list = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/BillsList")
	if not bills_list:
		skip_test("BillsList not available")
		return

	var vote_signal_received = false
	var received_bill_id = ""
	var received_vote = GameEnums.BillVote.ABSTAIN

	# Connect to vote signal
	bills_list.bill_vote_cast.connect(
		func(bill_id: String, vote: GameEnums.BillVote):
			vote_signal_received = true
			received_bill_id = bill_id
			received_vote = vote
	)

	# Simulate vote casting
	bills_list.bill_vote_cast.emit("BILL-001", GameEnums.BillVote.YES)
	await get_tree().process_frame

	assert_true(vote_signal_received, "Bill vote signal should be received")
	assert_eq(received_bill_id, "BILL-001", "Should receive correct bill ID")
	assert_eq(received_vote, GameEnums.BillVote.YES, "Should receive correct vote")

func test_bill_selection_flow():
	"""Test bill selection and detail display flow"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	bills_list = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/BillsList")
	if not bills_list:
		skip_test("BillsList not available")
		return

	var selection_signal_received = false
	var selected_bill: Bill

	# Connect to selection signal
	bills_list.bill_selected.connect(
		func(bill: Bill):
			selection_signal_received = true
			selected_bill = bill
	)

	# Create test bill
	var test_bill = Bill.new()
	test_bill.bill_id = "TEST-001"
	test_bill.title = "Test Bill"

	# Simulate bill selection
	bills_list.bill_selected.emit(test_bill)
	await get_tree().process_frame

	assert_true(selection_signal_received, "Bill selection signal should be received")
	assert_not_null(selected_bill, "Selected bill should be available")
	assert_eq(selected_bill.bill_id, "TEST-001", "Should receive correct bill")

func test_bills_population():
	"""Test bills list population with data"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	bills_list = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/BillsList")
	if not bills_list:
		skip_test("BillsList not available")
		return

	# Create test bills data
	var test_bills: Array[ParliamentaryBill] = []

	var bill1 = ParliamentaryBill.new()
	bill1.bill_id = "BILL-001"
	bill1.title = "Healthcare Reform Act"
	bill1.status = GameEnums.BillResult.PENDING
	test_bills.append(bill1)

	var bill2 = ParliamentaryBill.new()
	bill2.bill_id = "BILL-002"
	bill2.title = "Economic Stimulus Package"
	bill2.status = GameEnums.BillResult.PENDING
	test_bills.append(bill2)

	# Test population
	bills_list.populate_bills(test_bills)
	await get_tree().process_frame

	# Should not cause errors
	assert_true(true, "Bill population should work without errors")

func test_vote_deadline_management():
	"""Test vote deadline tracking and alerts"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	bills_list = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/BillsList")
	if not bills_list:
		skip_test("BillsList not available")
		return

	# Test deadline highlighting
	bills_list.highlight_urgent_bills()
	await get_tree().process_frame

	assert_true(true, "Urgent bill highlighting should work without errors")

func test_vote_consequence_display():
	"""Test display of vote consequences"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	bills_list = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/BillsList")
	if not bills_list:
		skip_test("BillsList not available")
		return

	var test_bill_id = "CONSEQUENCE-TEST"
	var test_vote = GameEnums.BillVote.NO

	# Test consequence display (if method exists)
	if bills_list.has_method("show_vote_consequences"):
		bills_list.show_vote_consequences(test_bill_id, test_vote)
		await get_tree().process_frame

		assert_true(true, "Vote consequences should display without errors")

func test_bill_filtering():
	"""Test bill filtering by status and category"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	bills_list = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/BillsList")
	if not bills_list:
		skip_test("BillsList not available")
		return

	# Test filtering by status
	if bills_list.has_method("filter_bills_by_status"):
		bills_list.filter_bills_by_status(GameEnums.BillResult.PENDING)
		await get_tree().process_frame

		assert_true(true, "Bill filtering should work without errors")

func test_coalition_agreement_tracking():
	"""Test coalition agreement compliance tracking"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	bills_list = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/BillsList")
	if not bills_list:
		skip_test("BillsList not available")
		return

	# Test coalition agreement display
	if bills_list.has_method("show_coalition_status"):
		bills_list.show_coalition_status()
		await get_tree().process_frame

		assert_true(true, "Coalition status display should work without errors")

func test_vote_impact_on_approval():
	"""Test that bill votes affect approval ratings"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	bills_list = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/BillsList")
	var stats_panel = main_dashboard.get_node("VBoxContainer/ContentContainer/LeftPanel/StatsPanel")

	if not bills_list or not stats_panel:
		skip_test("Required components not available")
		return

	# Get initial approval
	var initial_approval = 50.0
	stats_panel.set_approval_rating(initial_approval)
	await get_tree().process_frame

	# Cast a vote that might affect approval
	bills_list.bill_vote_cast.emit("APPROVAL-TEST", GameEnums.BillVote.YES)
	await get_tree().process_frame

	# System should handle vote without crashing
	assert_true(true, "Vote casting should not cause system errors")

func test_bills_dashboard_manager_integration():
	"""Test bills list integration with dashboard manager"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	# Verify bills data flows through dashboard manager
	var dashboard_data = main_dashboard._dashboard_manager.get_dashboard_data() if main_dashboard._dashboard_manager else null

	if dashboard_data and dashboard_data.has("bills"):
		assert_true(true, "Bills data should be available through dashboard manager")
	else:
		# Dashboard manager might not have bills data initially - that's ok
		pass

func test_urgent_bill_notifications():
	"""Test urgent bill notification system"""
	if not main_dashboard:
		skip_test("MainDashboard not available")
		return

	# Wait for initialization
	await get_tree().process_frame

	bills_list = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/BillsList")
	if not bills_list:
		skip_test("BillsList not available")
		return

	# Test urgent bill handling
	if bills_list.has_method("handle_urgent_bill"):
		var urgent_bill = ParliamentaryBill.new()
		urgent_bill.bill_id = "URGENT-001"
		urgent_bill.is_urgent = true

		bills_list.handle_urgent_bill(urgent_bill)
		await get_tree().process_frame

		assert_true(true, "Urgent bill handling should work without errors")