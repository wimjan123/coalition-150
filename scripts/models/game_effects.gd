class_name GameEffects extends RefCounted

# Data class representing game state modifications from interview answers
# Following Godot constitution: explicit typing, <20 line functions, snake_case

var stats: Dictionary      # String -> int (stat changes)
var flags: Dictionary      # String -> bool (boolean flags)
var unlocks: Array[String] # Content unlocks

func _init(stat_changes: Dictionary = {}, flag_changes: Dictionary = {}, content_unlocks: Array[String] = []) -> void:
	stats = stat_changes.duplicate()
	flags = flag_changes.duplicate()
	unlocks = content_unlocks.duplicate()

func is_valid() -> bool:
	# Validate effects data
	return _validate_stats() and _validate_flags() and _validate_unlocks()

func has_effects() -> bool:
	# Check if any effects are present
	return not stats.is_empty() or not flags.is_empty() or not unlocks.is_empty()

func apply_stat_change(stat_name: String, change_value: int) -> void:
	# Add or update stat change
	stats[stat_name] = change_value

func apply_flag_change(flag_name: String, flag_value: bool) -> void:
	# Set boolean flag
	flags[flag_name] = flag_value

func add_unlock(unlock_name: String) -> void:
	# Add content unlock
	if not unlocks.has(unlock_name):
		unlocks.append(unlock_name)

func merge_with(other_effects: GameEffects) -> GameEffects:
	# Combine effects with another GameEffects instance
	var merged: GameEffects = GameEffects.new()

	# Merge stats (sum values for same keys)
	for stat_name in stats.keys():
		merged.stats[stat_name] = stats[stat_name]
	for stat_name in other_effects.stats.keys():
		merged.stats[stat_name] = merged.stats.get(stat_name, 0) + other_effects.stats[stat_name]

	# Merge flags (other effects override)
	merged.flags.merge(flags)
	merged.flags.merge(other_effects.flags)

	# Merge unlocks (combine unique values)
	merged.unlocks = unlocks.duplicate()
	for unlock in other_effects.unlocks:
		merged.add_unlock(unlock)

	return merged

func to_dictionary() -> Dictionary:
	# Convert to dictionary for serialization
	var result: Dictionary = {}

	if not stats.is_empty():
		result["stats"] = stats

	if not flags.is_empty():
		result["flags"] = flags

	if not unlocks.is_empty():
		result["unlocks"] = unlocks

	return result

static func from_dictionary(data: Dictionary) -> GameEffects:
	# Create GameEffects from dictionary data
	var stats_data: Dictionary = data.get("stats", {})
	var flags_data: Dictionary = data.get("flags", {})
	var unlocks_data: Array[String] = []

	var unlocks_array: Array = data.get("unlocks", [])
	unlocks_data.assign(unlocks_array)

	return GameEffects.new(stats_data, flags_data, unlocks_data)

# Private validation methods

func _validate_stats() -> bool:
	# Ensure all stat values are integers within reasonable range
	for stat_name in stats.keys():
		var value = stats[stat_name]
		if not (value is int) or value < -10 or value > 10:
			return false
	return true

func _validate_flags() -> bool:
	# Ensure all flag values are booleans
	for flag_name in flags.keys():
		if not (flags[flag_name] is bool):
			return false
	return true

func _validate_unlocks() -> bool:
	# Ensure all unlocks are non-empty strings
	for unlock in unlocks:
		if not (unlock is String) or unlock.is_empty():
			return false
	return true