extends GutTest

# Test ParliamentaryBill resource class
# Tests must FAIL before implementation exists

func before_each():
	pass

func test_parliamentary_bill_resource_exists():
	# This test will fail until ParliamentaryBill class is implemented
	var bill = ParliamentaryBill.new()
	assert_not_null(bill, "ParliamentaryBill resource should be creatable")

func test_parliamentary_bill_has_required_fields():
	var bill = ParliamentaryBill.new()

	# Test field existence
	assert_has_method(bill, "get_title")
	assert_has_method(bill, "set_title")

	# Test default values
	assert_eq(bill.party_position, BillPosition.NEUTRAL, "Default position should be neutral")
	assert_eq(bill.public_opinion, 50.0, "Default public opinion should be 50.0")
	assert_eq(bill.vote_cast, BillVote.NOT_VOTED, "Should start not voted")
	assert_eq(bill.vote_result, BillResult.PENDING, "Should start with pending result")

func test_parliamentary_bill_setup():
	var bill = ParliamentaryBill.new()
	bill.bill_id = "BILL-2025-001"
	bill.title = "Healthcare Reform Act"
	bill.summary = "Comprehensive healthcare system reform"

	assert_eq(bill.bill_id, "BILL-2025-001", "Should store bill ID")
	assert_eq(bill.title, "Healthcare Reform Act", "Should store title")
	assert_eq(bill.summary, "Comprehensive healthcare system reform", "Should store summary")

func test_parliamentary_bill_voting():
	var bill = ParliamentaryBill.new()
	bill.party_position = BillPosition.SUPPORT
	bill.vote_cast = BillVote.YES

	assert_eq(bill.party_position, BillPosition.SUPPORT, "Should store party position")
	assert_eq(bill.vote_cast, BillVote.YES, "Should store vote cast")

func test_parliamentary_bill_consequences():
	var bill = ParliamentaryBill.new()

	# This will fail until Consequence class exists
	var consequence = Consequence.new()
	bill.predicted_consequences.append(consequence)

	assert_eq(bill.predicted_consequences.size(), 1, "Should store consequences")

func test_parliamentary_bill_validation():
	var bill = ParliamentaryBill.new()

	# Test voting before deadline
	var past_date = GameDate.new()
	past_date.day = 1
	bill.voting_deadline = past_date

	var current_date = GameDate.new()
	current_date.day = 5

	assert_false(bill.can_vote(current_date), "Should not allow voting after deadline")