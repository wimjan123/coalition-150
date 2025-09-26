# GameState Resource
# Core game state management for dashboard display

class_name GameState
extends Resource

@export var approval_rating: float = 50.0  # 0.0-100.0
@export var party_treasury: int = 100000   # Currency amount
@export var seats_in_parliament: int = 75  # Number of seats
@export var current_date: GameDate         # In-game date/time
@export var time_speed: GameEnums.TimeSpeed = GameEnums.TimeSpeed.NORMAL
@export var is_paused: bool = false

func _init():
	"""Initialize with default game date"""
	if not current_date:
		current_date = GameDate.new()

func is_valid() -> bool:
	"""Validate game state values"""
	if approval_rating < 0.0 or approval_rating > 100.0:
		return false

	if seats_in_parliament < 0 or seats_in_parliament > 150:
		return false

	if not current_date:
		return false

	return true

func get_stats_dictionary() -> Dictionary:
	"""Get current stats as dictionary for UI display"""
	return {
		"approval": approval_rating,
		"treasury": party_treasury,
		"seats": seats_in_parliament,
		"date": current_date.to_display_string() if current_date else "Unknown"
	}

func update_approval_rating(change: float) -> void:
	"""Update approval rating with bounds checking"""
	approval_rating = clampf(approval_rating + change, 0.0, 100.0)

func update_treasury(change: int) -> void:
	"""Update party treasury (can go negative)"""
	party_treasury += change

func update_seats(change: int) -> void:
	"""Update parliamentary seats with bounds checking"""
	seats_in_parliament = clampi(seats_in_parliament + change, 0, 150)

func can_afford(cost: int) -> bool:
	"""Check if party can afford a specific cost"""
	return party_treasury >= cost

func is_in_crisis() -> bool:
	"""Check if party is in crisis mode (approval ≤ 15%)"""
	return approval_rating <= 15.0

func has_special_opportunities() -> bool:
	"""Check if party has special opportunities (approval ≥ 85%)"""
	return approval_rating >= 85.0

func has_debt_warning() -> bool:
	"""Check if party has debt warning (treasury < 0)"""
	return party_treasury < 0

func needs_emergency_fundraising() -> bool:
	"""Check if party needs emergency fundraising (treasury < -50,000)"""
	return party_treasury < -50000