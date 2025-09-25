class_name InterviewQuestion extends RefCounted

# Data class representing a single interview question with metadata and branching logic
# Following Godot constitution: explicit typing, <20 line functions, snake_case

var id: String
var text: String
var tags: Array[String]
var answers: Array[AnswerChoice]
var is_fallback: bool

func _init(question_id: String = "", question_text: String = "", question_tags: Array[String] = [], question_answers: Array[AnswerChoice] = [], fallback: bool = false) -> void:
	id = question_id
	text = question_text
	tags = question_tags
	answers = question_answers
	is_fallback = fallback

func is_valid() -> bool:
	# Validate question data meets requirements
	if id.is_empty() or text.is_empty():
		return false

	if answers.size() < 2 or answers.size() > 5:
		return false

	return true

func matches_tags(player_tags: Array[String]) -> bool:
	# Check if question tags match any player tags
	if is_fallback:
		return true  # Fallback questions match everything

	for tag in tags:
		if player_tags.has(tag):
			return true

	return false

func to_dictionary() -> Dictionary:
	# Convert to dictionary for JSON serialization
	var answer_data: Array[Dictionary] = []
	for answer in answers:
		answer_data.append(answer.to_dictionary())

	return {
		"text": text,
		"tags": tags,
		"is_fallback": is_fallback,
		"answers": answer_data
	}

static func from_dictionary(question_id: String, data: Dictionary) -> InterviewQuestion:
	# Create InterviewQuestion from dictionary data
	var question_tags: Array[String] = []
	question_tags.assign(data.get("tags", []))

	var question_answers: Array[AnswerChoice] = []
	var answers_data: Array = data.get("answers", [])
	for answer_data in answers_data:
		question_answers.append(AnswerChoice.from_dictionary(answer_data))

	return InterviewQuestion.new(
		question_id,
		data.get("text", ""),
		question_tags,
		question_answers,
		data.get("is_fallback", false)
	)