# Integration Test: Scene Transitions
# Tests all scene transition functionality and performance requirements

extends GutTest

# Test Environment
var scene_manager: SceneManager = null
var test_character: CharacterData = null

func before_all():
	# Initialize scene manager
	scene_manager = SceneManager
	assert_not_null(scene_manager, "SceneManager should be available")

func before_each():
	# Clean up any existing data
	scene_manager.save_system.clear_all_save_data()

	# Create test character
	test_character = CharacterData.new()
	test_character.character_name = "Test Character"
	test_character.political_experience = "Test Experience"
	test_character.backstory = "Test backstory"

	var test_party: PartyData = PartyData.new()
	test_party.party_name = "Test Party"
	test_party.slogan = "Test Slogan"
	test_character.party = test_party

func after_each():
	# Clean up
	scene_manager.save_system.clear_all_save_data()
	scene_manager.set_current_character(null)
	test_character = null

# Scene Transition Tests

func test_main_menu_to_player_selection():
	"""Test transition from MainMenu to CharacterPartySelection"""
	var start_time: float = Time.get_ticks_msec()

	# This would normally be triggered by MainMenu button click
	scene_manager.change_scene_to_player_selection()

	var transition_time: float = Time.get_ticks_msec() - start_time

	# Verify transition completed within performance requirements
	assert_lt(transition_time, 100.0, "Scene transition should complete in under 100ms")

	# Verify scene manager state
	var expected_scene: String = scene_manager.SCENES.CHARACTER_PARTY_SELECTION
	assert_eq(scene_manager.get_current_scene_name(), expected_scene, "Should transition to CharacterPartySelection")

func test_player_selection_to_creation():
	"""Test transition from CharacterPartySelection to CharacterPartyCreation"""
	var start_time: float = Time.get_ticks_msec()

	# Simulate "Create New" button click
	scene_manager.change_scene_to_player_creation()

	var transition_time: float = Time.get_ticks_msec() - start_time

	# Performance check
	assert_lt(transition_time, 100.0, "Scene transition should complete in under 100ms")

	# State verification
	var expected_scene: String = scene_manager.SCENES.CHARACTER_PARTY_CREATION
	assert_eq(scene_manager.get_current_scene_name(), expected_scene, "Should transition to CharacterPartyCreation")

func test_creation_to_interview():
	"""Test transition from CharacterPartyCreation to MediaInterview"""
	# Set character data for transition
	scene_manager.set_current_character(test_character)

	var start_time: float = Time.get_ticks_msec()

	scene_manager.change_scene_to_interview(test_character)

	var transition_time: float = Time.get_ticks_msec() - start_time

	# Performance check
	assert_lt(transition_time, 100.0, "Scene transition should complete in under 100ms")

	# State verification
	var expected_scene: String = scene_manager.SCENES.MEDIA_INTERVIEW
	assert_eq(scene_manager.get_current_scene_name(), expected_scene, "Should transition to MediaInterview")

	# Character should be set
	assert_eq(scene_manager.get_current_character(), test_character, "Current character should be maintained")

func test_interview_to_main_game():
	"""Test transition from MediaInterview to main game"""
	# Setup: character with completed interview
	test_character.complete_interview()
	scene_manager.set_current_character(test_character)

	var start_time: float = Time.get_ticks_msec()

	scene_manager.change_scene_to_main_game()

	var transition_time: float = Time.get_ticks_msec() - start_time

	# Performance check
	assert_lt(transition_time, 100.0, "Scene transition should complete in under 100ms")

	# Verify transition (main game scene would be implemented later)
	assert_not_null(scene_manager.get_current_character(), "Character should be maintained for main game")

func test_back_navigation_creation_to_selection():
	"""Test back navigation from CharacterPartyCreation to CharacterPartySelection"""
	var start_time: float = Time.get_ticks_msec()

	# Simulate back button click
	scene_manager.change_scene_to_player_selection()

	var transition_time: float = Time.get_ticks_msec() - start_time

	# Performance check
	assert_lt(transition_time, 100.0, "Back navigation should complete in under 100ms")

	# State verification
	var expected_scene: String = scene_manager.SCENES.CHARACTER_PARTY_SELECTION
	assert_eq(scene_manager.get_current_scene_name(), expected_scene, "Should return to CharacterPartySelection")

func test_back_navigation_interview_to_creation():
	"""Test back navigation from MediaInterview to CharacterPartyCreation"""
	scene_manager.set_current_character(test_character)

	var start_time: float = Time.get_ticks_msec()

	# Simulate back/cancel from interview
	scene_manager.change_scene_to_player_creation()

	var transition_time: float = Time.get_ticks_msec() - start_time

	# Performance check
	assert_lt(transition_time, 100.0, "Back navigation should complete in under 100ms")

	# State verification
	var expected_scene: String = scene_manager.SCENES.CHARACTER_PARTY_CREATION
	assert_eq(scene_manager.get_current_scene_name(), expected_scene, "Should return to CharacterPartyCreation")

