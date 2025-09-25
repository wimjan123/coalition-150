class_name InterviewSession extends RefCounted

# Data class tracking current interview state and player progress
# Following Godot constitution: explicit typing, <20 line functions, snake_case

enum State {
	STARTING,
	ACTIVE,
	COMPLETED
}

var current_question_id: String
var answer_history: Array[String]
var questions_answered: int
var max_questions: int
var player_preset_tags: Array[String]
var state: State
var applied_effects: Array[Dictionary]

func _init(preset_tags: Array[String] = [], maximum_questions: int = 10) -> void:
	current_question_id = ""
	answer_history = []
	questions_answered = 0
	max_questions = maximum_questions
	player_preset_tags = preset_tags.duplicate()
	state = State.STARTING
	applied_effects = []

func is_valid() -> bool:
	# Validate session state
	return max_questions > 0 and max_questions <= 10

func is_complete() -> bool:
	# Check if interview session is complete
	return state == State.COMPLETED or questions_answered >= max_questions

func can_continue() -> bool:
	# Check if interview can continue
	return state == State.ACTIVE and not is_complete()

func start_session(first_question_id: String) -> void:
	# Initialize active interview session
	current_question_id = first_question_id
	state = State.ACTIVE

func record_answer(answer_index: int, effects: Dictionary) -> void:
	# Record player's answer and applied effects
	answer_history.append(str(answer_index))
	applied_effects.append(effects)
	questions_answered += 1

func advance_to_question(next_question_id: String) -> void:
	# Move to next question in interview
	current_question_id = next_question_id

func complete_session() -> void:
	# Mark interview session as completed
	state = State.COMPLETED
	current_question_id = ""

func get_progress_percentage() -> float:
	# Get interview completion percentage
	if max_questions <= 0:
		return 0.0
	return float(questions_answered) / float(max_questions) * 100.0

func to_dictionary() -> Dictionary:
	# Convert session to dictionary for serialization
	return {
		"current_question_id": current_question_id,
		"answer_history": answer_history,
		"questions_answered": questions_answered,
		"max_questions": max_questions,
		"player_preset_tags": player_preset_tags,
		"state": state,
		"applied_effects": applied_effects,
		"is_complete": is_complete(),
		"progress_percentage": get_progress_percentage()
	}