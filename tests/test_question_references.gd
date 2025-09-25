extends GutTest

# Test question reference validation for next_question_id links
# This test ensures all question references are valid and no broken links exist

func test_valid_question_references_pass_validation() -> void:
	# Test that valid question references pass validation
	var test_data: Dictionary = {
		"version": "1.0.0",
		"questions": {
			"q1": {
				"text": "First question",
				"tags": ["test"],
				"is_fallback": false,
				"answers": [
					{
						"text": "Go to q2",
						"effects": {"stats": {"test": 1}},
						"next_question_id": "q2"
					},
					{
						"text": "Go to q3",
						"effects": {"stats": {"test": 1}},
						"next_question_id": "q3"
					}
				]
			},
			"q2": {
				"text": "Second question",
				"tags": ["test"],
				"is_fallback": false,
				"answers": [
					{
						"text": "Final answer",
						"effects": {"stats": {"test": 1}}
					}
				]
			},
			"q3": {
				"text": "Third question",
				"tags": ["test"],
				"is_fallback": false,
				"answers": [
					{
						"text": "Back to q2",
						"effects": {"stats": {"test": 1}},
						"next_question_id": "q2"
					}
				]
			}
		},
		"fallback_questions": ["q2"]
	}

	var validation_errors: Array[String] = validate_question_references(test_data)
	assert_true(validation_errors.is_empty(), "Valid question references should pass validation")

func test_broken_next_question_id_fails_validation() -> void:
	# Test that broken next_question_id references fail validation
	var test_data: Dictionary = {
		"version": "1.0.0",
		"questions": {
			"q1": {
				"text": "Question with broken reference",
				"tags": ["test"],
				"is_fallback": false,
				"answers": [
					{
						"text": "Go to non-existent question",
						"effects": {"stats": {"test": 1}},
						"next_question_id": "non_existent_question"
					}
				]
			}
		},
		"fallback_questions": []
	}

	var validation_errors: Array[String] = validate_question_references(test_data)
	assert_false(validation_errors.is_empty(), "Broken question reference should fail validation")
	assert_true(validation_errors[0].contains("non_existent_question"), "Error should mention the broken reference")

func test_broken_fallback_question_fails_validation() -> void:
	# Test that broken fallback question references fail validation
	var test_data: Dictionary = {
		"version": "1.0.0",
		"questions": {
			"q1": {
				"text": "Valid question",
				"tags": ["test"],
				"is_fallback": true,
				"answers": [
					{
						"text": "Answer",
						"effects": {"stats": {"test": 1}}
					}
				]
			}
		},
		"fallback_questions": ["q1", "non_existent_fallback"]
	}

	var validation_errors: Array[String] = validate_question_references(test_data)
	assert_false(validation_errors.is_empty(), "Broken fallback reference should fail validation")
	assert_true(validation_errors[0].contains("non_existent_fallback"), "Error should mention the broken fallback reference")

func test_circular_reference_detection() -> void:
	# Test that circular references are detected
	var test_data: Dictionary = {
		"version": "1.0.0",
		"questions": {
			"q1": {
				"text": "First question",
				"tags": ["test"],
				"is_fallback": false,
				"answers": [
					{
						"text": "Go to q2",
						"effects": {"stats": {"test": 1}},
						"next_question_id": "q2"
					}
				]
			},
			"q2": {
				"text": "Second question",
				"tags": ["test"],
				"is_fallback": false,
				"answers": [
					{
						"text": "Back to q1",
						"effects": {"stats": {"test": 1}},
						"next_question_id": "q1"
					}
				]
			}
		},
		"fallback_questions": []
	}

	var circular_references: Array[String] = detect_circular_references(test_data)
	assert_false(circular_references.is_empty(), "Circular references should be detected")

func test_self_referencing_question_fails_validation() -> void:
	# Test that self-referencing questions fail validation
	var test_data: Dictionary = {
		"version": "1.0.0",
		"questions": {
			"q1": {
				"text": "Self-referencing question",
				"tags": ["test"],
				"is_fallback": false,
				"answers": [
					{
						"text": "Go to self",
						"effects": {"stats": {"test": 1}},
						"next_question_id": "q1"
					}
				]
			}
		},
		"fallback_questions": []
	}

	var validation_errors: Array[String] = validate_question_references(test_data)
	assert_false(validation_errors.is_empty(), "Self-referencing question should fail validation")

func test_orphaned_questions_detection() -> void:
	# Test detection of orphaned questions (not reachable from any path)
	var test_data: Dictionary = {
		"version": "1.0.0",
		"questions": {
			"q1": {
				"text": "Starting question",
				"tags": ["start"],
				"is_fallback": false,
				"answers": [
					{
						"text": "Go to q2",
						"effects": {"stats": {"test": 1}},
						"next_question_id": "q2"
					}
				]
			},
			"q2": {
				"text": "Second question",
				"tags": ["middle"],
				"is_fallback": false,
				"answers": [
					{
						"text": "End",
						"effects": {"stats": {"test": 1}}
					}
				]
			},
			"q_orphan": {
				"text": "Orphaned question - not referenced anywhere",
				"tags": ["orphan"],
				"is_fallback": false,
				"answers": [
					{
						"text": "Orphan answer",
						"effects": {"stats": {"test": 1}}
					}
				]
			}
		},
		"fallback_questions": []
	}

	var orphaned_questions: Array[String] = detect_orphaned_questions(test_data)
	assert_false(orphaned_questions.is_empty(), "Orphaned questions should be detected")
	assert_true(orphaned_questions.has("q_orphan"), "q_orphan should be detected as orphaned")

func test_empty_next_question_id_is_valid() -> void:
	# Test that empty/missing next_question_id is valid (indicates interview end)
	var test_data: Dictionary = {
		"version": "1.0.0",
		"questions": {
			"q1": {
				"text": "Final question",
				"tags": ["test"],
				"is_fallback": false,
				"answers": [
					{
						"text": "End interview",
						"effects": {"stats": {"test": 1}}
						# No next_question_id - this should be valid
					}
				]
			}
		},
		"fallback_questions": []
	}

	var validation_errors: Array[String] = validate_question_references(test_data)
	assert_true(validation_errors.is_empty(), "Missing next_question_id should be valid for interview termination")

# Placeholder functions - will be implemented in InterviewData validator

func validate_question_references(data: Dictionary) -> Array[String]:
	# Placeholder function - will be implemented in InterviewData class
	# Return non-empty array to ensure tests fail as required by TDD
	return ["Placeholder validation error"]

func detect_circular_references(data: Dictionary) -> Array[String]:
	# Placeholder function - will be implemented in InterviewData class
	# Return non-empty array to ensure tests fail as required by TDD
	return ["Placeholder circular reference error"]

func detect_orphaned_questions(data: Dictionary) -> Array[String]:
	# Placeholder function - will be implemented in InterviewData class
	# Return non-empty array to ensure tests fail as required by TDD
	return ["Placeholder orphaned question error"]