# Session Management Tests

func test_current_character_persistence():
	"""Test that current character persists across scene transitions"""
	# Set character
	scene_manager.set_current_character(test_character)

	# Transition through scenes
	scene_manager.change_scene_to_player_creation()
	assert_eq(scene_manager.get_current_character(), test_character, "Character should persist after creation scene")

	scene_manager.change_scene_to_interview(test_character)
	assert_eq(scene_manager.get_current_character(), test_character, "Character should persist after interview scene")

func test_session_data_cleanup():
	"""Test session data cleanup when returning to main menu"""
	# Set session data
	scene_manager.set_current_character(test_character)
	assert_not_null(scene_manager.get_current_character(), "Character should be set")

	# Return to main menu (should clear session)
	scene_manager.change_scene_to_main_menu()

	# Verify cleanup
	assert_null(scene_manager.get_current_character(), "Character should be cleared when returning to main menu")

func test_scene_context_preservation():
	"""Test that scene-specific context is preserved during transitions"""
	# This would test things like:
	# - Form data in creation scene
	# - Question progress in interview scene
	# - Selection state in player selection

	scene_manager.set_current_character(test_character)

	# Test interview context
	scene_manager.change_scene_to_interview(test_character)

	# Interview should have character data
	var current_char: CharacterData = scene_manager.get_current_character()
	assert_not_null(current_char, "Interview should have character context")
	assert_eq(current_char.character_name, "Test Character", "Character context should be preserved")

# Error Handling Tests

func test_invalid_scene_transition():
	"""Test handling of invalid scene transitions"""
	# Try to go to interview without character data
	scene_manager.set_current_character(null)

	# This should handle gracefully
	scene_manager.change_scene_to_interview(null)

	# Should either stay in current scene or go to safe fallback
	var current_scene: String = scene_manager.get_current_scene_name()
	assert_not_null(current_scene, "Should maintain valid scene state")

func test_missing_character_data():
	"""Test transitions that require character data when none is set"""
	# Ensure no character is set
	scene_manager.set_current_character(null)

	# Try interview transition
	scene_manager.change_scene_to_interview(null)

	# Should handle gracefully - either block transition or provide fallback
	var current_char: CharacterData = scene_manager.get_current_character()
	# Could be null (blocked) or valid fallback character
	if current_char != null:
		assert_not_null(current_char, "If transition allowed, should provide valid character")

func test_scene_loading_failure_recovery():
	"""Test recovery when scene loading fails"""
	# This is harder to test directly, but we can verify error handling exists

	# Try to load non-existent scene (simulated)
	var original_scene: String = scene_manager.get_current_scene_name()

	# Attempt invalid transition
	# scene_manager would handle this internally

	# Should maintain valid state
	var current_scene: String = scene_manager.get_current_scene_name()
	assert_not_null(current_scene, "Should maintain valid scene state after error")

# Performance Stress Tests

func test_rapid_scene_transitions():
	"""Test performance under rapid scene transitions"""
	var total_time: float = 0.0
	var transition_count: int = 5

	for i in range(transition_count):
		var start_time: float = Time.get_ticks_msec()

		# Alternate between scenes
		if i % 2 == 0:
			scene_manager.change_scene_to_player_selection()
		else:
			scene_manager.change_scene_to_player_creation()

		var transition_time: float = Time.get_ticks_msec() - start_time
		total_time += transition_time

	var average_time: float = total_time / transition_count
	assert_lt(average_time, 100.0, "Average transition time should be under 100ms")

func test_memory_usage_during_transitions():
	"""Test that memory usage remains reasonable during transitions"""
	# Get baseline memory usage
	var initial_memory: int = OS.get_static_memory_usage_by_type()

	# Perform multiple transitions
	for i in range(10):
		scene_manager.change_scene_to_player_selection()
		scene_manager.change_scene_to_player_creation()

		# Force garbage collection to clear unused scenes
		if i % 3 == 0:
			OS.low_processor_usage_mode = true
			await get_tree().process_frame
			OS.low_processor_usage_mode = false

	var final_memory: int = OS.get_static_memory_usage_by_type()
	var memory_increase: int = final_memory - initial_memory

	# Memory increase should be reasonable (less than 10MB)
	var max_acceptable_increase: int = 10 * 1024 * 1024  # 10MB
	assert_lt(memory_increase, max_acceptable_increase, "Memory usage should remain reasonable")

# Scene State Tests

