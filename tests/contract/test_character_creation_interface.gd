# Contract test for CharacterCreationInterface
# These tests MUST fail until CharacterPartyCreation scene is properly implemented

extends GutTest

var character_creation_scene: CharacterCreationInterface
var scene_instance: PackedScene

func before_each():
	# Load the CharacterPartyCreation scene and verify it implements the interface
	var scene_path: String = "res://scenes/player/CharacterPartyCreation.tscn"

	if ResourceLoader.exists(scene_path):
		scene_instance = load(scene_path)
		var instance: Node = scene_instance.instantiate()
		character_creation_scene = instance as CharacterCreationInterface
		add_child(instance)

	# This should fail until scene is created and properly implements interface
	assert_not_null(character_creation_scene, "CharacterPartyCreation scene should exist and implement CharacterCreationInterface")

func after_each():
	if character_creation_scene:
		character_creation_scene.queue_free()

func test_character_creation_methods_exist():
	# Test that all required character creation methods exist
	assert_has_method(character_creation_scene, "set_character_name", "Should have set_character_name method")
	assert_has_method(character_creation_scene, "set_political_experience", "Should have set_political_experience method")
	assert_has_method(character_creation_scene, "set_policy_position", "Should have set_policy_position method")
	assert_has_method(character_creation_scene, "set_backstory", "Should have set_backstory method")
	assert_has_method(character_creation_scene, "get_character_data", "Should have get_character_data method")

func test_party_creation_methods_exist():
	# Test that all required party creation methods exist
	assert_has_method(character_creation_scene, "set_party_name", "Should have set_party_name method")
	assert_has_method(character_creation_scene, "set_party_slogan", "Should have set_party_slogan method")
	assert_has_method(character_creation_scene, "set_party_color", "Should have set_party_color method")
	assert_has_method(character_creation_scene, "set_party_logo", "Should have set_party_logo method")
	assert_has_method(character_creation_scene, "get_party_data", "Should have get_party_data method")

func test_validation_methods_exist():
	# Test that all required validation methods exist
	assert_has_method(character_creation_scene, "validate_character_fields", "Should have validate_character_fields method")
	assert_has_method(character_creation_scene, "validate_party_fields", "Should have validate_party_fields method")
	assert_has_method(character_creation_scene, "validate_party_name_unique", "Should have validate_party_name_unique method")

func test_ui_state_management_methods_exist():
	# Test that UI state management methods exist
	assert_has_method(character_creation_scene, "show_character_section", "Should have show_character_section method")
	assert_has_method(character_creation_scene, "show_party_section", "Should have show_party_section method")
	assert_has_method(character_creation_scene, "show_summary_section", "Should have show_summary_section method")
	assert_has_method(character_creation_scene, "reset_form", "Should have reset_form method")

func test_creation_signals_exist():
	# Test that all required signals exist
	assert_has_signal(character_creation_scene, "character_creation_completed", "Should have character_creation_completed signal")
	assert_has_signal(character_creation_scene, "party_creation_completed", "Should have party_creation_completed signal")
	assert_has_signal(character_creation_scene, "creation_cancelled", "Should have creation_cancelled signal")
	assert_has_signal(character_creation_scene, "validation_failed", "Should have validation_failed signal")

func test_navigation_signals_exist():
	# Test that navigation signals exist
	assert_has_signal(character_creation_scene, "proceed_to_interview_requested", "Should have proceed_to_interview_requested signal")
	assert_has_signal(character_creation_scene, "return_to_selection_requested", "Should have return_to_selection_requested signal")

func test_character_data_creation():
	# Test that character data can be created and retrieved
	# This should fail until properly implemented
	character_creation_scene.set_character_name("Test Character")
	character_creation_scene.set_political_experience("Mayor")
	character_creation_scene.set_backstory("Test backstory")

	var character_data: CharacterData = character_creation_scene.get_character_data()
	assert_not_null(character_data, "Should create valid CharacterData")
	assert_eq(character_data.character_name, "Test Character", "Should store character name")

func test_party_data_creation():
	# Test that party data can be created and retrieved
	# This should fail until properly implemented
	character_creation_scene.set_party_name("Test Party")
	character_creation_scene.set_party_slogan("Test Slogan")
	character_creation_scene.set_party_color(Color.BLUE)
	character_creation_scene.set_party_logo(2)

	var party_data: PartyData = character_creation_scene.get_party_data()
	assert_not_null(party_data, "Should create valid PartyData")
	assert_eq(party_data.party_name, "Test Party", "Should store party name")

func test_validation_functionality():
	# Test that validation works properly
	# This should fail until properly implemented
	var is_valid: bool = character_creation_scene.validate_character_fields()
	assert_true(is_valid is bool, "Should return boolean for character validation")

	var party_valid: bool = character_creation_scene.validate_party_fields()
	assert_true(party_valid is bool, "Should return boolean for party validation")

func test_logo_management():
	# Test logo management functionality
	var logos: Array = character_creation_scene.get_available_logos()
	assert_true(logos is Array, "Should return array of available logos")
	assert_ge(logos.size(), 3, "Should have at least 3 logo options")

func test_completion_tracking():
	# Test completion tracking
	var completion: float = character_creation_scene.get_completion_percentage()
	assert_true(completion is float, "Should return float for completion percentage")
	assert_true(completion >= 0.0 and completion <= 1.0, "Completion should be between 0.0 and 1.0")

	var is_complete: bool = character_creation_scene.is_creation_complete()
	assert_true(is_complete is bool, "Should return boolean for completion status")