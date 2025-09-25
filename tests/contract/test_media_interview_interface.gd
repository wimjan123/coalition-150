# Contract test for MediaInterviewInterface
# These tests MUST fail until MediaInterview scene is properly implemented

extends GutTest

var media_interview_scene: MediaInterviewInterface
var scene_instance: PackedScene

func before_each():
	# Load the MediaInterview scene and verify it implements the interface
	var scene_path: String = "res://scenes/player/MediaInterview.tscn"

	if ResourceLoader.exists(scene_path):
		scene_instance = load(scene_path)
		var instance: Node = scene_instance.instantiate()
		media_interview_scene = instance as MediaInterviewInterface
		add_child(instance)

	# This should fail until scene is created and properly implements interface
	assert_not_null(media_interview_scene, "MediaInterview scene should exist and implement MediaInterviewInterface")

func after_each():
	if media_interview_scene:
		media_interview_scene.queue_free()

func test_interview_initialization_methods_exist():
	# Test that interview initialization methods exist
	assert_has_method(media_interview_scene, "start_interview", "Should have start_interview method")
	assert_has_method(media_interview_scene, "generate_questions_for_character", "Should have generate_questions_for_character method")

func test_question_management_methods_exist():
	# Test that question management methods exist
	assert_has_method(media_interview_scene, "display_question", "Should have display_question method")
	assert_has_method(media_interview_scene, "get_current_question", "Should have get_current_question method")
	assert_has_method(media_interview_scene, "get_total_questions", "Should have get_total_questions method")
	assert_has_method(media_interview_scene, "get_current_question_index", "Should have get_current_question_index method")

func test_answer_handling_methods_exist():
	# Test that answer handling methods exist
	assert_has_method(media_interview_scene, "submit_answer", "Should have submit_answer method")
	assert_has_method(media_interview_scene, "get_selected_answer", "Should have get_selected_answer method")
	assert_has_method(media_interview_scene, "can_change_answer", "Should have can_change_answer method")

func test_navigation_control_methods_exist():
	# Test that navigation control methods exist
	assert_has_method(media_interview_scene, "proceed_to_next_question", "Should have proceed_to_next_question method")
	assert_has_method(media_interview_scene, "go_back_to_previous_question", "Should have go_back_to_previous_question method")
	assert_has_method(media_interview_scene, "finish_interview", "Should have finish_interview method")

func test_interview_signals_exist():
	# Test that all required interview signals exist
	assert_has_signal(media_interview_scene, "interview_started", "Should have interview_started signal")
	assert_has_signal(media_interview_scene, "question_answered", "Should have question_answered signal")
	assert_has_signal(media_interview_scene, "interview_completed", "Should have interview_completed signal")
	assert_has_signal(media_interview_scene, "interview_cancelled", "Should have interview_cancelled signal")

func test_navigation_signals_exist():
	# Test that navigation signals exist
	assert_has_signal(media_interview_scene, "proceed_to_main_game_requested", "Should have proceed_to_main_game_requested signal")
	assert_has_signal(media_interview_scene, "return_to_creation_requested", "Should have return_to_creation_requested signal")

func test_ui_state_management_methods_exist():
	# Test that UI state management methods exist
	assert_has_method(media_interview_scene, "show_question_ui", "Should have show_question_ui method")
	assert_has_method(media_interview_scene, "show_summary_ui", "Should have show_summary_ui method")
	assert_has_method(media_interview_scene, "update_progress_display", "Should have update_progress_display method")

func test_response_compilation_methods_exist():
	# Test that response compilation methods exist
	assert_has_method(media_interview_scene, "compile_interview_responses", "Should have compile_interview_responses method")
	assert_has_method(media_interview_scene, "save_responses_to_character", "Should have save_responses_to_character method")

func test_question_generation_functionality():
	# Test that question generation works
	# This should fail until properly implemented
	var test_character: CharacterData = CharacterData.new()
	test_character.character_name = "Test Character"
	test_character.political_experience = "Mayor"
	test_character.backstory = "Test backstory"

	var questions: Array = media_interview_scene.generate_questions_for_character(test_character)
	assert_eq(questions.size(), 5, "Should generate exactly 5 questions")
	assert_true(questions[0] is Dictionary, "Questions should be Dictionary objects")

func test_interview_initialization():
	# Test that interview can be initialized
	# This should fail until properly implemented
	var test_character: CharacterData = CharacterData.new()
	test_character.character_name = "Test Character"

	media_interview_scene.start_interview(test_character)

	var total_questions: int = media_interview_scene.get_total_questions()
	assert_eq(total_questions, 5, "Should have 5 total questions after initialization")

func test_question_navigation():
	# Test question navigation functionality
	# This should fail until properly implemented
	var current_index: int = media_interview_scene.get_current_question_index()
	assert_eq(current_index, 0, "Should start at question 0")

	media_interview_scene.proceed_to_next_question()
	var new_index: int = media_interview_scene.get_current_question_index()
	assert_eq(new_index, 1, "Should advance to question 1")

func test_answer_submission():
	# Test answer submission functionality
	# This should fail until properly implemented
	media_interview_scene.submit_answer(1)
	var selected_answer: String = media_interview_scene.get_selected_answer()
	assert_ne(selected_answer, "", "Should have selected answer after submission")

func test_interview_completion():
	# Test interview completion functionality
	# This should fail until properly implemented
	var responses: Array = media_interview_scene.compile_interview_responses()
	assert_true(responses is Array, "Should return array of interview responses")

	var is_complete: bool = media_interview_scene.is_interview_complete()
	assert_true(is_complete is bool, "Should return boolean for completion status")

func test_validation_methods():
	# Test validation methods
	var all_answered: bool = media_interview_scene.validate_all_questions_answered()
	assert_true(all_answered is bool, "Should return boolean for validation")

func test_progress_tracking():
	# Test progress tracking
	var progress: float = media_interview_scene.get_interview_progress()
	assert_true(progress is float, "Should return float for progress")
	assert_true(progress >= 0.0 and progress <= 1.0, "Progress should be between 0.0 and 1.0")

	var answers_summary: Array = media_interview_scene.get_answers_summary()
	assert_true(answers_summary is Array, "Should return array of answers summary")

func test_question_template_methods_exist():
	# Test that question template methods exist
	assert_has_method(media_interview_scene, "get_experience_questions", "Should have get_experience_questions method")
	assert_has_method(media_interview_scene, "get_policy_questions", "Should have get_policy_questions method")
	assert_has_method(media_interview_scene, "get_backstory_questions", "Should have get_backstory_questions method")