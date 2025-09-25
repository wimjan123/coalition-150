# CharacterBackgroundPresets resource collection for Coalition 150
# Implements CharacterBackgroundPresetsInterface contract for preset management

class_name CharacterBackgroundPresets
extends Resource

## Core preset collection
@export var preset_options: Array[PresetOption]
@export var version: String

## Validation method implementing contract requirements
func is_valid() -> bool:
	"""Validates that the preset collection meets all requirements"""
	if preset_options.size() != 10:
		push_error("Preset collection must contain exactly 10 options, found: " + str(preset_options.size()))
		return false

	var satirical_count = 0
	var ids_seen = {}
	var difficulty_ratings = {}

	for preset in preset_options:
		# Check for duplicate IDs
		if preset.id in ids_seen:
			push_error("Duplicate preset ID found: " + preset.id)
			return false
		ids_seen[preset.id] = true

		# Count satirical options
		if preset.is_satirical:
			satirical_count += 1

		# Track difficulty ratings
		difficulty_ratings[preset.difficulty_rating] = true

		# Validate individual preset
		if not preset.is_valid():
			push_error("Invalid preset found: " + preset.id)
			return false

	# Check satirical count (exactly 2 for Coalition 150)
	if satirical_count != 2:
		push_error("Must have exactly 2 satirical options, found: " + str(satirical_count))
		return false

	# Verify good difficulty distribution
	var unique_difficulties = difficulty_ratings.keys().size()
	if unique_difficulties < 5:
		push_warning("Difficulty distribution could be improved. Found " + str(unique_difficulties) + " unique levels")

	return true

func get_sorted_by_difficulty() -> Array[PresetOption]:
	"""Returns presets sorted by difficulty rating (easiest first)"""
	var sorted_presets = preset_options.duplicate()
	sorted_presets.sort_custom(func(a, b): return a.difficulty_rating < b.difficulty_rating)
	return sorted_presets

func get_preset_by_id(preset_id: String) -> PresetOption:
	"""Retrieves a specific preset by its ID"""
	for preset in preset_options:
		if preset.id == preset_id:
			return preset

	push_warning("Preset not found with ID: " + preset_id)
	return null

func get_satirical_presets() -> Array[PresetOption]:
	"""Returns only the satirical preset options"""
	var satirical = []
	for preset in preset_options:
		if preset.is_satirical:
			satirical.append(preset)
	return satirical

func get_political_balance() -> Dictionary:
	"""Returns count of presets by political alignment"""
	var balance = {}
	for preset in preset_options:
		if preset.political_alignment in balance:
			balance[preset.political_alignment] += 1
		else:
			balance[preset.political_alignment] = 1
	return balance

func validate_difficulty_progression() -> bool:
	"""Ensures difficulty ratings provide good progression coverage"""
	var ratings = {}
	for preset in preset_options:
		ratings[preset.difficulty_rating] = true

	# Should have reasonable spread across difficulty range (1-10)
	var unique_ratings = ratings.keys().size()
	return unique_ratings >= 5  # At least 5 different difficulty levels

func get_fallback_preset() -> PresetOption:
	"""Returns a safe fallback preset (lowest difficulty, non-satirical)"""
	var sorted = get_sorted_by_difficulty()
	for preset in sorted:
		if not preset.is_satirical:
			return preset

	# Emergency fallback - return first preset if no non-satirical found
	if preset_options.size() > 0:
		return preset_options[0]

	push_error("No valid fallback preset available")
	return null

## Additional utility methods for Coalition 150 specific functionality

func get_presets_by_alignment(alignment: String) -> Array[PresetOption]:
	"""Returns all presets matching a political alignment"""
	var matching = []
	for preset in preset_options:
		if preset.is_politically_aligned(alignment):
			matching.append(preset)
	return matching

func get_presets_by_difficulty_range(min_rating: int, max_rating: int) -> Array[PresetOption]:
	"""Returns presets within a difficulty range"""
	var matching = []
	for preset in preset_options:
		if preset.difficulty_rating >= min_rating and preset.difficulty_rating <= max_rating:
			matching.append(preset)
	return matching

func get_non_satirical_presets() -> Array[PresetOption]:
	"""Returns only serious/non-satirical presets"""
	var non_satirical = []
	for preset in preset_options:
		if not preset.is_satirical:
			non_satirical.append(preset)
	return non_satirical

func get_difficulty_distribution() -> Dictionary:
	"""Returns detailed difficulty distribution statistics"""
	var distribution = {
		"easy": 0,    # 1-3
		"medium": 0,  # 4-7
		"hard": 0     # 8-10
	}

	for preset in preset_options:
		match preset.difficulty_rating:
			1, 2, 3:
				distribution["easy"] += 1
			4, 5, 6, 7:
				distribution["medium"] += 1
			8, 9, 10:
				distribution["hard"] += 1

	return distribution

func export_to_dictionary() -> Dictionary:
	"""Exports preset collection to save-compatible dictionary"""
	var export_data = {
		"version": version,
		"presets": []
	}

	for preset in preset_options:
		export_data["presets"].append(preset.to_save_data())

	return export_data

func import_from_dictionary(data: Dictionary) -> bool:
	"""Imports preset collection from dictionary data"""
	if not data.has("version") or not data.has("presets"):
		push_error("Invalid preset collection data format")
		return false

	version = data["version"]
	preset_options.clear()

	for preset_data in data["presets"]:
		var preset = PresetOption.new()
		preset.id = preset_data.get("id", "")
		preset.display_name = preset_data.get("display_name", "")
		preset.character_archetype = preset_data.get("character_archetype", "")
		preset.difficulty_rating = preset_data.get("difficulty_rating", 5)
		preset.political_alignment = preset_data.get("political_alignment", "Neutral")
		preset.is_satirical = preset_data.get("is_satirical", false)

		preset_options.append(preset)

	return is_valid()

## Resource lifecycle methods

func _init():
	"""Initialize with default values"""
	preset_options = []
	version = "1.0.0"

func _validate_property(property: Dictionary) -> void:
	"""Godot editor validation for resource properties"""
	match property.name:
		"preset_options":
			property.hint = PROPERTY_HINT_TYPE_STRING
			property.hint_string = str(TYPE_ARRAY) + ":" + str(TYPE_OBJECT) + ":" + "PresetOption"

## Debug and testing utilities

func print_collection_summary():
	"""Debug helper to print collection statistics"""
	print("=== CharacterBackgroundPresets Collection Summary ===")
	print("Version: ", version)
	print("Total presets: ", preset_options.size())
	print("Valid collection: ", is_valid())

	var balance = get_political_balance()
	print("Political balance:")
	for alignment in balance.keys():
		print("  ", alignment, ": ", balance[alignment])

	var satirical = get_satirical_presets()
	print("Satirical presets: ", satirical.size())
	for preset in satirical:
		print("  ", preset.display_name)

	var difficulty_dist = get_difficulty_distribution()
	print("Difficulty distribution:")
	print("  Easy (1-3): ", difficulty_dist["easy"])
	print("  Medium (4-7): ", difficulty_dist["medium"])
	print("  Hard (8-10): ", difficulty_dist["hard"])

	print("Difficulty progression valid: ", validate_difficulty_progression())
	print("===============================================")