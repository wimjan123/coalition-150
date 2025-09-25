extends GutTest

# Test JSON schema validation for interviews.json structure
# This test validates that interview data follows the expected schema

var json_parser: JSON

func before_each() -> void:
	json_parser = JSON.new()

func after_each() -> void:
	json_parser = null

func test_valid_json_structure_passes_validation() -> void:
	# Test that a valid interview JSON structure passes validation
	var test_data: Dictionary = {
		"version": "1.0.0",
		"questions": {
			"q1": {
				"text": "Test question",
				"tags": ["test"],
				"is_fallback": false,
				"answers": [
					{
						"text": "Test answer",
						"effects": {"stats": {"test": 1}},
						"next_question_id": "q2"
					}
				]
			},
			"q2": {
				"text": "Second question",
				"tags": [],
				"is_fallback": true,
				"answers": [
					{
						"text": "Final answer",
						"effects": {"stats": {"test": 1}}
					}
				]
			}
		},
		"fallback_questions": ["q2"]
	}

	# This should pass validation when InterviewData validator is implemented
	var validation_result: bool = validate_interview_data(test_data)
	assert_true(validation_result, "Valid interview data should pass validation")

func test_missing_version_fails_validation() -> void:
	# Test that missing version field fails validation
	var test_data: Dictionary = {
		"questions": {},
		"fallback_questions": []
	}

	var validation_result: bool = validate_interview_data(test_data)
	assert_false(validation_result, "Missing version should fail validation")

func test_missing_questions_fails_validation() -> void:
	# Test that missing questions field fails validation
	var test_data: Dictionary = {
		"version": "1.0.0",
		"fallback_questions": []
	}

	var validation_result: bool = validate_interview_data(test_data)
	assert_false(validation_result, "Missing questions should fail validation")

func test_missing_fallback_questions_fails_validation() -> void:
	# Test that missing fallback_questions field fails validation
	var test_data: Dictionary = {
		"version": "1.0.0",
		"questions": {}
	}

	var validation_result: bool = validate_interview_data(test_data)
	assert_false(validation_result, "Missing fallback_questions should fail validation")

func test_empty_questions_fails_validation() -> void:
	# Test that empty questions object fails validation
	var test_data: Dictionary = {
		"version": "1.0.0",
		"questions": {},
		"fallback_questions": ["q1"]
	}

	var validation_result: bool = validate_interview_data(test_data)
	assert_false(validation_result, "Empty questions should fail validation")

func test_invalid_version_format_fails_validation() -> void:
	# Test that invalid version format fails validation
	var test_data: Dictionary = {
		"version": "invalid_version",
		"questions": {
			"q1": {
				"text": "Test",
				"tags": [],
				"is_fallback": true,
				"answers": [{"text": "Test", "effects": {}}]
			}
		},
		"fallback_questions": ["q1"]
	}

	var validation_result: bool = validate_interview_data(test_data)
	assert_false(validation_result, "Invalid version format should fail validation")

func test_question_missing_required_fields_fails_validation() -> void:
	# Test that questions missing required fields fail validation
	var test_data: Dictionary = {
		"version": "1.0.0",
		"questions": {
			"q1": {
				"text": "Test question",
				# Missing tags, is_fallback, and answers
			}
		},
		"fallback_questions": []
	}

	var validation_result: bool = validate_interview_data(test_data)
	assert_false(validation_result, "Question missing required fields should fail validation")

func test_answer_missing_required_fields_fails_validation() -> void:
	# Test that answers missing required fields fail validation
	var test_data: Dictionary = {
		"version": "1.0.0",
		"questions": {
			"q1": {
				"text": "Test question",
				"tags": [],
				"is_fallback": true,
				"answers": [
					{
						# Missing text and effects
					}
				]
			}
		},
		"fallback_questions": ["q1"]
	}

	var validation_result: bool = validate_interview_data(test_data)
	assert_false(validation_result, "Answer missing required fields should fail validation")

# Placeholder function - will be implemented in InterviewData validator
func validate_interview_data(data: Dictionary) -> bool:
	# This function will be implemented in the InterviewData class
	# For now, return false to ensure tests fail as required by TDD
	return false