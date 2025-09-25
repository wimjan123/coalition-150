class_name AnswerChoice extends RefCounted

# Data class representing a player's response option with effects and branching
# Following Godot constitution: explicit typing, <20 line functions, snake_case

var text: String
var effects: GameEffects
var next_question_id: String

func _init(answer_text: String = "", answer_effects: GameEffects = null, next_id: String = "") -> void:
	text = answer_text
	effects = answer_effects if answer_effects != null else GameEffects.new()
	next_question_id = next_id

func is_valid() -> bool:
	# Validate answer data meets requirements
	if text.is_empty():
		return false

	return effects != null and effects.is_valid()

func has_next_question() -> bool:
	# Check if answer leads to another question
	return not next_question_id.is_empty()

func to_dictionary() -> Dictionary:
	# Convert to dictionary for JSON serialization
	var result: Dictionary = {
		"text": text,
		"effects": effects.to_dictionary()
	}

	if has_next_question():
		result["next_question_id"] = next_question_id

	return result

static func from_dictionary(data: Dictionary) -> AnswerChoice:
	# Create AnswerChoice from dictionary data
	var answer_effects: GameEffects = GameEffects.from_dictionary(data.get("effects", {}))

	return AnswerChoice.new(
		data.get("text", ""),
		answer_effects,
		data.get("next_question_id", "")
	)