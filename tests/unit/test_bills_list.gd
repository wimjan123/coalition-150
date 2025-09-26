extends GutTest

# Test BillsList UI component
# Tests must FAIL before implementation exists

var bills_list: Control

func before_each():
	var bills_scene = preload("res://scenes/dashboard/components/bills_list.tscn")
	if bills_scene:
		bills_list = bills_scene.instantiate()
		add_child_autofree(bills_list)

func test_bills_list_scene_exists():
	var scene_path = "res://scenes/dashboard/components/bills_list.tscn"
	assert_true(ResourceLoader.exists(scene_path), "BillsList scene should exist")

func test_bills_list_has_scroll_container():
	if not bills_list:
		skip_test("BillsList scene not available")
		return

	var scroll_container = bills_list.get_node("ScrollContainer")
	assert_not_null(scroll_container, "Should have ScrollContainer")

	var vbox = scroll_container.get_node("VBoxContainer")
	assert_not_null(vbox, "Should have VBoxContainer for bill items")

func test_bills_list_script_interface():
	if not bills_list:
		skip_test("BillsList scene not available")
		return

	assert_has_method(bills_list, "populate_bills")
	assert_has_method(bills_list, "add_bill_item")
	assert_has_method(bills_list, "clear_bills")
	assert_has_method(bills_list, "update_bill_status")

func test_bills_list_bill_management():
	if not bills_list:
		skip_test("BillsList scene not available")
		return

	var test_bill = ParliamentaryBill.new()
	test_bill.bill_id = "BILL-001"
	test_bill.title = "Test Healthcare Bill"
	test_bill.summary = "Test bill summary"

	bills_list.add_bill_item(test_bill)

	var bill_items = bills_list.get_node("ScrollContainer/VBoxContainer").get_children()
	assert_gt(bill_items.size(), 0, "Should add bill item")

func test_bills_list_voting_interface():
	if not bills_list:
		skip_test("BillsList scene not available")
		return

	watch_signals(bills_list)

	# Should emit signal when bill is voted on
	assert_has_signal(bills_list, "bill_voted")
	assert_has_signal(bills_list, "bill_details_requested")

func test_bills_list_filtering():
	if not bills_list:
		skip_test("BillsList scene not available")
		return

	assert_has_method(bills_list, "filter_by_status")
	assert_has_method(bills_list, "filter_by_deadline")

func test_bills_list_urgency_indicators():
	if not bills_list:
		skip_test("BillsList scene not available")
		return

	# Should highlight urgent bills (near deadline)
	assert_has_method(bills_list, "highlight_urgent_bills")