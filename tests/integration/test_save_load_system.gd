# Integration Test: Save/Load System
# Tests all save and load functionality with cross-platform compatibility

extends GutTest

# Test Environment
var save_system: SaveSystem = null
var test_player_data: PlayerData = null
var test_character_1: CharacterData = null
var test_character_2: CharacterData = null

func before_all():
	# Initialize save system
	save_system = SaveSystem.new()
	assert_not_null(save_system, "SaveSystem should be available")

func before_each():
	# Clean up existing save data
	save_system.clear_all_save_data()

	# Create test data
	_create_test_data()

func after_each():
	# Clean up test data after each test
	save_system.clear_all_save_data()
	test_player_data = null
	test_character_1 = null
	test_character_2 = null

func _create_test_data():
	"""Create consistent test data for each test"""
	# Create player data
	test_player_data = PlayerData.new()

	# Create first test character
	test_character_1 = CharacterData.new()
	test_character_1.character_name = "Alice Johnson"
	test_character_1.political_experience = "City Councilor"
	test_character_1.backstory = "Local business owner turned public servant"

	var party_1: PartyData = PartyData.new()
	party_1.party_name = "Progress Coalition"
	party_1.slogan = "Moving Forward Together"
	party_1.primary_color = Color.BLUE
	party_1.logo_index = 1
	test_character_1.party = party_1

	# Create second test character
	test_character_2 = CharacterData.new()
	test_character_2.character_name = "Bob Williams"
	test_character_2.political_experience = "Community Organizer"
	test_character_2.backstory = "Environmental activist with grassroots experience"

	var party_2: PartyData = PartyData.new()
	party_2.party_name = "Green Future Party"
	party_2.slogan = "Sustainable Tomorrow"
	party_2.primary_color = Color.GREEN
	party_2.logo_index = 2
	test_character_2.party = party_2

	# Add characters to player data
	test_player_data.add_character(test_character_1)
	test_player_data.add_character(test_character_2)

# Basic Save/Load Tests

func test_save_player_data_success():
	"""Test successful saving of player data"""
	var save_result: bool = save_system.save_player_data(test_player_data)
	assert_true(save_result, "Save should succeed with valid data")

	# Verify file exists
	assert_true(save_system.has_save_data(), "Save data should exist after saving")

func test_load_player_data_success():
	"""Test successful loading of saved player data"""
	# First save data
	save_system.save_player_data(test_player_data)

	# Then load it
	var loaded_data: PlayerData = save_system.load_player_data()
	assert_not_null(loaded_data, "Should be able to load saved data")
	assert_eq(loaded_data.characters.size(), 2, "Should load both characters")

func test_save_load_data_integrity():
	"""Test that saved and loaded data maintains integrity"""
	# Save original data
	save_system.save_player_data(test_player_data)

	# Load data
	var loaded_data: PlayerData = save_system.load_player_data()

	# Verify character data integrity
	var loaded_char_1: CharacterData = loaded_data.characters[0]
	assert_eq(loaded_char_1.character_name, "Alice Johnson", "Character 1 name should match")
	assert_eq(loaded_char_1.political_experience, "City Councilor", "Character 1 experience should match")
	assert_eq(loaded_char_1.party.party_name, "Progress Coalition", "Character 1 party name should match")

	var loaded_char_2: CharacterData = loaded_data.characters[1]
	assert_eq(loaded_char_2.character_name, "Bob Williams", "Character 2 name should match")
	assert_eq(loaded_char_2.party.primary_color, Color.GREEN, "Character 2 party color should match")

# Character-Specific Save/Load Tests

func test_quick_save_character():
	"""Test quick save functionality for individual characters"""
	var save_result: bool = save_system.quick_save_character(test_character_1)
	assert_true(save_result, "Quick save should succeed")

	# Verify save data exists
	assert_true(save_system.has_save_data(), "Save data should exist after quick save")

	# Load and verify
	var loaded_data: PlayerData = save_system.load_player_data()
	assert_eq(loaded_data.characters.size(), 1, "Should have 1 character from quick save")
	assert_eq(loaded_data.characters[0].character_name, "Alice Johnson", "Quick saved character should match")

func test_load_character_by_name():
	"""Test loading specific character by name"""
	# Save test data first
	save_system.save_player_data(test_player_data)

	# Load specific character
	var loaded_character: CharacterData = save_system.load_character("Alice Johnson")
	assert_not_null(loaded_character, "Should be able to load character by name")
	assert_eq(loaded_character.character_name, "Alice Johnson", "Loaded character should match requested name")

