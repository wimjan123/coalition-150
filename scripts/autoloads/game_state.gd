# GameState Autoload
# Global game state management and persistence

extends Node

signal stats_updated(stats: Dictionary)
signal crisis_mode_triggered()
signal special_opportunities_available()
signal debt_warning_triggered()
signal emergency_fundraising_required()

var _current_state: GameStateData
var _save_file_path: String = "user://game_save.tres"

func _ready():
	"""Initialize game state management"""
	_current_state = _create_default_state()

func get_current_state() -> GameStateData:
	"""Get current game state"""
	return _current_state

func update_state(new_state: GameStateData) -> bool:
	"""Update current state with validation"""
	if not new_state or not new_state.is_valid():
		return false

	var old_approval = _current_state.approval_rating
	var old_treasury = _current_state.party_treasury

	_current_state = new_state

	# Check for state changes that trigger events
	_check_state_triggers(old_approval, old_treasury)

	# Emit stats update
	stats_updated.emit(_current_state.get_stats_dictionary())

	return true

func create_default_state() -> GameStateData:
	"""Create a default game state"""
	return _create_default_state()

func save_game(file_path: String = "") -> int:
	"""Save current game state to file"""
	var save_path = file_path if not file_path.is_empty() else _save_file_path

	var result = ResourceSaver.save(_current_state, save_path)
	if result == OK:
		print("Game saved to: ", save_path)
	else:
		print("Failed to save game: ", result)

	return result

func load_game(file_path: String = "") -> int:
	"""Load game state from file"""
	var load_path = file_path if not file_path.is_empty() else _save_file_path

	if not FileAccess.file_exists(load_path):
		print("Save file not found: ", load_path)
		return ERR_FILE_NOT_FOUND

	var loaded_state = ResourceLoader.load(load_path) as GameStateData
	if not loaded_state:
		print("Failed to load game state from: ", load_path)
		return ERR_INVALID_DATA

	if not loaded_state.is_valid():
		print("Loaded game state is invalid")
		return ERR_INVALID_DATA

	_current_state = loaded_state
	stats_updated.emit(_current_state.get_stats_dictionary())

	print("Game loaded from: ", load_path)
	return OK

func has_save_file() -> bool:
	"""Check if save file exists"""
	return FileAccess.file_exists(_save_file_path)

## Stat update methods

func update_approval_rating(change: float) -> void:
	"""Update approval rating"""
	var old_approval = _current_state.approval_rating
	_current_state.update_approval_rating(change)

	if _current_state.approval_rating != old_approval:
		_check_approval_triggers(old_approval)
		stats_updated.emit(_current_state.get_stats_dictionary())

func update_treasury(change: int) -> void:
	"""Update party treasury"""
	var old_treasury = _current_state.party_treasury
	_current_state.update_treasury(change)

	if _current_state.party_treasury != old_treasury:
		_check_treasury_triggers(old_treasury)
		stats_updated.emit(_current_state.get_stats_dictionary())

func update_seats(change: int) -> void:
	"""Update parliamentary seats"""
	var old_seats = _current_state.seats_in_parliament
	_current_state.update_seats(change)

	if _current_state.seats_in_parliament != old_seats:
		stats_updated.emit(_current_state.get_stats_dictionary())

## State query methods

func get_approval_rating() -> float:
	"""Get current approval rating"""
	return _current_state.approval_rating

func get_party_treasury() -> int:
	"""Get current party treasury"""
	return _current_state.party_treasury

func get_seats_in_parliament() -> int:
	"""Get current seats in parliament"""
	return _current_state.seats_in_parliament

func get_current_date() -> GameDate:
	"""Get current game date"""
	return _current_state.current_date

func can_afford(cost: int) -> bool:
	"""Check if party can afford cost"""
	return _current_state.can_afford(cost)

func is_in_crisis() -> bool:
	"""Check if party is in crisis mode"""
	return _current_state.is_in_crisis()

func has_special_opportunities() -> bool:
	"""Check if party has special opportunities"""
	return _current_state.has_special_opportunities()

func has_debt_warning() -> bool:
	"""Check if party has debt warning"""
	return _current_state.has_debt_warning()

func needs_emergency_fundraising() -> bool:
	"""Check if party needs emergency fundraising"""
	return _current_state.needs_emergency_fundraising()

func get_stats_dictionary() -> Dictionary:
	"""Get stats as dictionary for UI"""
	return _current_state.get_stats_dictionary()

## Time integration

func advance_game_time(minutes: int) -> void:
	"""Advance game time (called by TimeManager)"""
	if _current_state.current_date:
		_current_state.current_date.advance_time(minutes)
		stats_updated.emit(_current_state.get_stats_dictionary())

func set_time_speed(speed: GameEnums.TimeSpeed) -> void:
	"""Update time speed in state"""
	_current_state.time_speed = speed

func set_time_paused(paused: bool) -> void:
	"""Update paused state"""
	_current_state.is_paused = paused

## Private methods

func _create_default_state() -> GameStateData:
	"""Create default game state"""
	var state = GameStateData.new()
	# Default values are set in the GameStateData resource constructor
	return state

func _check_state_triggers(old_approval: float, old_treasury: int) -> void:
	"""Check for state changes that should trigger events"""
	_check_approval_triggers(old_approval)
	_check_treasury_triggers(old_treasury)

func _check_approval_triggers(old_approval: float) -> void:
	"""Check approval rating triggers"""
	var current_approval = _current_state.approval_rating

	# Crisis mode trigger
	if old_approval > 15.0 and current_approval <= 15.0:
		crisis_mode_triggered.emit()

	# Special opportunities trigger
	if old_approval < 85.0 and current_approval >= 85.0:
		special_opportunities_available.emit()

func _check_treasury_triggers(old_treasury: int) -> void:
	"""Check treasury triggers"""
	var current_treasury = _current_state.party_treasury

	# Debt warning trigger
	if old_treasury >= 0 and current_treasury < 0:
		debt_warning_triggered.emit()

	# Emergency fundraising trigger
	if old_treasury >= -50000 and current_treasury < -50000:
		emergency_fundraising_required.emit()

func _on_time_manager_time_advanced(new_time: GameDate) -> void:
	"""Handle time advancement from TimeManager"""
	_current_state.current_date = new_time
	stats_updated.emit(_current_state.get_stats_dictionary())

func _connect_time_manager() -> void:
	"""Connect to TimeManager signals"""
	if TimeManager:
		TimeManager.time_advanced.connect(_on_time_manager_time_advanced)