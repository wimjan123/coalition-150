# Integration Test: Complete Player Creation Flow
# Tests the entire player creation workflow from main menu to game start

extends GutTest

# Test Environment
var scene_manager: SceneManager = null
var test_character_data: CharacterData = null
var test_party_data: PartyData = null

func before_all():
	# Initialize test environment
	scene_manager = SceneManager
	assert_not_null(scene_manager, "SceneManager should be available")

func before_each():
	# Clean up any existing save data before each test
	scene_manager.save_system.clear_all_save_data()

	# Create test data
	test_character_data = CharacterData.new()
	test_character_data.character_name = "Test Character"
	test_character_data.political_experience = "Community Organizer"
	test_character_data.backstory = "Long-time resident with community involvement"

	test_party_data = PartyData.new()
	test_party_data.party_name = "Test Party"
	test_party_data.slogan = "Test Slogan for Change"
	test_party_data.primary_color = Color.BLUE
	test_party_data.logo_index = 0

	test_character_data.party = test_party_data

func after_each():
	# Clean up test data
	scene_manager.save_system.clear_all_save_data()
	test_character_data = null
	test_party_data = null

# Test Cases

func test_main_menu_initialization():
	"""Test that MainMenu initializes correctly and checks save data"""
	var main_menu_scene = preload("res://scenes/main/MainMenu.tscn")
	var main_menu = main_menu_scene.instantiate()

	# Add to scene tree for testing
	add_child_autofree(main_menu)

	# Wait for _ready() to complete
	await get_tree().process_frame

	# Verify Load Game button is initially disabled (no save data)
	var load_button = main_menu.get_node("MenuContainer/LoadButton")
	assert_not_null(load_button, "Load button should exist")
	assert_true(load_button.disabled, "Load button should be disabled when no save data exists")

func test_character_party_selection_empty_state():
	"""Test CharacterPartySelection when no characters exist"""
	var selection_scene = preload("res://scenes/player/CharacterPartySelection.tscn")
	var selection = selection_scene.instantiate()

	add_child_autofree(selection)
	await get_tree().process_frame

	# Verify Create New button is available
	var create_button = selection.get_node("MainContainer/ActionContainer/CreateNewButton")
	assert_not_null(create_button, "Create New button should exist")
	assert_false(create_button.disabled, "Create New button should be enabled")

	# Verify Load Selected button is disabled (no characters)
	var load_button = selection.get_node("MainContainer/ActionContainer/LoadSelectedButton")
	assert_not_null(load_button, "Load Selected button should exist")
	assert_true(load_button.disabled, "Load Selected button should be disabled when no characters exist")

func test_character_party_creation_form_validation():
	"""Test CharacterPartyCreation form validation"""
	var creation_scene = preload("res://scenes/player/CharacterPartyCreation.tscn")
	var creation = creation_scene.instantiate()

	add_child_autofree(creation)
	await get_tree().process_frame

	# Test empty form validation
	var create_button = creation.get_node("MainContainer/ActionContainer/CreateCharacterButton")
	assert_not_null(create_button, "Create Character button should exist")

	# Initially button should be disabled (empty form)
	assert_true(create_button.disabled, "Create button should be disabled with empty form")

	# Fill in required fields
	var character_name_field = creation.get_node("MainContainer/ScrollContainer/FormContainer/CharacterSection/CharacterNameContainer/CharacterNameField")
	var party_name_field = creation.get_node("MainContainer/ScrollContainer/FormContainer/PartySection/PartyNameContainer/PartyNameField")

	character_name_field.text = "Test Character"
	party_name_field.text = "Test Party"

	# Simulate text changes
	character_name_field.text_changed.emit("Test Character")
	party_name_field.text_changed.emit("Test Party")

	await get_tree().process_frame

	# Button should now be enabled
	assert_false(create_button.disabled, "Create button should be enabled with valid form data")

func test_save_and_load_character_data():
	"""Test saving and loading character data"""
	# Create character through SaveSystem
	var player_data: PlayerData = PlayerData.new()
	player_data.add_character(test_character_data)

	# Save data
	var save_success: bool = scene_manager.save_system.save_player_data(player_data)
	assert_true(save_success, "Character data should save successfully")

	# Load data
	var loaded_data: PlayerData = scene_manager.save_system.load_player_data()
	assert_not_null(loaded_data, "Should be able to load saved data")
	assert_eq(loaded_data.characters.size(), 1, "Should load 1 character")
	assert_eq(loaded_data.characters[0].character_name, "Test Character", "Character name should match")

