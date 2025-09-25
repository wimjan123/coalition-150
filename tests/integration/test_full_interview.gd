extends GutTest

# End-to-end integration test for complete interview flow
# This test validates the entire interview process from start to completion

func test_complete_interview_flow_with_valid_data() -> void:
	# Test complete flow: load -> start -> answer -> complete
	var manager = get_interview_manager()

	# Step 1: Load interview data
	var load_success: bool = manager.load_interview_data("res://tests/data/mock_interview_valid.json")
	assert_true(load_success, "Should successfully load valid interview data")

	# Step 2: Start interview with player tags
	var player_tags: Array[String] = ["test_tag"]
	var first_question_id: String = manager.start_interview(player_tags)
	assert_false(first_question_id.is_empty(), "Should return first question ID")

	# Step 3: Get current question
	var current_question: Dictionary = manager.get_current_question()
	assert_false(current_question.is_empty(), "Should return current question data")
	assert_true(current_question.has("id"), "Question should have ID")
	assert_true(current_question.has("text"), "Question should have text")
	assert_true(current_question.has("answers"), "Question should have answers")

	# Step 4: Submit answer
	var answer_index: int = 0
	var answer_result: Dictionary = manager.submit_answer(answer_index)
	assert_true(answer_result.has("effects_applied"), "Should return effects applied")

	# Step 5: Check session progress
	var progress: Dictionary = manager.get_session_progress()
	assert_true(progress.has("questions_answered"), "Should track questions answered")
	assert_eq(progress.questions_answered, 1, "Should have answered 1 question")

	# Step 6: Complete interview (if applicable)
	if progress.is_complete:
		var summary: Dictionary = manager.complete_interview()
		assert_false(summary.is_empty(), "Should return interview summary")

func test_interview_with_branching_paths() -> void:
	# Test that interview follows branching paths based on answers
	var manager = get_interview_manager()
	manager.load_interview_data("res://tests/data/mock_interview_valid.json")

	# Start interview
	var player_tags: Array[String] = ["test_tag"]
	manager.start_interview(player_tags)

	# Get first question and answer to follow specific branch
	var q1: Dictionary = manager.get_current_question()
	var initial_question_id: String = q1.id

	# Submit answer that has next_question_id
	var answer_result: Dictionary = manager.submit_answer(0)
	if answer_result.has("next_question_id") and not answer_result.next_question_id.is_empty():
		var q2: Dictionary = manager.get_current_question()
		assert_ne(q2.id, initial_question_id, "Should progress to next question")

func test_interview_with_fallback_questions() -> void:
	# Test interview flow when no questions match player presets
	var manager = get_interview_manager()
	manager.load_interview_data("res://tests/data/mock_interview_valid.json")

	# Start with tags that don't match any questions
	var player_tags: Array[String] = ["non_matching_tag"]
	var first_question_id: String = manager.start_interview(player_tags)

	# Should still get a question (fallback)
	assert_false(first_question_id.is_empty(), "Should get fallback question when no matches")

	var current_question: Dictionary = manager.get_current_question()
	assert_false(current_question.is_empty(), "Should have current fallback question")

func test_interview_completion_after_max_questions() -> void:
	# Test that interview completes after maximum questions (5-10)
	var manager = get_interview_manager()
	manager.load_interview_data("res://tests/data/mock_interview_valid.json")

	var player_tags: Array[String] = ["test_tag"]
	manager.start_interview(player_tags)

	# Answer questions until completion
	var max_iterations: int = 15  # Safety limit
	var iterations: int = 0

	while iterations < max_iterations:
		var progress: Dictionary = manager.get_session_progress()
		if progress.is_complete:
			break

		var current_question: Dictionary = manager.get_current_question()
		if current_question.is_empty():
			break

		# Submit first available answer
		manager.submit_answer(0)
		iterations += 1

	var final_progress: Dictionary = manager.get_session_progress()
	assert_true(final_progress.is_complete or final_progress.questions_answered >= 5,
		"Interview should complete after reasonable number of questions")

func test_effects_application_during_interview() -> void:
	# Test that effects are properly applied during interview
	var manager = get_interview_manager()
	manager.load_interview_data("res://tests/data/mock_interview_valid.json")

	# Track effects application via signal
	var effects_received: Array[Dictionary] = []
	manager.effects_applied.connect(func(effects: Dictionary): effects_received.append(effects))

	var player_tags: Array[String] = ["test_tag"]
	manager.start_interview(player_tags)

	# Submit answer and check for effects
	var answer_result: Dictionary = manager.submit_answer(0)
	if answer_result.has("effects_applied"):
		assert_false(effects_received.is_empty(), "Should have received effects_applied signal")

func test_interview_data_validation_before_start() -> void:
	# Test that invalid data is rejected before starting interview
	var manager = get_interview_manager()

	# Try to load invalid data
	var load_success: bool = manager.load_interview_data("res://tests/data/mock_interview_invalid.json")
	assert_false(load_success, "Should reject invalid interview data")

	# Attempt to start interview should fail
	var player_tags: Array[String] = ["test_tag"]
	var first_question_id: String = manager.start_interview(player_tags)
	assert_true(first_question_id.is_empty(), "Should not start interview with invalid data")

# Helper function - will access actual InterviewManager singleton
func get_interview_manager():
	# Placeholder - will access /root/InterviewManager singleton
	# Return mock for TDD
	return InterviewManagerMock.new()

# Mock InterviewManager for integration testing
class InterviewManagerMock extends Node:

	signal question_changed(question_data: Dictionary)
	signal interview_completed(summary: Dictionary)
	signal effects_applied(effects: Dictionary)

	var current_question_data: Dictionary = {}
	var session_data: Dictionary = {"questions_answered": 0, "is_complete": false}

	func load_interview_data(file_path: String) -> bool:
		return false  # Fail for TDD

	func start_interview(player_preset_tags: Array[String]) -> String:
		return ""  # Empty for TDD

	func get_current_question() -> Dictionary:
		return {}  # Empty for TDD

	func submit_answer(answer_index: int) -> Dictionary:
		return {}  # Empty for TDD

	func get_session_progress() -> Dictionary:
		return session_data

	func complete_interview() -> Dictionary:
		return {}  # Empty for TDD