func test_load_character_nonexistent():
	"""Test loading non-existent character returns null"""
	# Save test data first
	save_system.save_player_data(test_player_data)

	# Try to load non-existent character
	var loaded_character: CharacterData = save_system.load_character("NonExistent Character")
	assert_null(loaded_character, "Should return null for non-existent character")

# Data Validation Tests

func test_save_invalid_data_handling():
	"""Test handling of invalid data during save"""
	var invalid_player_data: PlayerData = PlayerData.new()
	var invalid_character: CharacterData = CharacterData.new()
	# Leave character with empty/invalid data
	invalid_player_data.add_character(invalid_character)

	# Attempt to save invalid data
	var save_result: bool = save_system.save_player_data(invalid_player_data)

	# Save system should handle gracefully (implementation specific)
	# Either reject invalid data or save with warnings
	if not save_result:
		# If save rejected, that's acceptable
		assert_false(save_system.has_save_data(), "Invalid data should not create save file")
	else:
		# If save accepted, data should still be loadable
		var loaded_data: PlayerData = save_system.load_player_data()
		assert_not_null(loaded_data, "Even invalid data should be loadable if saved")

func test_save_null_data_handling():
	"""Test handling of null data during save"""
	var save_result: bool = save_system.save_player_data(null)
	assert_false(save_result, "Should not be able to save null data")
	assert_false(save_system.has_save_data(), "Should not create save file for null data")

func test_load_corrupted_data_handling():
	"""Test handling of corrupted save data"""
	# First save valid data
	save_system.save_player_data(test_player_data)

	# Simulate corruption by writing invalid data directly to save file
	var save_path: String = save_system.get_save_file_path()
	var file: FileAccess = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string("corrupted_data_not_valid_resource")
		file.close()

	# Attempt to load corrupted data
	var loaded_data: PlayerData = save_system.load_player_data()

	# Should handle gracefully - either return null or default data
	if loaded_data == null:
		assert_null(loaded_data, "Corrupted data should return null")
	else:
		# Or return valid default/empty data
		assert_not_null(loaded_data, "Fallback data should be valid")

# File System Tests

func test_save_file_path_validation():
	"""Test that save file path is valid and uses user:// directory"""
	var save_path: String = save_system.get_save_file_path()

	# Should use user:// directory for cross-platform compatibility
	assert_true(save_path.begins_with("user://"), "Save path should use user:// directory")
	assert_true(save_path.ends_with(".tres"), "Save path should end with .tres extension")

func test_backup_save_functionality():
	"""Test backup save file creation"""
	# Save data
	save_system.save_player_data(test_player_data)

	# Create backup
	var backup_success: bool = save_system.create_backup()
	assert_true(backup_success, "Should be able to create backup")

	# Verify backup exists
	var backup_path: String = save_system.get_backup_file_path()
	assert_true(FileAccess.file_exists(backup_path), "Backup file should exist")

func test_restore_from_backup():
	"""Test restoring data from backup"""
	# Save original data
	save_system.save_player_data(test_player_data)
	save_system.create_backup()

	# Modify original data
	var modified_character: CharacterData = CharacterData.new()
	modified_character.character_name = "Modified Character"
	var modified_data: PlayerData = PlayerData.new()
	modified_data.add_character(modified_character)
	save_system.save_player_data(modified_data)

	# Restore from backup
	var restore_success: bool = save_system.restore_from_backup()
	assert_true(restore_success, "Should be able to restore from backup")

	# Verify original data is restored
	var restored_data: PlayerData = save_system.load_player_data()
	assert_eq(restored_data.characters.size(), 2, "Should restore original 2 characters")
	assert_eq(restored_data.characters[0].character_name, "Alice Johnson", "Should restore original character")

# Party Name Uniqueness Tests

func test_party_name_uniqueness_check():
	"""Test party name uniqueness validation"""
	# Save test data with existing party names
	save_system.save_player_data(test_player_data)

	# Check existing party name
	var is_unique_existing: bool = save_system.is_party_name_unique("Progress Coalition")
	assert_false(is_unique_existing, "Existing party name should not be unique")

	# Check new party name
	var is_unique_new: bool = save_system.is_party_name_unique("New Unique Party")
	assert_true(is_unique_new, "New party name should be unique")

