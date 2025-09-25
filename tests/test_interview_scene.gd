extends GutTest

# TDD tests for InterviewScene UI - Following Godot constitution
# Test UI components, signal handling, and integration with InterviewManager

var interview_scene: Control
var interview_manager: Node

func before_each() -> void:
	# Load scene and mock InterviewManager
	var scene_resource = preload("res://scenes/InterviewScene.tscn")
	interview_scene = scene_resource.instantiate()
	add_child_autofree(interview_scene)

	# Setup mock InterviewManager data
	InterviewManager.current_session = null
	InterviewManager.is_interview_active = false

func test_scene_initializes_correctly() -> void:
	# Test that scene components are properly initialized
	assert_not_null(interview_scene.get_node("MainContainer/QuestionContainer/QuestionLabel"), "Question label should exist")
	assert_not_null(interview_scene.get_node("MainContainer/AnswersContainer"), "Answers container should exist")
	assert_not_null(interview_scene.get_node("MainContainer/ProgressContainer/ProgressBar"), "Progress bar should exist")

func test_question_display() -> void:
	# Test question and answers are displayed correctly
	var test_question: Dictionary = {
		"id": "test_q1",
		"text": "Test question text?",
		"answers": [
			{"text": "Answer 1"},
			{"text": "Answer 2"},
			{"text": "Answer 3"}
		]
	}

	interview_scene._display_question(test_question)

	# Verify question text is set
	var question_label: Label = interview_scene.get_node("MainContainer/QuestionContainer/QuestionLabel")
	assert_eq(question_label.text, "Test question text?", "Question text should be displayed")

	# Wait for UI updates
	await get_tree().process_frame

	# Verify answer buttons are created
	var answers_container: VBoxContainer = interview_scene.get_node("MainContainer/AnswersContainer")
	assert_eq(answers_container.get_child_count(), 3, "Should create 3 answer buttons")

	# Verify button text
	var button1: Button = answers_container.get_child(0)
	assert_eq(button1.text, "Answer 1", "First button text should match")

func test_answer_button_interaction() -> void:
	# Test answer button press triggers correct signals
	var test_question: Dictionary = {
		"id": "test_q1",
		"text": "Test question?",
		"answers": [{"text": "Answer 1"}, {"text": "Answer 2"}]
	}

	interview_scene._display_question(test_question)
	await get_tree().process_frame

	# Mock InterviewManager response
	InterviewManager.current_session = InterviewSession.new(["test_tag"], 5)
	InterviewManager.is_interview_active = true

	# Simulate button press
	var answers_container: VBoxContainer = interview_scene.get_node("MainContainer/AnswersContainer")
	var first_button: Button = answers_container.get_child(0)

	# Press button and verify it becomes disabled
	first_button.pressed.emit()
	await get_tree().process_frame

	assert_true(first_button.disabled, "Button should be disabled after press")

func test_progress_update() -> void:
	# Test progress bar updates correctly
	var mock_session = InterviewSession.new(["test"], 5)
	mock_session.questions_answered = 2
	InterviewManager.current_session = mock_session

	interview_scene._update_progress_display()

	var progress_bar: ProgressBar = interview_scene.get_node("MainContainer/ProgressContainer/ProgressBar")
	var progress_label: Label = interview_scene.get_node("MainContainer/ProgressContainer/ProgressLabel")

	assert_eq(progress_bar.value, 2, "Progress bar should show 2")
	assert_eq(progress_bar.max_value, 5, "Progress bar max should be 5")
	assert_eq(progress_label.text, "2 / 5 questions", "Progress label should show correct format")

func test_error_handling() -> void:
	# Test error message display
	var error_message: String = "Test error message"
	interview_scene._show_error_message(error_message)

	var question_label: Label = interview_scene.get_node("MainContainer/QuestionContainer/QuestionLabel")
	assert_eq(question_label.text, "Error: " + error_message, "Error message should be displayed")

	await get_tree().process_frame

	# Verify retry button is created
	var answers_container: VBoxContainer = interview_scene.get_node("MainContainer/AnswersContainer")
	assert_eq(answers_container.get_child_count(), 1, "Should create retry button")

	var retry_button: Button = answers_container.get_child(0)
	assert_eq(retry_button.text, "Retry", "Retry button should have correct text")

func test_completion_screen() -> void:
	# Test interview completion display
	var summary: Dictionary = {
		"total_questions": 5,
		"effects_summary": {"strength": 2, "wisdom": 1},
		"completion_reason": "interview_finished"
	}

	interview_scene._show_completion_screen(summary)

	var question_label: Label = interview_scene.get_node("MainContainer/QuestionContainer/QuestionLabel")
	assert_eq(question_label.text, "Interview Complete!", "Completion title should be displayed")

	await get_tree().process_frame

	# Verify continue button is created
	var answers_container: VBoxContainer = interview_scene.get_node("MainContainer/AnswersContainer")
	assert_eq(answers_container.get_child_count(), 1, "Should create continue button")

	var continue_button: Button = answers_container.get_child(0)
	assert_eq(continue_button.text, "Continue", "Continue button should have correct text")

func test_interview_manager_signal_connections() -> void:
	# Test that InterviewManager signals are properly connected
	var connections = InterviewManager.question_changed.get_connections()
	var scene_connected = false

	for connection in connections:
		if connection.callable.get_object() == interview_scene:
			scene_connected = true
			break

	assert_true(scene_connected, "InterviewScene should be connected to question_changed signal")

func test_button_clearing() -> void:
	# Test that previous answer buttons are cleared correctly
	var test_question: Dictionary = {
		"text": "Question 1?",
		"answers": [{"text": "Answer 1"}, {"text": "Answer 2"}]
	}

	interview_scene._display_question(test_question)
	await get_tree().process_frame

	var answers_container: VBoxContainer = interview_scene.get_node("MainContainer/AnswersContainer")
	assert_eq(answers_container.get_child_count(), 2, "Should have 2 buttons initially")

	# Display new question with different answers
	test_question.answers = [{"text": "New Answer 1"}]
	interview_scene._display_question(test_question)
	await get_tree().process_frame

	# Wait additional frame for cleanup
	await get_tree().process_frame

	assert_eq(answers_container.get_child_count(), 1, "Should have 1 button after clearing")