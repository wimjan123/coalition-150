# MediaInterviewInterface - Contract for media interview scene
# Defines the required interface for the MediaInterview scene

extends Control
class_name MediaInterviewInterface

# Interview progression signals
signal interview_started(character: CharacterData)
signal question_answered(question_index: int, answer: String)
signal interview_completed(responses: Array[InterviewResponse])
signal interview_cancelled()

# Navigation signals
signal proceed_to_main_game_requested()
signal return_to_creation_requested()

# Interview initialization
func start_interview(character: CharacterData) -> void:
	# Initialize interview with character data
	push_error("MediaInterviewInterface.start_interview() not implemented")

func generate_questions_for_character(character: CharacterData) -> Array[Dictionary]:
	# Generate 5 questions based on character profile
	# Returns: Array of {question_id: String, text: String, answers: Array[String]}
	push_error("MediaInterviewInterface.generate_questions_for_character() not implemented")
	return []

# Question management
func display_question(question_index: int) -> void:
	# Show specific question with answer options
	push_error("MediaInterviewInterface.display_question() not implemented")

func get_current_question() -> Dictionary:
	# Return current question data
	push_error("MediaInterviewInterface.get_current_question() not implemented")
	return {}

func get_total_questions() -> int:
	# Return total number of questions (should be 5)
	push_error("MediaInterviewInterface.get_total_questions() not implemented")
	return 0

func get_current_question_index() -> int:
	# Return index of currently displayed question
	push_error("MediaInterviewInterface.get_current_question_index() not implemented")
	return 0

# Answer handling
func submit_answer(answer_index: int) -> void:
	# Submit selected answer for current question
	push_error("MediaInterviewInterface.submit_answer() not implemented")

func get_selected_answer() -> String:
	# Return text of selected answer for current question
	push_error("MediaInterviewInterface.get_selected_answer() not implemented")
	return ""

func can_change_answer() -> bool:
	# Check if player can modify their answer
	push_error("MediaInterviewInterface.can_change_answer() not implemented")
	return false

# Navigation control
func proceed_to_next_question() -> void:
	# Move to next question in sequence
	push_error("MediaInterviewInterface.proceed_to_next_question() not implemented")

func go_back_to_previous_question() -> void:
	# Return to previous question (if allowed)
	push_error("MediaInterviewInterface.go_back_to_previous_question() not implemented")

func finish_interview() -> void:
	# Complete interview and compile responses
	push_error("MediaInterviewInterface.finish_interview() not implemented")

# UI state management
func show_question_ui() -> void:
	# Display question and answer options
	push_error("MediaInterviewInterface.show_question_ui() not implemented")

func show_summary_ui() -> void:
	# Display interview summary/completion screen
	push_error("MediaInterviewInterface.show_summary_ui() not implemented")

func update_progress_display() -> void:
	# Update progress indicator (Question X of 5)
	push_error("MediaInterviewInterface.update_progress_display() not implemented")

# Response compilation
func compile_interview_responses() -> Array[InterviewResponse]:
	# Create InterviewResponse objects from all answers
	push_error("MediaInterviewInterface.compile_interview_responses() not implemented")
	return []

func save_responses_to_character(character: CharacterData) -> void:
	# Add interview responses to character data
	push_error("MediaInterviewInterface.save_responses_to_character() not implemented")

# Validation
func validate_all_questions_answered() -> bool:
	# Check if all 5 questions have been answered
	push_error("MediaInterviewInterface.validate_all_questions_answered() not implemented")
	return false

func is_interview_complete() -> bool:
	# Check if interview can be finished
	push_error("MediaInterviewInterface.is_interview_complete() not implemented")
	return false

# Question templates (for dynamic generation)
func get_experience_questions() -> Array[Dictionary]:
	# Questions based on political experience
	push_error("MediaInterviewInterface.get_experience_questions() not implemented")
	return []

func get_policy_questions(policies: Dictionary) -> Array[Dictionary]:
	# Questions based on character's policy positions
	push_error("MediaInterviewInterface.get_policy_questions() not implemented")
	return []

func get_backstory_questions(backstory: String) -> Array[Dictionary]:
	# Questions based on character's personal history
	push_error("MediaInterviewInterface.get_backstory_questions() not implemented")
	return []

# Progress tracking
func get_interview_progress() -> float:
	# Return completion progress (0.0 to 1.0)
	push_error("MediaInterviewInterface.get_interview_progress() not implemented")
	return 0.0

func get_answers_summary() -> Array[String]:
	# Return array of all selected answers for review
	push_error("MediaInterviewInterface.get_answers_summary() not implemented")
	return []