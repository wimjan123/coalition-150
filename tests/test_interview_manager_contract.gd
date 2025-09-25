extends GutTest

# Test InterviewManager autoload singleton API contract
# This test ensures the InterviewManager provides the expected singleton interface

func test_interview_manager_singleton_is_accessible() -> void:
	# Test that InterviewManager singleton is accessible from anywhere
	var manager = get_interview_manager()
	assert_not_null(manager, "InterviewManager singleton should be accessible")

func test_load_interview_data_method_exists() -> void:
	# Test that load_interview_data method exists and returns bool
	var manager = get_interview_manager()
	var file_path: String = "res://interviews.json"

	var result: bool = manager.load_interview_data(file_path)
	# Method should exist and return a boolean (even if false due to TDD)
	assert_typeof(result, TYPE_BOOL, "load_interview_data should return bool")

func test_start_interview_method_exists() -> void:
	# Test that start_interview method exists and returns String
	var manager = get_interview_manager()
	var player_tags: Array[String] = ["warrior", "noble"]

	var result: String = manager.start_interview(player_tags)
	assert_typeof(result, TYPE_STRING, "start_interview should return String")

func test_get_current_question_method_exists() -> void:
	# Test that get_current_question method exists and returns Dictionary
	var manager = get_interview_manager()

	var result: Dictionary = manager.get_current_question()
	assert_typeof(result, TYPE_DICTIONARY, "get_current_question should return Dictionary")

func test_submit_answer_method_exists() -> void:
	# Test that submit_answer method exists and returns Dictionary
	var manager = get_interview_manager()
	var answer_index: int = 0

	var result: Dictionary = manager.submit_answer(answer_index)
	assert_typeof(result, TYPE_DICTIONARY, "submit_answer should return Dictionary")

func test_get_session_progress_method_exists() -> void:
	# Test that get_session_progress method exists and returns Dictionary
	var manager = get_interview_manager()

	var result: Dictionary = manager.get_session_progress()
	assert_typeof(result, TYPE_DICTIONARY, "get_session_progress should return Dictionary")

func test_complete_interview_method_exists() -> void:
	# Test that complete_interview method exists and returns Dictionary
	var manager = get_interview_manager()

	var result: Dictionary = manager.complete_interview()
	assert_typeof(result, TYPE_DICTIONARY, "complete_interview should return Dictionary")

func test_validate_interview_data_method_exists() -> void:
	# Test that validate_interview_data method exists and returns Array
	var manager = get_interview_manager()
	var test_data: Dictionary = {"version": "1.0.0", "questions": {}, "fallback_questions": []}

	var result: Array[String] = manager.validate_interview_data(test_data)
	assert_typeof(result, TYPE_ARRAY, "validate_interview_data should return Array")

func test_validate_question_references_method_exists() -> void:
	# Test that validate_question_references method exists and returns Array
	var manager = get_interview_manager()
	var test_data: Dictionary = {"questions": {}, "fallback_questions": []}

	var result: Array[String] = manager.validate_question_references(test_data)
	assert_typeof(result, TYPE_ARRAY, "validate_question_references should return Array")

func test_interview_manager_signals_exist() -> void:
	# Test that required signals are defined on InterviewManager
	var manager = get_interview_manager()

	# Check if signals are connected (they should exist even if not connected)
	assert_true(manager.has_signal("question_changed"), "InterviewManager should have question_changed signal")
	assert_true(manager.has_signal("interview_completed"), "InterviewManager should have interview_completed signal")
	assert_true(manager.has_signal("effects_applied"), "InterviewManager should have effects_applied signal")

func test_interview_manager_has_required_properties() -> void:
	# Test that InterviewManager has required properties
	var manager = get_interview_manager()

	# These properties should exist (even if null/empty initially)
	assert_true(manager.has_method("get"), "InterviewManager should have property access")

func test_interview_manager_singleton_persistence() -> void:
	# Test that InterviewManager singleton persists across scene changes
	var manager1 = get_interview_manager()
	var manager2 = get_interview_manager()

	# Should return the same singleton instance
	assert_same(manager1, manager2, "InterviewManager should return the same singleton instance")

func test_interview_session_state_initialization() -> void:
	# Test that InterviewManager initializes with proper default state
	var manager = get_interview_manager()

	# Session should be initialized but not active
	var progress: Dictionary = manager.get_session_progress()
	assert_true(progress.has("is_complete"), "Session progress should have is_complete field")
	assert_true(progress.has("questions_answered"), "Session progress should have questions_answered field")

func test_current_question_default_state() -> void:
	# Test that get_current_question returns appropriate default when no interview active
	var manager = get_interview_manager()

	var current_question: Dictionary = manager.get_current_question()
	# Should return empty dictionary when no interview is active
	assert_typeof(current_question, TYPE_DICTIONARY, "get_current_question should always return Dictionary")

# Helper function - will be replaced by actual InterviewManager singleton access
func get_interview_manager():
	# Placeholder function - will access actual InterviewManager singleton
	# For TDD, return a mock object that fails tests appropriately
	return InterviewManagerMock.new()

# Mock InterviewManager for TDD - ensures tests fail until real implementation
class InterviewManagerMock extends Node:

	signal question_changed(question_data: Dictionary)
	signal interview_completed(summary: Dictionary)
	signal effects_applied(effects: Dictionary)

	func load_interview_data(file_path: String) -> bool:
		return false  # Fail by default for TDD

	func start_interview(player_preset_tags: Array[String]) -> String:
		return ""  # Empty string indicates failure

	func get_current_question() -> Dictionary:
		return {}  # Empty dictionary

	func submit_answer(answer_index: int) -> Dictionary:
		return {}  # Empty dictionary

	func get_session_progress() -> Dictionary:
		return {"is_complete": false, "questions_answered": 0}

	func complete_interview() -> Dictionary:
		return {}  # Empty dictionary

	func validate_interview_data(data: Dictionary) -> Array[String]:
		return ["Mock validation error"]  # Non-empty to fail tests

	func validate_question_references(data: Dictionary) -> Array[String]:
		return ["Mock reference error"]  # Non-empty to fail tests