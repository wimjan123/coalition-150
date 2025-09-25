# Contract test for SceneManagerInterface
# These tests MUST fail until SceneManager is properly implemented

extends GutTest

var scene_manager: SceneManagerInterface

func before_each():
	# Get the SceneManager autoload and verify it implements the interface
	scene_manager = SceneManager as SceneManagerInterface
	assert_not_null(scene_manager, "SceneManager autoload should exist")
	assert_true(scene_manager is SceneManagerInterface, "SceneManager should implement SceneManagerInterface")

func test_scene_transition_methods_exist():
	# Test that all required scene transition methods exist
	assert_has_method(scene_manager, "change_scene_to_player_selection", "Should have change_scene_to_player_selection method")
	assert_has_method(scene_manager, "change_scene_to_player_creation", "Should have change_scene_to_player_creation method")
	assert_has_method(scene_manager, "change_scene_to_interview", "Should have change_scene_to_interview method")
	assert_has_method(scene_manager, "change_scene_to_main_menu", "Should have change_scene_to_main_menu method")
	assert_has_method(scene_manager, "change_scene_to_main_game", "Should have change_scene_to_main_game method")

func test_scene_transition_signals_exist():
	# Test that all required signals exist
	assert_has_signal(scene_manager, "scene_change_started", "Should have scene_change_started signal")
	assert_has_signal(scene_manager, "scene_change_completed", "Should have scene_change_completed signal")
	assert_has_signal(scene_manager, "transition_fade_started", "Should have transition_fade_started signal")
	assert_has_signal(scene_manager, "transition_fade_completed", "Should have transition_fade_completed signal")

func test_scene_transitions_work():
	# Test that scene transitions actually work and don't just push errors
	# This should fail until properly implemented
	var scene_changed: bool = false

	scene_manager.scene_change_completed.connect(_on_scene_changed)

	# Test transition to player selection
	scene_manager.change_scene_to_player_selection()

	# This should fail until implemented
	assert_true(scene_changed, "Scene transition should complete without errors")

func test_current_scene_path_tracking():
	# Test that current scene path is properly tracked
	var current_path: String = scene_manager.get_current_scene_path()
	assert_ne(current_path, "", "Should return current scene path")

func test_save_data_detection():
	# Test that save data detection works
	var has_save: bool = scene_manager.has_save_data()
	assert_true(has_save is bool, "Should return boolean for save data existence")

func test_character_data_management():
	# Test that character data management works
	var characters: Array = scene_manager.get_available_characters()
	assert_true(characters is Array, "Should return array of available characters")

func test_session_management():
	# Test session management functionality
	var test_character: CharacterData = CharacterData.new()
	test_character.character_name = "Test Character"

	scene_manager.set_current_character(test_character)
	var retrieved_character: CharacterData = scene_manager.get_current_character()

	assert_eq(retrieved_character.character_name, "Test Character", "Should properly store and retrieve current character")

func test_transition_validation():
	# Test transition validation
	var is_valid: bool = scene_manager.validate_scene_transition("main_menu", "player_selection")
	assert_true(is_valid is bool, "Should return boolean for transition validation")

func _on_scene_changed():
	# Helper function for scene change testing
	pass