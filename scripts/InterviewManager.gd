extends Node

# InterviewManager - Autoload singleton for interview state management
# Following Godot constitution: Scene-first architecture, explicit typing, TDD-driven

signal question_changed(question_data: Dictionary)
signal interview_completed(summary: Dictionary)
signal effects_applied(effects: Dictionary)

var interview_data: InterviewData
var current_session: InterviewSession
var is_interview_active: bool = false

func _ready() -> void:
	# Initialize InterviewManager singleton
	interview_data = InterviewData.new()
	current_session = null

	# Connect to any required game state systems here
	_setup_logging()

func load_interview_data(file_path: String) -> bool:
	# Load and validate interview data from JSON file
	var json_data: Dictionary = _load_json_file(file_path)
	if json_data.is_empty():
		_log_error("Failed to load interview data from: " + file_path)
		return false

	var validation_errors: Array[String] = interview_data.validate_interview_data(json_data)
	if not validation_errors.is_empty():
		_log_error("Interview data validation failed: " + str(validation_errors))
		return false

	var reference_errors: Array[String] = interview_data.validate_question_references(json_data)
	if not reference_errors.is_empty():
		_log_error("Question reference validation failed: " + str(reference_errors))
		return false

	return interview_data.load_from_dictionary(json_data)

func start_interview(player_preset_tags: Array[String]) -> String:
	# Initialize interview session with player context
	if interview_data.questions.is_empty():
		_log_error("No interview data loaded")
		return ""

	# Create new session
	current_session = InterviewSession.new(player_preset_tags, 10)  # Max 10 questions per spec

	# Find first question
	var first_question_id: String = _select_first_question(player_preset_tags)
	if first_question_id.is_empty():
		_log_error("No suitable first question found")
		return ""

	# Start session
	current_session.start_session(first_question_id)
	is_interview_active = true

	# Emit signal
	var question_data: Dictionary = get_current_question()
	question_changed.emit(question_data)

	_log_info("Interview started with question: " + first_question_id)
	return first_question_id

func get_current_question() -> Dictionary:
	# Returns current question data structure
	if not is_interview_active or current_session == null or current_session.current_question_id.is_empty():
		return {}

	var question: InterviewQuestion = interview_data.get_question_by_id(current_session.current_question_id)
	if question == null:
		_log_error("Current question not found: " + current_session.current_question_id)
		return {}

	return _format_question_for_ui(question)

func submit_answer(answer_index: int) -> Dictionary:
	# Process selected answer and apply effects
	if not is_interview_active or current_session == null:
		_log_error("No active interview session")
		return {}

	var question: InterviewQuestion = interview_data.get_question_by_id(current_session.current_question_id)
	if question == null or answer_index < 0 or answer_index >= question.answers.size():
		_log_error("Invalid answer selection")
		return {}

	var selected_answer: AnswerChoice = question.answers[answer_index]

	# Apply effects
	var effects_dict: Dictionary = selected_answer.effects.to_dictionary()
	_apply_game_effects(selected_answer.effects)
	effects_applied.emit(effects_dict)

	# Record answer in session
	current_session.record_answer(answer_index, effects_dict)

	# Determine next question
	var result: Dictionary = {
		"effects_applied": effects_dict,
		"is_complete": false
	}

	if selected_answer.has_next_question() and not current_session.is_complete():
		# Continue to next question
		current_session.advance_to_question(selected_answer.next_question_id)
		result["next_question_id"] = selected_answer.next_question_id

		var next_question_data: Dictionary = get_current_question()
		question_changed.emit(next_question_data)
	else:
		# Complete interview
		result["is_complete"] = true
		_complete_interview_session()

	return result

func get_session_progress() -> Dictionary:
	# Returns current session state
	if current_session == null:
		return {"questions_answered": 0, "max_questions": 0, "is_complete": true}

	return current_session.to_dictionary()

func complete_interview() -> Dictionary:
	# Finalizes interview and returns summary
	if current_session == null:
		return {}

	var summary: Dictionary = {
		"total_questions": current_session.questions_answered,
		"effects_summary": _summarize_applied_effects(),
		"completion_reason": "interview_finished"
	}

	_complete_interview_session()
	return summary

func validate_interview_data(data: Dictionary) -> Array[String]:
	# Public validation method for testing
	return interview_data.validate_interview_data(data)

func validate_question_references(data: Dictionary) -> Array[String]:
	# Public validation method for testing
	return interview_data.validate_question_references(data)

# Private helper methods

func _select_first_question(player_tags: Array[String]) -> String:
	# Select first question based on player tags
	var matching_questions: Array[String] = _filter_questions_by_tags(player_tags)

	if matching_questions.is_empty():
		# Use fallback questions
		var fallback_ids: Array[String] = interview_data.get_fallback_question_ids()
		if fallback_ids.size() > 0:
			return fallback_ids[0]
		return ""

	return matching_questions[0]

func _filter_questions_by_tags(player_tags: Array[String]) -> Array[String]:
	# Filter questions by matching tags
	var matching_questions: Array[String] = []

	for question_id in interview_data.questions.keys():
		var question: InterviewQuestion = interview_data.questions[question_id]
		if question.matches_tags(player_tags) and not question.is_fallback:
			matching_questions.append(question_id)

	return matching_questions

func _format_question_for_ui(question: InterviewQuestion) -> Dictionary:
	# Format question data for UI consumption
	var answers_data: Array[Dictionary] = []
	for answer in question.answers:
		answers_data.append({"text": answer.text})

	return {
		"id": question.id,
		"text": question.text,
		"answers": answers_data
	}

func _apply_game_effects(effects: GameEffects) -> void:
	# Apply effects to game state (placeholder - integrate with actual game state system)
	if effects.has_effects():
		_log_info("Applied effects: " + str(effects.to_dictionary()))
		# TODO: Integrate with actual game state management system

func _complete_interview_session() -> void:
	# Clean up and complete interview
	if current_session != null:
		current_session.complete_session()

	is_interview_active = false

	var summary: Dictionary = complete_interview()
	interview_completed.emit(summary)

	_log_info("Interview completed")

func _summarize_applied_effects() -> Dictionary:
	# Summarize all effects applied during interview
	if current_session == null:
		return {}

	var combined_effects: GameEffects = GameEffects.new()
	for effect_dict in current_session.applied_effects:
		var effect: GameEffects = GameEffects.from_dictionary(effect_dict)
		combined_effects = combined_effects.merge_with(effect)

	return combined_effects.to_dictionary()

func _load_json_file(file_path: String) -> Dictionary:
	# Load and parse JSON file
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		_log_error("Cannot open file: " + file_path)
		return {}

	var json_string: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(json_string)

	if parse_result != OK:
		_log_error("JSON parse error: " + json.get_error_message())
		return {}

	if not (json.data is Dictionary):
		_log_error("JSON root is not a dictionary")
		return {}

	return json.data

func _setup_logging() -> void:
	# Initialize logging system
	pass  # Placeholder for logging setup

func _log_info(message: String) -> void:
	print("[InterviewManager INFO] " + message)

func _log_error(message: String) -> void:
	print_rich("[color=red][InterviewManager ERROR] " + message + "[/color]")