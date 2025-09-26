# RegionalManager
# Manages campaign activities across Netherlands provinces

class_name RegionalManager
extends RefCounted

## Regional campaign signals
signal province_funding_changed(province_id: String, new_amount: int)
signal candidate_selected(province_id: String, candidate: Candidate)
signal strategy_updated(province_id: String, strategy: Strategy)
signal rally_scheduled(province_id: String, rally: Rally)
signal local_policy_adopted(province_id: String, policy: LocalPolicy)
signal support_level_changed(province_id: String, new_level: float)

var _provinces: Dictionary = {}  # String -> RegionalData
var _candidates_pool: Array[Candidate] = []
var _available_strategies: Array[Strategy] = []

func _init():
	"""Initialize regional manager with Dutch provinces"""
	_setup_provinces()
	_setup_candidates()
	_setup_strategies()

## Province management

func get_province_data(province_id: String) -> RegionalData:
	"""Get data for specific province"""
	return _provinces.get(province_id, null)

func get_all_provinces() -> Array[RegionalData]:
	"""Get all province data"""
	var provinces: Array[RegionalData] = []
	for province_data in _provinces.values():
		provinces.append(province_data)
	return provinces

func get_province_names() -> Array[String]:
	"""Get list of province names"""
	var names: Array[String] = []
	for province_id in _provinces.keys():
		var province_data = _provinces[province_id] as RegionalData
		if province_data:
			names.append(province_data.province_name)
	return names

## Campaign funding management

func allocate_funding(province_id: String, amount: int) -> bool:
	"""Allocate funding to a province"""
	if amount <= 0:
		return false

	var province_data = get_province_data(province_id)
	if not province_data:
		return false

	# Check if party can afford this
	if GameState and not GameState.can_afford(amount):
		return false

	# Allocate funding
	province_data.allocate_funding(amount)

	# Deduct from treasury
	if GameState:
		GameState.update_treasury(-amount)

	province_funding_changed.emit(province_id, province_data.campaign_funding)
	return true

func get_total_funding_allocated() -> int:
	"""Get total funding across all provinces"""
	var total := 0
	for province_data in _provinces.values():
		var data = province_data as RegionalData
		if data:
			total += data.campaign_funding
	return total

func get_funding_by_province(province_id: String) -> int:
	"""Get funding allocated to specific province"""
	var province_data = get_province_data(province_id)
	if province_data:
		return province_data.campaign_funding
	return 0

func redistribute_funding(from_province: String, to_province: String, amount: int) -> bool:
	"""Move funding between provinces"""
	if amount <= 0:
		return false

	var from_data = get_province_data(from_province)
	var to_data = get_province_data(to_province)

	if not from_data or not to_data:
		return false

	if from_data.campaign_funding < amount:
		return false

	from_data.remove_funding(amount)
	to_data.allocate_funding(amount)

	province_funding_changed.emit(from_province, from_data.campaign_funding)
	province_funding_changed.emit(to_province, to_data.campaign_funding)
	return true

## Candidate selection and management

func get_available_candidates(province_id: String) -> Array[Candidate]:
	"""Get candidates available for province"""
	# Return all candidates for now - could filter by region suitability
	return _candidates_pool.duplicate()

func select_candidate(province_id: String, candidate: Candidate) -> bool:
	"""Select candidate for province"""
	if not candidate or not _candidates_pool.has(candidate):
		return false

	var province_data = get_province_data(province_id)
	if not province_data:
		return false

	province_data.selected_candidate = candidate
	candidate_selected.emit(province_id, candidate)
	return true

func get_selected_candidate(province_id: String) -> Candidate:
	"""Get selected candidate for province"""
	var province_data = get_province_data(province_id)
	if province_data:
		return province_data.selected_candidate
	return null

func evaluate_candidate_fit(province_id: String, candidate: Candidate) -> float:
	"""Evaluate how well candidate fits province"""
	if not candidate:
		return 0.0

	var province_data = get_province_data(province_id)
	if not province_data:
		return 0.0

	return candidate.calculate_fit_score(province_data)

## Campaign strategy management

func set_campaign_strategy(province_id: String, strategy: Strategy) -> bool:
	"""Set campaign strategy for province"""
	if not strategy or not _available_strategies.has(strategy):
		return false

	var province_data = get_province_data(province_id)
	if not province_data:
		return false

	province_data.campaign_strategy = strategy
	strategy_updated.emit(province_id, strategy)
	return true

func get_campaign_strategy(province_id: String) -> Strategy:
	"""Get current campaign strategy for province"""
	var province_data = get_province_data(province_id)
	if province_data:
		return province_data.campaign_strategy
	return null

func get_available_strategies() -> Array[Strategy]:
	"""Get all available campaign strategies"""
	return _available_strategies.duplicate()

## Rally scheduling and management

func schedule_rally(province_id: String, rally: Rally) -> bool:
	"""Schedule a rally in province"""
	if not rally or not rally.is_valid():
		return false

	var province_data = get_province_data(province_id)
	if not province_data:
		return false

	# Check if can afford rally
	if GameState and not GameState.can_afford(rally.cost):
		return false

	# Add rally to province
	province_data.add_rally(rally)

	# Deduct cost
	if GameState:
		GameState.update_treasury(-rally.cost)

	rally_scheduled.emit(province_id, rally)
	return true

