# Unit test for CharacterBackgroundPresets collection validation
# This test MUST FAIL until CharacterBackgroundPresets resource class is implemented (T017)

extends GutTest

var presets_interface_script = preload("res://specs/003-refine-the-character/contracts/CharacterBackgroundPresetsInterface.gd")
var preset_option_interface_script = preload("res://specs/003-refine-the-character/contracts/PresetOptionInterface.gd")

func before_each():
	gut.p("Testing CharacterBackgroundPresets collection validation logic")

func create_test_preset_option(preset_id: String, difficulty: int, alignment: String, satirical: bool = false):
	# Helper to create test preset options
	var preset = preset_option_interface_script.new()
	preset.id = preset_id
	preset.display_name = "Test " + preset_id
	preset.background_text = "Test background for " + preset_id
	preset.character_archetype = "Test Archetype"
	preset.difficulty_rating = difficulty
	preset.difficulty_label = "Level " + str(difficulty)
	preset.gameplay_impact = "Test impact " + str(difficulty)
	preset.political_alignment = alignment
	preset.is_satirical = satirical
	return preset

func test_presets_collection_validation_empty():
	# Test validation fails with empty preset collection
	var presets = presets_interface_script.new()

	presets.preset_options = []
	presets.version = "1.0"

	assert_false(presets.is_valid(), "Empty preset collection should fail validation")
	presets.free()

func test_presets_collection_validation_correct_count():
	# Test validation passes with exactly 10 presets
	var presets = presets_interface_script.new()

	# Create exactly 10 test presets
	var preset_list = []
	for i in range(10):
		var preset = create_test_preset_option("preset_" + str(i), i + 1, "Neutral")
		preset_list.append(preset)

	presets.preset_options = preset_list
	presets.version = "1.0"

	assert_true(presets.is_valid(), "Collection with 10 presets should pass validation")

	# Clean up
	for preset in preset_list:
		preset.free()
	presets.free()

func test_presets_collection_validation_wrong_count():
	# Test validation fails with incorrect number of presets
	var presets = presets_interface_script.new()

	# Test with 5 presets (too few)
	var preset_list_few = []
	for i in range(5):
		var preset = create_test_preset_option("preset_" + str(i), i + 1, "Neutral")
		preset_list_few.append(preset)

	presets.preset_options = preset_list_few
	presets.version = "1.0"
	assert_false(presets.is_valid(), "Collection with 5 presets should fail validation")

	# Test with 15 presets (too many)
	var preset_list_many = []
	for i in range(15):
		var preset = create_test_preset_option("preset_" + str(i), i + 1, "Neutral")
		preset_list_many.append(preset)

	presets.preset_options = preset_list_many
	assert_false(presets.is_valid(), "Collection with 15 presets should fail validation")

	# Clean up
	for preset in preset_list_few:
		preset.free()
	for preset in preset_list_many:
		preset.free()
	presets.free()

func test_presets_collection_sorting_by_difficulty():
	# Test get_sorted_by_difficulty() returns presets in correct order
	var presets = presets_interface_script.new()

	# Create presets with random difficulty order
	var preset_list = []
	var difficulties = [7, 3, 10, 1, 5, 8, 2, 9, 4, 6]

	for i in range(10):
		var preset = create_test_preset_option("preset_" + str(difficulties[i]), difficulties[i], "Neutral")
		preset_list.append(preset)

	presets.preset_options = preset_list

	var sorted_presets = presets.get_sorted_by_difficulty()
	assert_true(sorted_presets is Array, "Sorted presets should return Array")
	assert_eq(sorted_presets.size(), 10, "Sorted array should contain all presets")

	# Verify sorting order (ascending difficulty)
	for i in range(sorted_presets.size() - 1):
		var current_difficulty = sorted_presets[i].difficulty_rating
		var next_difficulty = sorted_presets[i + 1].difficulty_rating
		assert_true(current_difficulty <= next_difficulty,
			"Preset at index " + str(i) + " should have difficulty <= next preset")

	# Clean up
	for preset in preset_list:
		preset.free()
	presets.free()

func test_presets_collection_lookup_by_id():
	# Test get_preset_by_id() correctly finds presets
	var presets = presets_interface_script.new()

	var preset_list = []
	for i in range(10):
		var preset = create_test_preset_option("unique_" + str(i), i + 1, "Neutral")
		preset_list.append(preset)

	presets.preset_options = preset_list

	# Test finding existing preset
	var found_preset = presets.get_preset_by_id("unique_5")
	assert_not_null(found_preset, "Should find existing preset by ID")
	assert_eq(found_preset.id, "unique_5", "Found preset should have correct ID")

	# Test searching for non-existent preset
	var missing_preset = presets.get_preset_by_id("nonexistent")
	assert_null(missing_preset, "Should return null for non-existent preset ID")

	# Clean up
	for preset in preset_list:
		preset.free()
	presets.free()

func test_presets_collection_satirical_filtering():
	# Test get_satirical_presets() filters correctly
	var presets = presets_interface_script.new()

	var preset_list = []
	# Create 6 normal presets and 4 satirical presets
	for i in range(6):
		var preset = create_test_preset_option("normal_" + str(i), i + 1, "Neutral", false)
		preset_list.append(preset)

	for i in range(4):
		var preset = create_test_preset_option("satirical_" + str(i), i + 7, "Populist", true)
		preset_list.append(preset)

	presets.preset_options = preset_list

	var satirical_presets = presets.get_satirical_presets()
	assert_true(satirical_presets is Array, "Satirical presets should return Array")
	assert_eq(satirical_presets.size(), 4, "Should return exactly 4 satirical presets")

	# Verify all returned presets are satirical
	for preset in satirical_presets:
		assert_true(preset.is_satirical, "All returned presets should be satirical")

	# Clean up
	for preset in preset_list:
		preset.free()
	presets.free()

