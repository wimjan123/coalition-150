# RegionalData Resource
# Manages campaign data for individual provinces

class_name RegionalData
extends Resource

@export var province_name: String          # e.g. "Noord-Holland"
@export var province_id: String            # e.g. "noord_holland"
@export var campaign_funding: int = 0      # Allocated funds
@export var selected_candidate: Candidate  # Campaign candidate
@export var campaign_strategy: Strategy    # Current strategy
@export var scheduled_rallies: Array[Rally] = []
@export var local_policies: Array[LocalPolicy] = []
@export var support_level: float = 50.0    # 0.0-100.0 regional support

func is_valid() -> bool:
	"""Validate regional data values"""
	if support_level < 0.0 or support_level > 100.0:
		return false

	if campaign_funding < 0:
		return false

	if province_name.is_empty() or province_id.is_empty():
		return false

	return true

func get_province_name() -> String:
	return province_name

func set_province_name(value: String) -> void:
	province_name = value

func allocate_funding(amount: int) -> bool:
	"""Allocate campaign funding to this province"""
	if amount < 0:
		return false

	campaign_funding += amount
	return true

func remove_funding(amount: int) -> bool:
	"""Remove campaign funding from this province"""
	if amount < 0 or amount > campaign_funding:
		return false

	campaign_funding -= amount
	return true

func add_rally(rally: Rally) -> void:
	"""Add a scheduled rally to this province"""
	if rally:
		scheduled_rallies.append(rally)

func remove_rally(rally_id: String) -> bool:
	"""Remove a rally by ID"""
	for i in range(scheduled_rallies.size()):
		var rally = scheduled_rallies[i] as Rally
		if rally and rally.get_rally_id() == rally_id:
			scheduled_rallies.remove_at(i)
			return true
	return false

func get_total_rally_cost() -> int:
	"""Calculate total cost of all scheduled rallies"""
	var total_cost := 0
	for rally in scheduled_rallies:
		if rally is Rally:
			total_cost += rally.cost
	return total_cost

func update_support_level(change: float) -> void:
	"""Update support level with bounds checking"""
	support_level = clampf(support_level + change, 0.0, 100.0)

func get_support_status() -> String:
	"""Get descriptive support status"""
	if support_level >= 80.0:
		return "Strong Support"
	elif support_level >= 60.0:
		return "Good Support"
	elif support_level >= 40.0:
		return "Moderate Support"
	elif support_level >= 20.0:
		return "Low Support"
	else:
		return "Very Low Support"