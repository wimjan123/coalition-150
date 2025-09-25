extends GutTest

# Test interview data loading and malformed JSON handling
# This test ensures robust error handling for various JSON loading scenarios

func test_load_valid_json_file_succeeds() -> void:
	# Test that loading a valid JSON file succeeds
	var file_path: String = "res://tests/data/mock_interview_valid.json"

	var loaded_data: Dictionary = load_interview_json(file_path)
	assert_false(loaded_data.is_empty(), "Valid JSON file should load successfully")
	assert_true(loaded_data.has("version"), "Loaded data should have version field")
	assert_true(loaded_data.has("questions"), "Loaded data should have questions field")
	assert_true(loaded_data.has("fallback_questions"), "Loaded data should have fallback_questions field")

func test_load_nonexistent_file_returns_empty() -> void:
	# Test that loading a non-existent file returns empty dictionary
	var file_path: String = "res://nonexistent_file.json"

	var loaded_data: Dictionary = load_interview_json(file_path)
	assert_true(loaded_data.is_empty(), "Non-existent file should return empty dictionary")

func test_load_malformed_json_returns_empty() -> void:
	# Test that loading malformed JSON returns empty dictionary
	var file_path: String = "res://tests/data/mock_interview_malformed.json"

	var loaded_data: Dictionary = load_interview_json(file_path)
	assert_true(loaded_data.is_empty(), "Malformed JSON should return empty dictionary")

func test_load_empty_file_returns_empty() -> void:
	# Test that loading an empty file returns empty dictionary
	# First create an empty test file
	var empty_file_path: String = "res://tests/data/empty_file.json"
	create_empty_test_file(empty_file_path)

	var loaded_data: Dictionary = load_interview_json(empty_file_path)
	assert_true(loaded_data.is_empty(), "Empty file should return empty dictionary")

func test_load_invalid_permissions_returns_empty() -> void:
	# Test that files with invalid permissions return empty dictionary
	# This is platform-dependent, so we simulate the behavior
	var invalid_path: String = "/invalid/path/interview.json"

	var loaded_data: Dictionary = load_interview_json(invalid_path)
	assert_true(loaded_data.is_empty(), "Invalid path should return empty dictionary")

func test_json_parse_error_handling() -> void:
	# Test that JSON parse errors are handled gracefully
	var json_string: String = '{"invalid": json, "structure"}'

	var parsed_data: Dictionary = parse_json_string(json_string)
	assert_true(parsed_data.is_empty(), "Invalid JSON string should return empty dictionary")

func test_large_json_file_loading() -> void:
	# Test that large JSON files can be loaded efficiently
	var large_data: Dictionary = create_large_interview_data()
	var temp_file_path: String = "res://tests/data/large_interview.json"

	# Save and then load the large data
	save_json_data(large_data, temp_file_path)
	var loaded_data: Dictionary = load_interview_json(temp_file_path)

	assert_false(loaded_data.is_empty(), "Large JSON file should load successfully")
	assert_eq(loaded_data.questions.size(), large_data.questions.size(), "All questions should be loaded")

func test_json_loading_performance() -> void:
	# Test that JSON loading meets performance requirements (<100ms)
	var file_path: String = "res://tests/data/mock_interview_valid.json"

	var start_time: int = Time.get_ticks_msec()
	var loaded_data: Dictionary = load_interview_json(file_path)
	var end_time: int = Time.get_ticks_msec()

	var load_time: int = end_time - start_time
	assert_lt(load_time, 100, "JSON loading should complete in under 100ms")

# Helper functions - will be replaced by actual implementation

func load_interview_json(file_path: String) -> Dictionary:
	# Placeholder function - will be implemented in InterviewManager
	# Return empty dictionary to ensure tests fail as required by TDD
	return {}

func parse_json_string(json_string: String) -> Dictionary:
	# Placeholder function - will be implemented in InterviewManager
	# Return empty dictionary to ensure tests fail as required by TDD
	return {}

func create_empty_test_file(file_path: String) -> void:
	# Helper to create empty test files
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	if file != null:
		file.close()

func save_json_data(data: Dictionary, file_path: String) -> void:
	# Helper to save JSON data for testing
	var json_string: String = JSON.stringify(data)
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	if file != null:
		file.store_string(json_string)
		file.close()

func create_large_interview_data() -> Dictionary:
	# Helper to create large test data set
	var large_data: Dictionary = {
		"version": "1.0.0",
		"questions": {},
		"fallback_questions": []
	}

	# Create 100 test questions
	for i in range(100):
		var question_id: String = "test_q" + str(i)
		large_data.questions[question_id] = {
			"text": "Test question " + str(i),
			"tags": ["test"],
			"is_fallback": false,
			"answers": [
				{
					"text": "Answer " + str(i),
					"effects": {"stats": {"test": 1}}
				}
			]
		}

		if i < 10:  # First 10 are fallback questions
			large_data.questions[question_id].is_fallback = true
			large_data.fallback_questions.append(question_id)

	return large_data