func test_presets_collection_political_balance():
	# Test get_political_balance() provides accurate balance reporting
	var presets = presets_interface_script.new()

	var preset_list = []
	var alignments = ["Progressive", "Progressive", "Conservative", "Conservative",
					 "Libertarian", "Libertarian", "Centrist", "Populist", "Populist", "Neutral"]

	for i in range(10):
		var preset = create_test_preset_option("balanced_" + str(i), i + 1, alignments[i])
		preset_list.append(preset)

	presets.preset_options = preset_list

	var balance = presets.get_political_balance()
	assert_true(balance is Dictionary, "Political balance should return Dictionary")

	# Verify expected alignment counts
	assert_eq(balance.get("Progressive", 0), 2, "Should have 2 Progressive presets")
	assert_eq(balance.get("Conservative", 0), 2, "Should have 2 Conservative presets")
	assert_eq(balance.get("Libertarian", 0), 2, "Should have 2 Libertarian presets")
	assert_eq(balance.get("Populist", 0), 2, "Should have 2 Populist presets")
	assert_eq(balance.get("Centrist", 0), 1, "Should have 1 Centrist preset")
	assert_eq(balance.get("Neutral", 0), 1, "Should have 1 Neutral preset")

	# Clean up
	for preset in preset_list:
		preset.free()
	presets.free()

func test_presets_collection_difficulty_progression():
	# Test validate_difficulty_progression() ensures proper difficulty curve
	var presets = presets_interface_script.new()

	# Test valid progression (1-10)
	var valid_preset_list = []
	for i in range(10):
		var preset = create_test_preset_option("progression_" + str(i), i + 1, "Neutral")
		valid_preset_list.append(preset)

	presets.preset_options = valid_preset_list
	assert_true(presets.validate_difficulty_progression(),
		"Valid 1-10 difficulty progression should pass validation")

	# Test invalid progression (missing difficulty levels)
	var invalid_preset_list = []
	var invalid_difficulties = [1, 2, 4, 5, 7, 8, 9, 10, 10, 10]  # Missing 3, 6; duplicate 10s

	for i in range(10):
		var preset = create_test_preset_option("invalid_" + str(i), invalid_difficulties[i], "Neutral")
		invalid_preset_list.append(preset)

	presets.preset_options = invalid_preset_list
	assert_false(presets.validate_difficulty_progression(),
		"Invalid difficulty progression should fail validation")

	# Clean up
	for preset in valid_preset_list:
		preset.free()
	for preset in invalid_preset_list:
		preset.free()
	presets.free()

func test_presets_collection_fallback_preset():
	# Test get_fallback_preset() returns appropriate default
	var presets = presets_interface_script.new()

	var preset_list = []
	for i in range(10):
		var preset = create_test_preset_option("fallback_" + str(i), i + 1, "Neutral")
		preset_list.append(preset)

	presets.preset_options = preset_list

	var fallback = presets.get_fallback_preset()
	assert_not_null(fallback, "Should return a fallback preset")

	# Fallback should typically be the easiest (difficulty 1) preset
	assert_eq(fallback.difficulty_rating, 1, "Fallback should be easiest preset")

	# Clean up
	for preset in preset_list:
		preset.free()
	presets.free()

func test_presets_collection_version_tracking():
	# Test version property for resource versioning
	var presets = presets_interface_script.new()

	presets.version = "1.0"
	assert_eq(presets.version, "1.0", "Version should be correctly set and retrieved")

	presets.version = "1.2.3"
	assert_eq(presets.version, "1.2.3", "Version should support semantic versioning format")

	presets.free()

# EXPECTED TO FAIL: These tests verify actual implementation doesn't exist yet (TDD)
func test_character_background_presets_implementation_not_exists():
	# This should FAIL - CharacterBackgroundPresets class doesn't exist yet
	var presets_path = "res://scripts/data/CharacterBackgroundPresets.gd"
	assert_false(ResourceLoader.exists(presets_path),
		"CharacterBackgroundPresets implementation should NOT exist yet (TDD - test first!)")

func test_preset_data_resource_file_not_exists():
	# This should FAIL - preset data .tres file doesn't exist yet
	var data_path = "res://assets/data/CharacterBackgroundPresets.tres"
	assert_false(ResourceLoader.exists(data_path),
		"Preset data resource should NOT exist yet (TDD - test first!)")

func test_preset_integration_with_ui_not_exists():
	# This should FAIL - UI integration hasn't been implemented yet
	var scene_path = "res://scenes/player/CharacterPartyCreation.tscn"

	if ResourceLoader.exists(scene_path):
		var scene = load(scene_path)
		if scene != null:
			var instance = scene.instantiate()

			# Should not have preset dropdown yet
			var preset_dropdown = instance.get_node_or_null("PresetDropdown")
			assert_null(preset_dropdown,
				"PresetDropdown should NOT exist in UI yet (TDD - test first!)")

			instance.queue_free()

func test_save_system_integration_not_exists():
	# This should FAIL - save system integration doesn't exist yet
	var save_system_path = "res://scripts/data/SaveSystem.gd"

	if ResourceLoader.exists(save_system_path):
		var save_system_script = load(save_system_path)
		var save_system = save_system_script.new()

		# Should not have preset-related save methods yet
		assert_false(save_system.has_method("save_selected_preset_id"),
			"SaveSystem should NOT have preset methods yet (TDD - test first!)")

		save_system.free()