func test_interview_flow_completion():
	"""Test MediaInterview flow from start to finish"""
	var interview_scene = preload("res://scenes/player/MediaInterview.tscn")
	var interview = interview_scene.instantiate()

	add_child_autofree(interview)

	# Set current character in SceneManager for testing
	scene_manager.set_current_character(test_character_data)

	await get_tree().process_frame

	# Verify interview initialized
	assert_true(interview.questions.size() > 0, "Questions should be generated")
	assert_eq(interview.get_current_question_index(), 0, "Should start at question 0")

	# Simulate answering all questions
	for i in range(interview.get_total_questions()):
		# Select first answer for each question
		interview.submit_answer(0)

		# Move to next question if not last
		if i < interview.get_total_questions() - 1:
			interview.proceed_to_next_question()

	# Verify interview completion
	assert_true(interview.validate_all_questions_answered(), "All questions should be answered")

	# Finish interview
	interview.finish_interview()

	# Verify responses were saved to character
	assert_true(test_character_data.has_completed_interview(), "Character should have completed interview")

func test_complete_workflow_new_character():
	"""Integration test for complete new character creation workflow"""
	# Step 1: MainMenu -> Player Selection
	assert_false(scene_manager.has_save_data(), "Should start with no save data")

	# Step 2: Player Selection -> Character Creation (no existing characters)
	var characters: Array[CharacterData] = scene_manager.get_available_characters()
	assert_eq(characters.size(), 0, "Should start with no characters")

	# Step 3: Character Creation -> Interview
	# Create character data through creation process
	scene_manager.set_current_character(test_character_data)
	assert_not_null(scene_manager.get_current_character(), "Current character should be set")

	# Step 4: Interview -> Game Start
	# Complete interview process
	test_character_data.complete_interview()

	# Step 5: Save character
	var save_success: bool = scene_manager.save_system.quick_save_character(test_character_data)
	assert_true(save_success, "Character should save successfully")

	# Step 6: Verify workflow completion
	assert_true(scene_manager.has_save_data(), "Save data should now exist")
	var saved_characters: Array[CharacterData] = scene_manager.get_available_characters()
	assert_eq(saved_characters.size(), 1, "Should have 1 saved character")
	assert_eq(saved_characters[0].character_name, "Test Character", "Saved character name should match")

func test_complete_workflow_load_character():
	"""Integration test for loading existing character workflow"""
	# Setup: Save a character first
	var player_data: PlayerData = PlayerData.new()
	player_data.add_character(test_character_data)
	scene_manager.save_system.save_player_data(player_data)

	# Step 1: MainMenu with existing save data
	assert_true(scene_manager.has_save_data(), "Save data should exist")

	# Step 2: Player Selection -> Load existing character
	var characters: Array[CharacterData] = scene_manager.get_available_characters()
	assert_eq(characters.size(), 1, "Should have 1 saved character")

	# Step 3: Select and load character
	var loaded_character: CharacterData = characters[0]
	scene_manager.set_current_character(loaded_character)

	# Step 4: Verify character loaded correctly
	var current_character: CharacterData = scene_manager.get_current_character()
	assert_not_null(current_character, "Current character should be loaded")
	assert_eq(current_character.character_name, "Test Character", "Loaded character should match")

func test_error_handling_invalid_data():
	"""Test error handling for invalid data scenarios"""
	# Test null character handling
	scene_manager.set_current_character(null)
	assert_null(scene_manager.get_current_character(), "Should handle null character")

	# Test invalid save data
	var invalid_player_data: PlayerData = PlayerData.new()
	var invalid_character: CharacterData = CharacterData.new()
	# Leave character with invalid/empty data
	invalid_player_data.add_character(invalid_character)

	var validation: Dictionary = invalid_character.validate()
	assert_false(validation.valid, "Invalid character data should fail validation")

func test_performance_requirements():
	"""Test that scene transitions meet performance requirements"""
	var start_time: float = Time.get_ticks_msec()

	# Test scene loading performance
	var selection_scene = preload("res://scenes/player/CharacterPartySelection.tscn")
	var selection = selection_scene.instantiate()
	add_child_autofree(selection)

	await get_tree().process_frame

	var load_time: float = Time.get_ticks_msec() - start_time

	# Should load in < 100ms as per requirements
	assert_lt(load_time, 100.0, "Scene should load in under 100ms")

func test_ui_consistency_theme_application():
	"""Test that all scenes apply themes consistently"""
	# Test Character Selection scene
	var selection_scene = preload("res://scenes/player/CharacterPartySelection.tscn")
	var selection = selection_scene.instantiate()
	add_child_autofree(selection)
	await get_tree().process_frame

	assert_not_null(selection.theme, "CharacterPartySelection should have theme applied")

	# Test Character Creation scene
	var creation_scene = preload("res://scenes/player/CharacterPartyCreation.tscn")
	var creation = creation_scene.instantiate()
	add_child_autofree(creation)
	await get_tree().process_frame

	assert_not_null(creation.theme, "CharacterPartyCreation should have theme applied")

	# Test Interview scene
	var interview_scene = preload("res://scenes/player/MediaInterview.tscn")
	var interview = interview_scene.instantiate()
	add_child_autofree(interview)
	await get_tree().process_frame

	assert_not_null(interview.theme, "MediaInterview should have theme applied")