# Unit test for PresetOption validation
# This test MUST FAIL until PresetOption resource class is implemented (T016)

extends GutTest

var preset_option_interface_script = preload("res://specs/003-refine-the-character/contracts/PresetOptionInterface.gd")

func before_each():
	gut.p("Testing PresetOption resource validation logic")

func test_preset_option_validation_empty_fields():
	# Test validation fails with empty required fields
	var preset = preset_option_interface_script.new()

	# Empty fields should fail validation
	preset.id = ""
	preset.display_name = ""
	preset.background_text = ""
	preset.character_archetype = ""

	assert_false(preset.is_valid(), "Empty fields should fail validation")
	preset.free()

func test_preset_option_validation_minimal_valid_data():
	# Test validation passes with minimal valid data
	var preset = preset_option_interface_script.new()

	# Minimal valid data
	preset.id = "test_preset"
	preset.display_name = "Test Preset"
	preset.background_text = "Test background description"
	preset.character_archetype = "Test Archetype"
	preset.difficulty_rating = 5
	preset.difficulty_label = "Medium"
	preset.gameplay_impact = "Test impact"
	preset.political_alignment = "Neutral"
	preset.is_satirical = false

	assert_true(preset.is_valid(), "Valid minimal data should pass validation")
	preset.free()

func test_preset_option_validation_invalid_difficulty_rating():
	# Test validation fails with invalid difficulty ratings
	var preset = preset_option_interface_script.new()

	# Valid base data
	preset.id = "test_preset"
	preset.display_name = "Test Preset"
	preset.background_text = "Test background"
	preset.character_archetype = "Test Archetype"
	preset.difficulty_label = "Easy"
	preset.gameplay_impact = "Low impact"
	preset.political_alignment = "Progressive"
	preset.is_satirical = false

	# Test invalid difficulty ratings (should be 1-10)
	preset.difficulty_rating = 0
	assert_false(preset.is_valid(), "Difficulty rating 0 should fail validation")

	preset.difficulty_rating = 11
	assert_false(preset.is_valid(), "Difficulty rating 11 should fail validation")

	preset.difficulty_rating = -1
	assert_false(preset.is_valid(), "Negative difficulty rating should fail validation")

	preset.free()

func test_preset_option_validation_political_alignment():
	# Test validation of political alignment values
	var preset = preset_option_interface_script.new()

	# Valid base data
	preset.id = "test_preset"
	preset.display_name = "Test Preset"
	preset.background_text = "Test background"
	preset.character_archetype = "Test Archetype"
	preset.difficulty_rating = 5
	preset.difficulty_label = "Medium"
	preset.gameplay_impact = "Medium impact"
	preset.is_satirical = false

	# Test valid political alignments
	var valid_alignments = ["Progressive", "Conservative", "Libertarian", "Centrist", "Populist", "Neutral"]

	for alignment in valid_alignments:
		preset.political_alignment = alignment
		assert_true(preset.is_valid(), "Political alignment '" + alignment + "' should be valid")

	# Test invalid political alignment
	preset.political_alignment = "InvalidAlignment"
	assert_false(preset.is_valid(), "Invalid political alignment should fail validation")

	preset.free()

func test_preset_option_display_info_structure():
	# Test get_display_info() returns correctly structured data
	var preset = preset_option_interface_script.new()

	preset.display_name = "Campaign Manager"
	preset.difficulty_label = "Hard"
	preset.gameplay_impact = "High political strategy requirements"
	preset.character_archetype = "Political Strategist"
	preset.is_satirical = true

	var display_info = preset.get_display_info()

	assert_true(display_info is Dictionary, "Display info should be Dictionary")
	assert_true(display_info.has("name"), "Should contain 'name' key")
	assert_true(display_info.has("difficulty"), "Should contain 'difficulty' key")
	assert_true(display_info.has("impact"), "Should contain 'impact' key")
	assert_true(display_info.has("archetype"), "Should contain 'archetype' key")
	assert_true(display_info.has("satirical"), "Should contain 'satirical' key")

	assert_eq(display_info["name"], "Campaign Manager", "Name should match display_name")
	assert_eq(display_info["difficulty"], "Hard", "Difficulty should match difficulty_label")
	assert_eq(display_info["satirical"], true, "Satirical flag should match is_satirical")

	preset.free()

func test_preset_option_utility_methods():
	# Test matches_difficulty() and is_politically_aligned() utility methods
	var preset = preset_option_interface_script.new()

	preset.difficulty_rating = 7
	preset.political_alignment = "Progressive"

	# Test difficulty matching
	assert_true(preset.matches_difficulty(7), "Should match exact difficulty rating")
	assert_false(preset.matches_difficulty(5), "Should not match different difficulty rating")
	assert_false(preset.matches_difficulty(0), "Should not match invalid difficulty rating")

	# Test political alignment matching
	assert_true(preset.is_politically_aligned("Progressive"), "Should match exact political alignment")
	assert_false(preset.is_politically_aligned("Conservative"), "Should not match different alignment")
	assert_false(preset.is_politically_aligned(""), "Should not match empty alignment")

	preset.free()

func test_preset_option_satirical_classification():
	# Test satirical preset handling and classification
	var preset = preset_option_interface_script.new()

	preset.id = "satirical_test"
	preset.display_name = "Social Media Influencer"
	preset.background_text = "Former TikTok star turned political commentator"
	preset.character_archetype = "Digital Native"
	preset.difficulty_rating = 3
	preset.difficulty_label = "Easy"
	preset.gameplay_impact = "High social media reach, low policy knowledge"
	preset.political_alignment = "Populist"
	preset.is_satirical = true

	assert_true(preset.is_valid(), "Satirical preset should be valid")

	var display_info = preset.get_display_info()
	assert_true(display_info["satirical"], "Display info should indicate satirical content")

	preset.free()

# EXPECTED TO FAIL: These tests verify actual implementation doesn't exist yet (TDD)
func test_preset_option_implementation_not_exists():
	# This should FAIL - PresetOption class implementation doesn't exist yet
	var preset_option_path = "res://scripts/data/PresetOption.gd"
	assert_false(ResourceLoader.exists(preset_option_path),
		"PresetOption implementation should NOT exist yet (TDD - test first!)")

func test_preset_option_integration_with_character_data():
	# This should FAIL - integration with CharacterData doesn't exist yet
	var character_data_path = "res://scripts/data/CharacterData.gd"

	# This test will fail because CharacterData integration hasn't been implemented
	if ResourceLoader.exists(character_data_path):
		var character_data_script = load(character_data_path)
		var character_data = character_data_script.new()

		# Should not have preset integration methods yet
		assert_false(character_data.has_method("set_selected_background_preset_id"),
			"CharacterData should NOT have preset integration yet (TDD - test first!)")

		character_data.free()

func test_preset_option_resource_loading():
	# This should FAIL - no preset data resources exist yet
	var preset_data_path = "res://assets/data/CharacterBackgroundPresets.tres"
	assert_false(ResourceLoader.exists(preset_data_path),
		"Preset data resource should NOT exist yet (TDD - test first!)")