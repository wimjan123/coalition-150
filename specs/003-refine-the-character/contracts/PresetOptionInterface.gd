# Interface contract for PresetOption resource
# This interface defines the expected structure and behavior for character background presets

class_name PresetOptionInterface
extends Resource

## Core identification and display
@export var id: String
@export var display_name: String
@export var background_text: String
@export var character_archetype: String

## Difficulty and gameplay impact
@export var difficulty_rating: int
@export var difficulty_label: String
@export var gameplay_impact: String

## Political categorization
@export var political_alignment: String
@export var is_satirical: bool

## Contract validation methods
func is_valid() -> bool:
	"""Validates that this preset option meets all contract requirements"""
	if id.is_empty() or display_name.is_empty() or background_text.is_empty():
		return false
	if difficulty_rating < 1 or difficulty_rating > 10:
		return false
	if character_archetype.is_empty():
		return false
	return true

func get_display_info() -> Dictionary:
	"""Returns formatted information for UI display"""
	return {
		"name": display_name,
		"difficulty": difficulty_label,
		"impact": gameplay_impact,
		"archetype": character_archetype,
		"is_satirical": is_satirical
	}

func matches_difficulty(target_rating: int) -> bool:
	"""Checks if this preset matches a target difficulty level"""
	return difficulty_rating == target_rating

func is_politically_aligned(alignment: String) -> bool:
	"""Checks if this preset matches a political alignment"""
	return political_alignment == alignment