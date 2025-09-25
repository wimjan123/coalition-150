# PresetOption resource class for character background presets
# Implements PresetOptionInterface contract for Coalition 150 political campaign game

class_name PresetOption
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

## Validation method implementing contract requirements
func is_valid() -> bool:
	"""Validates that this preset option meets all contract requirements"""
	# Check for empty required fields
	if id.is_empty() or display_name.is_empty() or background_text.is_empty():
		return false

	# Check difficulty rating bounds (1-10)
	if difficulty_rating < 1 or difficulty_rating > 10:
		return false

	# Check character archetype is not empty
	if character_archetype.is_empty():
		return false

	# Check difficulty label is not empty
	if difficulty_label.is_empty():
		return false

	# Check gameplay impact is not empty
	if gameplay_impact.is_empty():
		return false

	# Check political alignment is valid
	var valid_alignments = ["Progressive", "Conservative", "Libertarian", "Centrist", "Populist", "Neutral"]
	if not political_alignment in valid_alignments:
		return false

	return true

func get_display_info() -> Dictionary:
	"""Returns formatted information for UI display"""
	return {
		"name": display_name,
		"difficulty": difficulty_label,
		"impact": gameplay_impact,
		"archetype": character_archetype,
		"satirical": is_satirical
	}

func matches_difficulty(target_rating: int) -> bool:
	"""Checks if this preset matches a target difficulty level"""
	return difficulty_rating == target_rating

func is_politically_aligned(alignment: String) -> bool:
	"""Checks if this preset matches a political alignment"""
	return political_alignment == alignment

## Additional utility methods for Coalition 150 specific functionality

func get_full_description() -> String:
	"""Returns complete preset description for character creation"""
	var description = background_text

	if is_satirical:
		description = "[color=orange][Satirical][/color] " + description

	return description

func get_difficulty_color() -> Color:
	"""Returns color coding for difficulty level"""
	match difficulty_rating:
		1, 2, 3:
			return Color.GREEN  # Easy
		4, 5, 6, 7:
			return Color.YELLOW  # Medium
		8, 9, 10:
			return Color.RED  # Hard
		_:
			return Color.WHITE  # Default

func get_political_color() -> Color:
	"""Returns color coding for political alignment"""
	match political_alignment:
		"Progressive":
			return Color.CYAN
		"Conservative":
			return Color.BLUE
		"Libertarian":
			return Color.PURPLE
		"Centrist":
			return Color.GRAY
		"Populist":
			return Color.ORANGE
		"Neutral":
			return Color.WHITE
		_:
			return Color.WHITE

func to_save_data() -> Dictionary:
	"""Converts preset to save-compatible dictionary"""
	return {
		"id": id,
		"display_name": display_name,
		"character_archetype": character_archetype,
		"difficulty_rating": difficulty_rating,
		"political_alignment": political_alignment,
		"is_satirical": is_satirical
	}

## Resource lifecycle methods

func _init():
	"""Initialize with default values"""
	id = ""
	display_name = ""
	background_text = ""
	character_archetype = ""
	difficulty_rating = 5
	difficulty_label = "Medium"
	gameplay_impact = ""
	political_alignment = "Neutral"
	is_satirical = false

func _validate_property(property: Dictionary) -> void:
	"""Godot editor validation for resource properties"""
	match property.name:
		"difficulty_rating":
			property.hint = PROPERTY_HINT_RANGE
			property.hint_string = "1,10,1"
		"political_alignment":
			property.hint = PROPERTY_HINT_ENUM
			property.hint_string = "Progressive,Conservative,Libertarian,Centrist,Populist,Neutral"
		"difficulty_label":
			property.hint = PROPERTY_HINT_ENUM
			property.hint_string = "Very Easy,Easy,Medium,Hard,Very Hard,Expert"