# Interface contract for CharacterBackgroundPresets resource collection
# This interface defines the expected structure and behavior for the preset collection

class_name CharacterBackgroundPresetsInterface
extends Resource

## Core preset collection
@export var preset_options: Array[PresetOptionInterface]
@export var version: String

## Contract validation methods
func is_valid() -> bool:
	"""Validates that the preset collection meets all requirements"""
	if preset_options.size() != 10:
		push_error("Preset collection must contain exactly 10 options")
		return false

	var satirical_count = 0
	var ids_seen = {}

	for preset in preset_options:
		# Check for duplicate IDs
		if preset.id in ids_seen:
			push_error("Duplicate preset ID found: " + preset.id)
			return false
		ids_seen[preset.id] = true

		# Count satirical options
		if preset.is_satirical:
			satirical_count += 1

		# Validate individual preset
		if not preset.is_valid():
			push_error("Invalid preset found: " + preset.id)
			return false

	if satirical_count != 2:
		push_error("Must have exactly 2 satirical options, found: " + str(satirical_count))
		return false

	return true

func get_sorted_by_difficulty() -> Array[PresetOptionInterface]:
	"""Returns presets sorted by difficulty rating (easiest first)"""
	var sorted_presets = preset_options.duplicate()
	sorted_presets.sort_custom(func(a, b): return a.difficulty_rating < b.difficulty_rating)
	return sorted_presets

func get_preset_by_id(preset_id: String) -> PresetOptionInterface:
	"""Retrieves a specific preset by its ID"""
	for preset in preset_options:
		if preset.id == preset_id:
			return preset
	push_warning("Preset not found with ID: " + preset_id)
	return null

func get_satirical_presets() -> Array[PresetOptionInterface]:
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

	# Should have reasonable spread across difficulty range
	var unique_ratings = ratings.keys().size()
	return unique_ratings >= 5  # At least 5 different difficulty levels

func get_fallback_preset() -> PresetOptionInterface:
	"""Returns a safe fallback preset (lowest difficulty, non-satirical)"""
	var sorted = get_sorted_by_difficulty()
	for preset in sorted:
		if not preset.is_satirical:
			return preset

	# Emergency fallback - return first preset
	if preset_options.size() > 0:
		return preset_options[0]

	push_error("No valid fallback preset available")
	return null