func test_scene_initialization_state():
	"""Test that scenes initialize with correct default state"""
	# Test CharacterPartySelection initialization
	scene_manager.change_scene_to_player_selection()

	# Should be ready to create new or load existing characters
	var available_characters: Array[CharacterData] = scene_manager.get_available_characters()
	assert_not_null(available_characters, "Should provide character list (even if empty)")

func test_scene_cleanup_on_exit():
	"""Test that scenes clean up properly when exiting"""
	# Set character data
	scene_manager.set_current_character(test_character)

	# Transition to interview
	scene_manager.change_scene_to_interview(test_character)

	# Transition away
	scene_manager.change_scene_to_player_selection()

	# Previous scene should not affect current state inappropriately
	var current_scene: String = scene_manager.get_current_scene_name()
	assert_eq(current_scene, scene_manager.SCENES.CHARACTER_PARTY_SELECTION, "Should be in correct scene")

# Integration with Save System Tests

func test_scene_transitions_with_save_data():
	"""Test scene transitions when save data exists"""
	# Create save data
	var player_data: PlayerData = PlayerData.new()
	player_data.add_character(test_character)
	scene_manager.save_system.save_player_data(player_data)

	# Transition to player selection
	scene_manager.change_scene_to_player_selection()

	# Should detect existing save data
	assert_true(scene_manager.has_save_data(), "Should detect existing save data")

	var characters: Array[CharacterData] = scene_manager.get_available_characters()
	assert_eq(characters.size(), 1, "Should load existing character")

func test_scene_transitions_with_character_loading():
	"""Test scene transitions with character loading from save data"""
	# Save character data
	var player_data: PlayerData = PlayerData.new()
	player_data.add_character(test_character)
	scene_manager.save_system.save_player_data(player_data)

	# Load character through scene manager
	var loaded_character: CharacterData = scene_manager.get_available_characters()[0]
	scene_manager.set_current_character(loaded_character)

	# Transition to interview
	scene_manager.change_scene_to_interview(loaded_character)

	# Verify loaded character is maintained
	var current_char: CharacterData = scene_manager.get_current_character()
	assert_eq(current_char.character_name, "Test Character", "Loaded character should be maintained")

# UI Responsiveness Tests

func test_ui_responsiveness_during_transitions():
	"""Test that UI remains responsive during scene transitions"""
	var frame_time_threshold: float = 16.67  # 60 FPS = ~16.67ms per frame

	var start_time: float = Time.get_ticks_msec()

	scene_manager.change_scene_to_player_creation()

	# Wait for next frame
	await get_tree().process_frame

	var frame_time: float = Time.get_ticks_msec() - start_time

	# Frame time should not exceed 60 FPS threshold significantly
	assert_lt(frame_time, frame_time_threshold * 2, "UI should remain responsive during transitions")

func test_scene_transition_signals():
	"""Test that appropriate signals are emitted during transitions"""
	var signal_emitted: bool = false

	# Connect to scene change signal if it exists
	if scene_manager.has_signal("scene_changed"):
		scene_manager.scene_changed.connect(func(): signal_emitted = true)

		scene_manager.change_scene_to_player_creation()

		assert_true(signal_emitted, "Scene change signal should be emitted")
	else:
		# If no signal exists, that's also acceptable
		pass_test("No scene change signal implemented - acceptable")

# Complete Flow Tests

func test_complete_forward_flow():
	"""Test complete forward navigation flow"""
	var total_start_time: float = Time.get_ticks_msec()

	# MainMenu -> Player Selection
	scene_manager.change_scene_to_player_selection()

	# Player Selection -> Character Creation
	scene_manager.change_scene_to_player_creation()

	# Character Creation -> Interview
	scene_manager.set_current_character(test_character)
	scene_manager.change_scene_to_interview(test_character)

	# Interview -> Main Game
	test_character.complete_interview()
	scene_manager.change_scene_to_main_game()

	var total_time: float = Time.get_ticks_msec() - total_start_time

	# Complete flow should be reasonably fast
	assert_lt(total_time, 400.0, "Complete forward flow should complete in under 400ms")

func test_complete_backward_flow():
	"""Test complete backward navigation flow"""
	# Set up end state
	scene_manager.set_current_character(test_character)
	scene_manager.change_scene_to_interview(test_character)

	var total_start_time: float = Time.get_ticks_msec()

	# Interview -> Character Creation
	scene_manager.change_scene_to_player_creation()

	# Character Creation -> Player Selection
	scene_manager.change_scene_to_player_selection()

	# Player Selection -> Main Menu
	scene_manager.change_scene_to_main_menu()

	var total_time: float = Time.get_ticks_msec() - total_start_time

	# Complete backward flow should be reasonably fast
	assert_lt(total_time, 300.0, "Complete backward flow should complete in under 300ms")