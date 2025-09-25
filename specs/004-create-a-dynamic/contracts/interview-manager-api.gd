# InterviewManager API Contract
# This file defines the expected interface for the InterviewManager autoload

class_name InterviewManagerContract

# Core interview management methods
func load_interview_data(file_path: String) -> bool:
	# Loads and validates interview data from JSON file
	# Returns true if successful, false if validation fails
	pass

func start_interview(player_preset_tags: Array[String]) -> String:
	# Initializes interview session with player context
	# Returns ID of first question to display
	pass

func get_current_question() -> Dictionary:
	# Returns current question data structure
	# Format: {id: String, text: String, answers: Array}
	pass

func submit_answer(answer_index: int) -> Dictionary:
	# Processes selected answer and applies effects
	# Returns: {next_question_id: String, effects_applied: Dictionary, is_complete: bool}
	pass

func get_session_progress() -> Dictionary:
	# Returns current session state
	# Format: {questions_answered: int, max_questions: int, is_complete: bool}
	pass

func complete_interview() -> Dictionary:
	# Finalizes interview and returns summary
	# Format: {total_questions: int, effects_summary: Dictionary, completion_reason: String}
	pass

# Data validation methods
func validate_interview_data(data: Dictionary) -> Array[String]:
	# Validates loaded interview data structure
	# Returns array of validation errors (empty if valid)
	pass

func validate_question_references(questions: Dictionary) -> Array[String]:
	# Validates all next_question_id references are valid
	# Returns array of broken references
	pass

# Interview session state
var current_session: Dictionary
var interview_data: Dictionary
var is_interview_active: bool

# Signals for UI communication
signal question_changed(question_data: Dictionary)
signal interview_completed(summary: Dictionary)
signal effects_applied(effects: Dictionary)