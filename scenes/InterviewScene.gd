extends Control

# InterviewScene - Main UI for interview questionnaire
# Following Godot constitution: Scene-first architecture, explicit typing, TDD-driven

signal answer_selected(answer_index: int)

@onready var question_label: Label = $QuestionContainer/QuestionLabel
@onready var answers_container: VBoxContainer = $AnswersContainer
@onready var progress_bar: ProgressBar = $ProgressContainer/ProgressBar
@onready var progress_label: Label = $ProgressContainer/ProgressLabel

var current_question_data: Dictionary = {}

func _ready() -> void:
	# Connect to InterviewManager signals
	InterviewManager.question_changed.connect(_on_question_changed)
	InterviewManager.interview_completed.connect(_on_interview_completed)
	InterviewManager.effects_applied.connect(_on_effects_applied)

func initialize_interview(player_preset_tags: Array[String]) -> void:
	# Start interview with player context
	var first_question_id: String = InterviewManager.start_interview(player_preset_tags)

	if first_question_id.is_empty():
		_show_error_message("Failed to start interview")
		return

	_update_progress_display()

func _on_question_changed(question_data: Dictionary) -> void:
	# Update UI with new question data
	current_question_data = question_data
	_display_question(question_data)

func _on_interview_completed(summary: Dictionary) -> void:
	# Handle interview completion
	_show_completion_screen(summary)

func _on_effects_applied(effects: Dictionary) -> void:
	# Visual feedback for applied effects (optional animation)
	_log_info("Effects applied: " + str(effects))

func _display_question(question_data: Dictionary) -> void:
	# Display question text and answer options
	if question_data.is_empty():
		_show_error_message("No question data available")
		return

	# Update question text
	question_label.text = question_data.get("text", "Missing question text")

	# Clear previous answer buttons
	_clear_answer_buttons()

	# Create new answer buttons
	var answers: Array = question_data.get("answers", [])
	for i in answers.size():
		var answer_data: Dictionary = answers[i]
		_create_answer_button(answer_data.get("text", ""), i)

	_update_progress_display()

func _create_answer_button(text: String, index: int) -> void:
	# Create and configure answer button
	var button: Button = Button.new()
	button.text = text
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size.y = 60

	# Connect button signal
	button.pressed.connect(_on_answer_button_pressed.bind(index))

	answers_container.add_child(button)

func _on_answer_button_pressed(answer_index: int) -> void:
	# Handle answer selection
	_disable_answer_buttons()

	var result: Dictionary = InterviewManager.submit_answer(answer_index)

	if result.is_empty():
		_show_error_message("Failed to submit answer")
		_enable_answer_buttons()
		return

	# Check if interview is complete
	if result.get("is_complete", false):
		return  # Completion will be handled by signal

	# Continue to next question
	if result.has("next_question_id"):
		_log_info("Moving to question: " + result.next_question_id)

func _clear_answer_buttons() -> void:
	# Remove all answer buttons
	for child in answers_container.get_children():
		child.queue_free()

func _disable_answer_buttons() -> void:
	# Disable all answer buttons
	for child in answers_container.get_children():
		if child is Button:
			child.disabled = true

func _enable_answer_buttons() -> void:
	# Enable all answer buttons
	for child in answers_container.get_children():
		if child is Button:
			child.disabled = false

func _update_progress_display() -> void:
	# Update progress bar and label
	var progress_data: Dictionary = InterviewManager.get_session_progress()

	var current: int = progress_data.get("questions_answered", 0)
	var maximum: int = progress_data.get("max_questions", 10)

	progress_bar.max_value = maximum
	progress_bar.value = current
	progress_label.text = str(current) + " / " + str(maximum) + " questions"

func _show_completion_screen(summary: Dictionary) -> void:
	# Display interview completion screen
	question_label.text = "Interview Complete!"
	_clear_answer_buttons()

	# Show summary information
	var total_questions: int = summary.get("total_questions", 0)
	var effects_summary: Dictionary = summary.get("effects_summary", {})

	var completion_text: String = "Answered " + str(total_questions) + " questions"
	if not effects_summary.is_empty():
		completion_text += "\nEffects applied: " + str(effects_summary)

	var completion_button: Button = Button.new()
	completion_button.text = "Continue"
	completion_button.pressed.connect(_on_completion_continue_pressed)
	answers_container.add_child(completion_button)

	_log_info("Interview completed: " + str(summary))

func _on_completion_continue_pressed() -> void:
	# Handle completion button press
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _show_error_message(message: String) -> void:
	# Display error message to user
	question_label.text = "Error: " + message
	_clear_answer_buttons()

	var retry_button: Button = Button.new()
	retry_button.text = "Retry"
	retry_button.pressed.connect(_on_retry_pressed)
	answers_container.add_child(retry_button)

func _on_retry_pressed() -> void:
	# Handle retry button press
	get_tree().reload_current_scene()

func _log_info(message: String) -> void:
	print("[InterviewScene INFO] " + message)