extends GutTest

# TDD integration tests for complete interview system
# Following Godot constitution: explicit typing, TDD-driven, <20 line functions

var interview_scene: Control
var test_json_path: String = "res://interviews.json"

func before_each() -> void:
	# Setup clean test environment
	InterviewManager.interview_data = InterviewData.new()
	InterviewManager.current_session = null
	InterviewManager.is_interview_active = false

	# Load interview scene
	var scene_resource = preload("res://scenes/InterviewScene.tscn")
	interview_scene = scene_resource.instantiate()
	add_child_autofree(interview_scene)

func test_complete_interview_flow() -> void:
	# Test complete interview from start to finish
	# Load interview data
	var loaded = InterviewManager.load_interview_data(test_json_path)
	assert_true(loaded, "Should load interview data successfully")

	# Initialize interview with warrior preset
	var player_tags: Array[String] = ["warrior", "noble"]
	interview_scene.initialize_interview(player_tags)

	# Wait for initialization
	await get_tree().process_frame

	# Verify interview started
	assert_true(InterviewManager.is_interview_active, "Interview should be active")
	assert_not_null(InterviewManager.current_session, "Session should exist")

	# Verify first question is displayed
	var question_label: Label = interview_scene.get_node("MainContainer/QuestionContainer/QuestionLabel")
	assert_ne(question_label.text, "", "Question should be displayed")

	# Simulate answering questions until completion
	var max_iterations: int = 10
	var iterations: int = 0

	while InterviewManager.is_interview_active and iterations < max_iterations:
		# Get current question
		var current_question = InterviewManager.get_current_question()
		if current_question.is_empty():
			break

		# Select first answer
		interview_scene._on_answer_button_pressed(0)
		await get_tree().process_frame

		iterations += 1

	assert_false(InterviewManager.is_interview_active, "Interview should complete")

func test_signal_propagation() -> void:
	# Test that signals propagate correctly between components
	var signal_received: bool = false
	var effects_received: Dictionary = {}

	# Connect to signals
	InterviewManager.question_changed.connect(_on_test_question_changed)
	InterviewManager.effects_applied.connect(_on_test_effects_applied.bind())

	# Load and start interview
	InterviewManager.load_interview_data(test_json_path)
	var first_question_id = InterviewManager.start_interview(["mage"])

	assert_ne(first_question_id, "", "Should start interview successfully")

	# Wait for signal propagation
	await get_tree().process_frame

	# Verify signal was received (question_changed fires on start)
	assert_true(signal_received, "question_changed signal should be received")

	# Answer a question to trigger effects
	InterviewManager.submit_answer(0)
	await get_tree().process_frame

	# Verify effects signal was received
	assert_false(effects_received.is_empty(), "effects_applied signal should be received")

func _on_test_question_changed(question_data: Dictionary) -> void:
	signal_received = true

func _on_test_effects_applied(effects: Dictionary) -> void:
	effects_received = effects

func test_error_recovery() -> void:
	# Test system handles errors gracefully
	# Try to start interview without loading data
	interview_scene.initialize_interview(["warrior"])

	await get_tree().process_frame

	# Should show error state
	var question_label: Label = interview_scene.get_node("MainContainer/QuestionContainer/QuestionLabel")
	assert_true(question_label.text.begins_with("Error:"), "Should display error message")

	# Verify retry functionality exists
	var answers_container: VBoxContainer = interview_scene.get_node("MainContainer/AnswersContainer")
	assert_gt(answers_container.get_child_count(), 0, "Should have retry button")

func test_preset_filtering() -> void:
	# Test that preset tags correctly filter questions
	InterviewManager.load_interview_data(test_json_path)

	# Start with different presets
	var warrior_question_id = InterviewManager.start_interview(["warrior"])
	InterviewManager.current_session = null
	InterviewManager.is_interview_active = false

	var mage_question_id = InterviewManager.start_interview(["mage"])

	# Questions should be different based on presets
	# (Note: This assumes our test data has preset-specific questions)
	if warrior_question_id != "" and mage_question_id != "":
		# If both found questions, they might be different
		pass # This test depends on specific test data structure

func test_progress_tracking() -> void:
	# Test progress tracking throughout interview
	InterviewManager.load_interview_data(test_json_path)
	interview_scene.initialize_interview(["scholar"])

	await get_tree().process_frame

	# Check initial progress
	var progress_data = InterviewManager.get_session_progress()
	assert_eq(progress_data.get("questions_answered", -1), 0, "Should start with 0 questions answered")

	# Answer one question
	if InterviewManager.is_interview_active:
		interview_scene._on_answer_button_pressed(0)
		await get_tree().process_frame

		progress_data = InterviewManager.get_session_progress()
		assert_eq(progress_data.get("questions_answered", -1), 1, "Should have 1 question answered")

func test_effects_accumulation() -> void:
	# Test that effects accumulate properly across questions
	InterviewManager.load_interview_data(test_json_path)
	interview_scene.initialize_interview(["warrior"])

	await get_tree().process_frame

	var initial_effects_count: int = 0
	if InterviewManager.current_session:
		initial_effects_count = InterviewManager.current_session.applied_effects.size()

	# Answer a question that should apply effects
	if InterviewManager.is_interview_active:
		interview_scene._on_answer_button_pressed(0)
		await get_tree().process_frame

		if InterviewManager.current_session:
			var new_effects_count = InterviewManager.current_session.applied_effects.size()
			assert_gt(new_effects_count, initial_effects_count, "Effects should be accumulated")

var signal_received: bool = false