# Regional Manager Interface Contract
# Defines the interface for managing campaign activities across Netherlands provinces

class_name IRegionalManager
extends RefCounted

## Regional campaign signals
signal province_funding_changed(province_id: String, new_amount: int)
signal candidate_selected(province_id: String, candidate: Candidate)
signal strategy_updated(province_id: String, strategy: Strategy)
signal rally_scheduled(province_id: String, rally: Rally)
signal local_policy_adopted(province_id: String, policy: LocalPolicy)
signal support_level_changed(province_id: String, new_level: float)

## Province management
func get_province_data(province_id: String) -> RegionalData:
	assert(false, "Must be implemented by concrete class")
	return null

func get_all_provinces() -> Array[RegionalData]:
	assert(false, "Must be implemented by concrete class")
	return []

func get_province_names() -> Array[String]:
	assert(false, "Must be implemented by concrete class")
	return []

## Campaign funding management
func allocate_funding(province_id: String, amount: int) -> bool:
	assert(false, "Must be implemented by concrete class")
	return false

func get_total_funding_allocated() -> int:
	assert(false, "Must be implemented by concrete class")
	return 0

func get_funding_by_province(province_id: String) -> int:
	assert(false, "Must be implemented by concrete class")
	return 0

func redistribute_funding(from_province: String, to_province: String, amount: int) -> bool:
	assert(false, "Must be implemented by concrete class")
	return false

## Candidate selection and management
func get_available_candidates(province_id: String) -> Array[Candidate]:
	assert(false, "Must be implemented by concrete class")
	return []

func select_candidate(province_id: String, candidate: Candidate) -> bool:
	assert(false, "Must be implemented by concrete class")
	return false

func get_selected_candidate(province_id: String) -> Candidate:
	assert(false, "Must be implemented by concrete class")
	return null

func evaluate_candidate_fit(province_id: String, candidate: Candidate) -> float:
	assert(false, "Must be implemented by concrete class")
	return 0.0

## Campaign strategy management
func set_campaign_strategy(province_id: String, strategy: Strategy) -> bool:
	assert(false, "Must be implemented by concrete class")
	return false

func get_campaign_strategy(province_id: String) -> Strategy:
	assert(false, "Must be implemented by concrete class")
	return null

func get_available_strategies() -> Array[Strategy]:
	assert(false, "Must be implemented by concrete class")
	return []

## Rally scheduling and management
func schedule_rally(province_id: String, rally: Rally) -> bool:
	assert(false, "Must be implemented by concrete class")
	return false

func cancel_rally(province_id: String, rally_id: String) -> bool:
	assert(false, "Must be implemented by concrete class")
	return false

func get_scheduled_rallies(province_id: String) -> Array[Rally]:
	assert(false, "Must be implemented by concrete class")
	return []

func get_rally_cost(province_id: String, rally_type: String) -> int:
	assert(false, "Must be implemented by concrete class")
	return 0

## Local policy management
func adopt_local_policy(province_id: String, policy: LocalPolicy) -> bool:
	assert(false, "Must be implemented by concrete class")
	return false

func remove_local_policy(province_id: String, policy_id: String) -> bool:
	assert(false, "Must be implemented by concrete class")
	return false

func get_local_policies(province_id: String) -> Array[LocalPolicy]:
	assert(false, "Must be implemented by concrete class")
	return []

func get_policy_impact(province_id: String, policy: LocalPolicy) -> Dictionary:
	assert(false, "Must be implemented by concrete class")
	return {}

## Support level tracking
func get_support_level(province_id: String) -> float:
	assert(false, "Must be implemented by concrete class")
	return 0.0

func calculate_support_change(province_id: String, actions: Array) -> float:
	assert(false, "Must be implemented by concrete class")
	return 0.0

func get_support_trends(province_id: String, days: int = 30) -> Array[float]:
	assert(false, "Must be implemented by concrete class")
	return []

## Resource validation
func can_afford_action(province_id: String, action_cost: int) -> bool:
	assert(false, "Must be implemented by concrete class")
	return false

func validate_schedule_conflicts(province_id: String, event: CalendarEvent) -> Array[String]:
	assert(false, "Must be implemented by concrete class")
	return []