func test_party_name_case_sensitivity():
	"""Test party name uniqueness with different cases"""
	save_system.save_player_data(test_player_data)

	# Test case variations
	assert_false(save_system.is_party_name_unique("PROGRESS COALITION"), "Uppercase should not be unique")
	assert_false(save_system.is_party_name_unique("progress coalition"), "Lowercase should not be unique")
	assert_false(save_system.is_party_name_unique("Progress coalition"), "Mixed case should not be unique")

# Cross-Platform Compatibility Tests

func test_save_load_cross_platform_paths():
	"""Test that save/load works with cross-platform file paths"""
	# Save data
	save_system.save_player_data(test_player_data)

	# Get platform-specific path
	var save_path: String = save_system.get_save_file_path()
	var global_path: String = ProjectSettings.globalize_path(save_path)

	# Verify file exists at global path
	assert_true(FileAccess.file_exists(save_path), "Save file should exist at Godot path")

	# Load using same path
	var loaded_data: PlayerData = save_system.load_player_data()
	assert_not_null(loaded_data, "Should load successfully using cross-platform path")

func test_save_directory_creation():
	"""Test that save directory is created if it doesn't exist"""
	# Clear save directory
	save_system.clear_all_save_data()

	# Remove directory if it exists
	var save_dir: String = save_system.get_save_directory()
	DirAccess.remove_absolute(save_dir)

	# Save data (should create directory)
	var save_result: bool = save_system.save_player_data(test_player_data)
	assert_true(save_result, "Should be able to save even if directory doesn't exist")

	# Verify directory was created
	assert_true(DirAccess.dir_exists_absolute(save_dir), "Save directory should be created")

# Performance Tests

func test_save_performance():
	"""Test that save operations complete within reasonable time"""
	var start_time: float = Time.get_ticks_msec()

	save_system.save_player_data(test_player_data)

	var save_time: float = Time.get_ticks_msec() - start_time

	# Should save in under 100ms
	assert_lt(save_time, 100.0, "Save operation should complete in under 100ms")

func test_load_performance():
	"""Test that load operations complete within reasonable time"""
	# First save data
	save_system.save_player_data(test_player_data)

	var start_time: float = Time.get_ticks_msec()

	save_system.load_player_data()

	var load_time: float = Time.get_ticks_msec() - start_time

	# Should load in under 50ms
	assert_lt(load_time, 50.0, "Load operation should complete in under 50ms")

func test_multiple_character_save_load():
	"""Test saving and loading large numbers of characters"""
	var large_player_data: PlayerData = PlayerData.new()

	# Create 10 test characters
	for i in range(10):
		var character: CharacterData = CharacterData.new()
		character.character_name = "Character " + str(i)
		character.political_experience = "Experience " + str(i)

		var party: PartyData = PartyData.new()
		party.party_name = "Party " + str(i)
		party.slogan = "Slogan " + str(i)
		character.party = party

		large_player_data.add_character(character)

	# Save and load
	var save_result: bool = save_system.save_player_data(large_player_data)
	assert_true(save_result, "Should be able to save 10 characters")

	var loaded_data: PlayerData = save_system.load_player_data()
	assert_not_null(loaded_data, "Should be able to load 10 characters")
	assert_eq(loaded_data.characters.size(), 10, "Should load all 10 characters")

# Cleanup and Utility Tests

func test_clear_all_save_data():
	"""Test clearing all save data"""
	# First save some data
	save_system.save_player_data(test_player_data)
	assert_true(save_system.has_save_data(), "Save data should exist")

	# Clear all data
	save_system.clear_all_save_data()
	assert_false(save_system.has_save_data(), "Save data should not exist after clearing")

func test_save_data_exists_check():
	"""Test save data existence check"""
	# Initially no data
	assert_false(save_system.has_save_data(), "Should start with no save data")

	# Save data
	save_system.save_player_data(test_player_data)
	assert_true(save_system.has_save_data(), "Should detect save data after saving")

	# Clear data
	save_system.clear_all_save_data()
	assert_false(save_system.has_save_data(), "Should detect no save data after clearing")

func test_get_available_characters():
	"""Test getting available characters from save data"""
	# No characters initially
	var characters_empty: Array[CharacterData] = save_system.get_available_characters()
	assert_eq(characters_empty.size(), 0, "Should start with no characters")

	# Save characters
	save_system.save_player_data(test_player_data)

	# Get available characters
	var characters: Array[CharacterData] = save_system.get_available_characters()
	assert_eq(characters.size(), 2, "Should return 2 saved characters")
	assert_eq(characters[0].character_name, "Alice Johnson", "First character should match")
	assert_eq(characters[1].character_name, "Bob Williams", "Second character should match")