# InterviewResponse - Individual interview question response data
# Stores player's answer to a specific media interview question

class_name InterviewResponse
extends Resource

# Unique identifier for the question
@export var question_id: String = ""

# The actual question text shown to player
@export var question_text: String = ""

# Player's selected answer text
@export var selected_answer: String = ""

# Index of the selected answer (for multiple choice)
@export var answer_index: int = -1

# Timestamp when answer was given
@export var answered_at: String = ""

# Optional: Question category (experience, policy, backstory)
@export var question_category: String = ""

func _init(p_question_id: String = "", p_question_text: String = "", p_answer: String = "", p_index: int = -1) -> void:
	question_id = p_question_id
	question_text = p_question_text
	selected_answer = p_answer
	answer_index = p_index
	answered_at = Time.get_datetime_string_from_system()

# Set the player's response
func set_response(answer_text: String, index: int) -> void:
	if answer_text.is_empty():
		push_error("Answer text cannot be empty")
		return

	if index < 0:
		push_error("Answer index must be non-negative")
		return

	selected_answer = answer_text
	answer_index = index
	answered_at = Time.get_datetime_string_from_system()
	emit_changed()

# Update question information
func set_question_info(id: String, text: String, category: String = "") -> void:
	if id.is_empty():
		push_error("Question ID cannot be empty")
		return

	if text.is_empty():
		push_error("Question text cannot be empty")
		return

	question_id = id
	question_text = text
	question_category = category
	emit_changed()

# Check if response has been answered
func is_answered() -> bool:
	return not selected_answer.is_empty() and answer_index >= 0

# Get response summary for display
func get_response_summary() -> String:
	if not is_answered():
		return "Not answered"

	return "Q: " + question_text + "\nA: " + selected_answer

# Get response for analytics/scoring
func get_response_data() -> Dictionary:
	return {
		"question_id": question_id,
		"question_text": question_text,
		"answer": selected_answer,
		"answer_index": answer_index,
		"category": question_category,
		"timestamp": answered_at,
		"is_answered": is_answered()
	}

# Validate interview response data
func validate() -> bool:
	# Check required fields
	if question_id.is_empty():
		push_error("Question ID is required")
		return false

	if question_text.is_empty():
		push_error("Question text is required")
		return false

	# If response is marked as answered, validate answer data
	if is_answered():
		if selected_answer.is_empty():
			push_error("Selected answer cannot be empty for answered question")
			return false

		if answer_index < 0:
			push_error("Answer index must be non-negative for answered question")
			return false

	return true

# Clear the response (for re-answering)
func clear_response() -> void:
	selected_answer = ""
	answer_index = -1
	answered_at = ""
	emit_changed()

# Check if this response matches a specific question
func matches_question(id: String) -> bool:
	return question_id == id

# Get formatted display text for UI
func get_display_text() -> String:
	if not is_answered():
		return question_text + "\n[Not answered]"

	return question_text + "\n→ " + selected_answer

# Clone response for editing
func duplicate_response() -> InterviewResponse:
	var copy: InterviewResponse = InterviewResponse.new(question_id, question_text, selected_answer, answer_index)
	copy.question_category = question_category
	copy.answered_at = answered_at
	return copy