func cancel_rally(province_id: String, rally_id: String) -> bool:
	"""Cancel a scheduled rally"""
	var province_data = get_province_data(province_id)
	if not province_data:
		return false

	return province_data.remove_rally(rally_id)

func get_scheduled_rallies(province_id: String) -> Array[Rally]:
	"""Get all scheduled rallies for province"""
	var province_data = get_province_data(province_id)
	if province_data:
		return province_data.scheduled_rallies.duplicate()
	return []

func get_rally_cost(province_id: String, rally_type: String) -> int:
	"""Get cost of rally type in province"""
	match rally_type:
		"small": return 2000
		"medium": return 5000
		"large": return 10000
		_: return 1000

## Local policy management

func adopt_local_policy(province_id: String, policy: LocalPolicy) -> bool:
	"""Adopt local policy in province"""
	if not policy:
		return false

	var province_data = get_province_data(province_id)
	if not province_data:
		return false

	province_data.local_policies.append(policy)

	# Update support level based on policy
	province_data.update_support_level(policy.support_impact)

	local_policy_adopted.emit(province_id, policy)
	support_level_changed.emit(province_id, province_data.support_level)
	return true

func remove_local_policy(province_id: String, policy_id: String) -> bool:
	"""Remove local policy from province"""
	var province_data = get_province_data(province_id)
	if not province_data:
		return false

	for i in range(province_data.local_policies.size()):
		var policy = province_data.local_policies[i] as LocalPolicy
		if policy and policy.policy_id == policy_id:
			province_data.local_policies.remove_at(i)
			return true

	return false

func get_local_policies(province_id: String) -> Array[LocalPolicy]:
	"""Get local policies for province"""
	var province_data = get_province_data(province_id)
	if province_data:
		return province_data.local_policies.duplicate()
	return []

func get_policy_impact(province_id: String, policy: LocalPolicy) -> Dictionary:
	"""Get impact assessment for policy"""
	if not policy:
		return {}

	return {
		"support_change": policy.support_impact,
		"cost": 0,  # Could be enhanced
		"description": policy.description
	}

## Support level tracking

func get_support_level(province_id: String) -> float:
	"""Get current support level in province"""
	var province_data = get_province_data(province_id)
	if province_data:
		return province_data.support_level
	return 50.0

func calculate_support_change(province_id: String, actions: Array) -> float:
	"""Calculate support change from actions"""
	var change := 0.0
	for action in actions:
		# Implementation would analyze action impact
		change += 1.0  # Placeholder
	return change

func get_support_trends(province_id: String, days: int = 30) -> Array[float]:
	"""Get historical support trends"""
	# Placeholder - would return historical data
	var trends: Array[float] = []
	for i in range(days):
		trends.append(get_support_level(province_id) + randf_range(-5.0, 5.0))
	return trends

## Resource validation

func can_afford_action(province_id: String, action_cost: int) -> bool:
	"""Check if action can be afforded"""
	if GameState:
		return GameState.can_afford(action_cost)
	return false

func validate_schedule_conflicts(province_id: String, event: CalendarEvent) -> Array[String]:
	"""Check for scheduling conflicts"""
	var conflicts: Array[String] = []
	# Implementation would check against existing events
	return conflicts

## Private setup methods

func _setup_provinces() -> void:
	"""Initialize Dutch provinces"""
	var province_names = [
		["groningen", "Groningen"],
		["friesland", "Friesland"],
		["drenthe", "Drenthe"],
		["overijssel", "Overijssel"],
		["flevoland", "Flevoland"],
		["gelderland", "Gelderland"],
		["utrecht", "Utrecht"],
		["noord_holland", "Noord-Holland"],
		["zuid_holland", "Zuid-Holland"],
		["zeeland", "Zeeland"],
		["noord_brabant", "Noord-Brabant"],
		["limburg", "Limburg"]
	]

	for province_info in province_names:
		var province_data = RegionalData.new()
		province_data.province_id = province_info[0]
		province_data.province_name = province_info[1]
		province_data.support_level = randf_range(40.0, 60.0)  # Random starting support

		_provinces[province_info[0]] = province_data

func _setup_candidates() -> void:
	"""Initialize candidate pool"""
	var candidate_names = [
		"Jan van der Berg", "Maria Jansen", "Peter de Vries",
		"Anna Willems", "Tom van Dijk", "Lisa van den Berg"
	]

	for name in candidate_names:
		var candidate = Candidate.new()
		candidate.name = name
		candidate.experience_level = randi_range(1, 5)
		candidate.popularity = randf_range(30.0, 70.0)
		candidate.political_alignment = randi_range(-2, 2) as GameEnums.PoliticalAlignment

		_candidates_pool.append(candidate)

func _setup_strategies() -> void:
	"""Initialize available strategies"""
	var strategies_data = [
		["grassroots", "Grassroots Campaign", "Focus on local community engagement"],
		["media_heavy", "Media Campaign", "Heavy emphasis on media presence"],
		["policy_focused", "Policy-Focused", "Emphasize policy positions"]
	]

	for strategy_info in strategies_data:
		var strategy = Strategy.new()
		strategy.strategy_id = strategy_info[0]
		strategy.name = strategy_info[1]
		strategy.description = strategy_info[2]

		_available_strategies.append(strategy)