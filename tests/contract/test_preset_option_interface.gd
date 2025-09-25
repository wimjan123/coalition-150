# Contract test for PresetOptionInterface
# This test MUST FAIL until PresetOption resource class is implemented

extends GutTest

var preset_interface_script = preload("res://specs/003-refine-the-character/contracts/PresetOptionInterface.gd")

func before_each():
	gut.p("Testing PresetOptionInterface contract compliance")

func test_preset_option_interface_exists():
	# This test verifies the interface contract exists and is accessible
	assert_not_null(preset_interface_script, "PresetOptionInterface script should be available")

func test_preset_option_interface_extends_resource():
	# Verify interface properly extends Resource
	var temp_instance = preset_interface_script.new()
	assert_true(temp_instance is Resource, "PresetOptionInterface should extend Resource")
	temp_instance.free()

func test_preset_option_has_required_properties():
	# Test that interface defines all required @export properties
	var temp_instance = preset_interface_script.new()

	# Core identification and display properties
	assert_true(temp_instance.has_method("set_id"), "Should have id property setter")
	assert_true(temp_instance.has_method("get_id"), "Should have id property getter")
	assert_true(temp_instance.has_method("set_display_name"), "Should have display_name property")
	assert_true(temp_instance.has_method("set_background_text"), "Should have background_text property")
	assert_true(temp_instance.has_method("set_character_archetype"), "Should have character_archetype property")

	# Difficulty and gameplay impact properties
	assert_true(temp_instance.has_method("set_difficulty_rating"), "Should have difficulty_rating property")
	assert_true(temp_instance.has_method("set_difficulty_label"), "Should have difficulty_label property")
	assert_true(temp_instance.has_method("set_gameplay_impact"), "Should have gameplay_impact property")

	# Political categorization properties
	assert_true(temp_instance.has_method("set_political_alignment"), "Should have political_alignment property")
	assert_true(temp_instance.has_method("set_is_satirical"), "Should have is_satirical property")

	temp_instance.free()

func test_preset_option_has_validation_method():
	# Test that is_valid() method exists and has expected signature
	var temp_instance = preset_interface_script.new()
	assert_true(temp_instance.has_method("is_valid"), "Should have is_valid() method")

	# Test with invalid data (empty fields) - should return false
	temp_instance.id = ""
	temp_instance.display_name = ""
	temp_instance.background_text = ""
	assert_false(temp_instance.is_valid(), "Should return false for invalid data")

	temp_instance.free()

func test_preset_option_has_display_info_method():
	# Test that get_display_info() method exists and returns Dictionary
	var temp_instance = preset_interface_script.new()
	assert_true(temp_instance.has_method("get_display_info"), "Should have get_display_info() method")

	# Set sample data
	temp_instance.display_name = "Test Preset"
	temp_instance.difficulty_label = "Easy"
	temp_instance.gameplay_impact = "Test impact"
	temp_instance.character_archetype = "Test Archetype"
	temp_instance.is_satirical = false

	var display_info = temp_instance.get_display_info()
	assert_true(display_info is Dictionary, "get_display_info() should return Dictionary")
	assert_true(display_info.has("name"), "Display info should contain 'name' key")
	assert_true(display_info.has("difficulty"), "Display info should contain 'difficulty' key")
	assert_true(display_info.has("impact"), "Display info should contain 'impact' key")

	temp_instance.free()

func test_preset_option_has_utility_methods():
	# Test matches_difficulty() and is_politically_aligned() methods
	var temp_instance = preset_interface_script.new()

	assert_true(temp_instance.has_method("matches_difficulty"), "Should have matches_difficulty() method")
	assert_true(temp_instance.has_method("is_politically_aligned"), "Should have is_politically_aligned() method")

	# Test difficulty matching
	temp_instance.difficulty_rating = 5
	assert_true(temp_instance.matches_difficulty(5), "Should match correct difficulty rating")
	assert_false(temp_instance.matches_difficulty(3), "Should not match incorrect difficulty rating")

	# Test political alignment matching
	temp_instance.political_alignment = "Progressive"
	assert_true(temp_instance.is_politically_aligned("Progressive"), "Should match correct political alignment")
	assert_false(temp_instance.is_politically_aligned("Conservative"), "Should not match incorrect political alignment")

	temp_instance.free()

# EXPECTED TO FAIL: These tests verify integration with actual PresetOption implementation
# These will fail until T016 (Create PresetOption resource class) is completed

func test_preset_option_implementation_missing():
	# This test should FAIL - PresetOption class doesn't exist yet
	var preset_option_path = "res://scripts/data/PresetOption.gd"
	assert_false(ResourceLoader.exists(preset_option_path),
		"PresetOption implementation should NOT exist yet (TDD - test first!)")

func test_character_background_presets_implementation_missing():
	# This test should FAIL - CharacterBackgroundPresets class doesn't exist yet
	var presets_path = "res://scripts/data/CharacterBackgroundPresets.gd"
	assert_false(ResourceLoader.exists(presets_path),
		"CharacterBackgroundPresets implementation should NOT exist yet (TDD - test first!)")

func test_preset_data_file_missing():
	# This test should FAIL - preset data file doesn't exist yet
	var data_path = "res://assets/data/CharacterBackgroundPresets.tres"
	assert_false(ResourceLoader.exists(data_path),
		"Preset data file should NOT exist yet (TDD - test first!)")