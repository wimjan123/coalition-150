# BillsList Component
# Displays parliamentary bills with voting interface

class_name BillsList
extends Control

signal bill_voted(bill_id: String, vote: GameEnums.BillVote)
signal bill_details_requested(bill_id: String)

@onready var scroll_container: ScrollContainer = $VBoxContainer/ScrollContainer
@onready var vbox_container: VBoxContainer = $VBoxContainer/ScrollContainer/VBoxContainer
@onready var filter_button: OptionButton = $VBoxContainer/HeaderContainer/FilterButton

var _bills: Array[ParliamentaryBill] = []
var _bill_items: Array[Control] = []

func _ready() -> void:
	"""Initialize bills list"""
	filter_button.item_selected.connect(_on_filter_changed)
	_populate_sample_bills()

func populate_bills(bills: Array[ParliamentaryBill]) -> void:
	"""Populate bills list with data"""
	_bills = bills
	_refresh_display()

func add_bill_item(bill: ParliamentaryBill) -> void:
	"""Add single bill to the list"""
	if not bill:
		return

	_bills.append(bill)
	_create_bill_item(bill)

func clear_bills() -> void:
	"""Clear all bills from list"""
	_bills.clear()
	for item in _bill_items:
		if item:
			item.queue_free()
	_bill_items.clear()

func update_bill_status(bill_id: String, status: GameEnums.BillResult) -> void:
	"""Update bill status display"""
	for i in range(_bills.size()):
		if _bills[i].bill_id == bill_id:
			_bills[i].vote_result = status
			_refresh_display()
			break

func filter_by_status(status: String) -> void:
	"""Filter bills by status"""
	_refresh_display()

func filter_by_deadline() -> void:
	"""Filter bills by urgency (near deadline)"""
	_refresh_display()

func highlight_urgent_bills() -> void:
	"""Highlight bills with urgent deadlines"""
	for i in range(_bill_items.size()):
		var bill_item = _bill_items[i]
		var bill = _bills[i] if i < _bills.size() else null

		if bill and bill.is_urgent():
			bill_item.modulate = Color.ORANGE

## Private Methods

func _refresh_display() -> void:
	"""Refresh the bills display"""
	# Clear existing items
	for item in _bill_items:
		if item:
			item.queue_free()
	_bill_items.clear()

	# Create filtered items
	var filtered_bills = _get_filtered_bills()
	for bill in filtered_bills:
		_create_bill_item(bill)

func _create_bill_item(bill: ParliamentaryBill) -> void:
	"""Create a bill item UI"""
	var bill_item = _create_bill_container()

	# Title
	var title_label = Label.new()
	title_label.text = bill.title
	title_label.add_theme_font_size_override("font_size", 16)
	bill_item.add_child(title_label)

	# Summary
	var summary_label = Label.new()
	summary_label.text = bill.summary
	summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bill_item.add_child(summary_label)

	# Details container
	var details_container = HBoxContainer.new()
	bill_item.add_child(details_container)

	# Position label
	var position_label = Label.new()
	position_label.text = "Position: %s" % bill.get_position_description()
	details_container.add_child(position_label)

	# Public opinion
	var opinion_label = Label.new()
	opinion_label.text = "Public: %s" % bill.get_public_opinion_description()
	details_container.add_child(opinion_label)

	# Voting buttons (if not voted)
	if bill.vote_cast == GameEnums.BillVote.NOT_VOTED:
		var vote_container = HBoxContainer.new()
		bill_item.add_child(vote_container)

		var yes_button = Button.new()
		yes_button.text = "Vote Yes"
		yes_button.pressed.connect(_on_vote_cast.bind(bill.bill_id, GameEnums.BillVote.YES))
		vote_container.add_child(yes_button)

		var no_button = Button.new()
		no_button.text = "Vote No"
		no_button.pressed.connect(_on_vote_cast.bind(bill.bill_id, GameEnums.BillVote.NO))
		vote_container.add_child(no_button)

		var abstain_button = Button.new()
		abstain_button.text = "Abstain"
		abstain_button.pressed.connect(_on_vote_cast.bind(bill.bill_id, GameEnums.BillVote.ABSTAIN))
		vote_container.add_child(abstain_button)
	else:
		# Show vote cast
		var vote_label = Label.new()
		vote_label.text = "Voted: %s" % bill.get_vote_description()
		bill_item.add_child(vote_label)

	vbox_container.add_child(bill_item)
	_bill_items.append(bill_item)

func _create_bill_container() -> Control:
	"""Create container for bill item"""
	var container = PanelContainer.new()
	container.custom_minimum_size = Vector2(0, 120)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	container.add_child(vbox)

	return vbox

func _get_filtered_bills() -> Array[ParliamentaryBill]:
	"""Get bills filtered by current filter"""
	var selected_filter = filter_button.selected
	var filtered: Array[ParliamentaryBill] = []

	for bill in _bills:
		match selected_filter:
			0: # All Bills
				filtered.append(bill)
			1: # Pending
				if bill.vote_cast == GameEnums.BillVote.NOT_VOTED:
					filtered.append(bill)
			2: # Urgent
				if bill.is_urgent():
					filtered.append(bill)
			3: # Voted
				if bill.vote_cast != GameEnums.BillVote.NOT_VOTED:
					filtered.append(bill)

	return filtered

func _populate_sample_bills() -> void:
	"""Populate with sample bills for testing"""
	var sample_bills: Array[ParliamentaryBill] = []

	# Sample bill 1
	var bill1 = ParliamentaryBill.new()
	bill1.bill_id = "BILL-2025-001"
	bill1.title = "Healthcare Reform Act"
	bill1.summary = "Comprehensive reform of the national healthcare system to improve accessibility and reduce costs."
	bill1.party_position = GameEnums.BillPosition.SUPPORT
	bill1.public_opinion = 65.0
	sample_bills.append(bill1)

	# Sample bill 2
	var bill2 = ParliamentaryBill.new()
	bill2.bill_id = "BILL-2025-002"
	bill2.title = "Climate Action Initiative"
	bill2.summary = "Legislation to accelerate the transition to renewable energy and meet climate targets."
	bill2.party_position = GameEnums.BillPosition.STRONGLY_SUPPORT
	bill2.public_opinion = 72.0
	sample_bills.append(bill2)

	populate_bills(sample_bills)

## Signal Handlers

func _on_vote_cast(bill_id: String, vote: GameEnums.BillVote) -> void:
	"""Handle vote cast on bill"""
	bill_voted.emit(bill_id, vote)

	# Update local bill state
	for bill in _bills:
		if bill.bill_id == bill_id:
			bill.cast_vote(vote)
			break

	_refresh_display()

func _on_filter_changed(index: int) -> void:
	"""Handle filter selection change"""
	_refresh_display()