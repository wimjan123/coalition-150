class_name InterviewData extends RefCounted

# Validator and container for interview data loaded from JSON
# Following Godot constitution: explicit typing, <20 line functions, snake_case

var questions: Dictionary  # String -> InterviewQuestion
var fallback_questions: Array[String]
var version: String

func _init() -> void:
	questions = {}
	fallback_questions = []
	version = ""

func load_from_dictionary(data: Dictionary) -> bool:
	# Load and validate interview data from dictionary
	if not _validate_basic_structure(data):
		return false

	version = data.get("version", "")
	_load_questions(data.get("questions", {}))
	_load_fallback_questions(data.get("fallback_questions", []))

	return validate_all_references()

func validate_interview_data(data: Dictionary) -> Array[String]:
	# Comprehensive validation returning list of errors
	var errors: Array[String] = []

	errors.append_array(_validate_version(data))
	errors.append_array(_validate_questions_structure(data))
	errors.append_array(_validate_fallback_structure(data))

	return errors

func validate_question_references(data: Dictionary) -> Array[String]:
	# Validate all next_question_id references are valid
	var errors: Array[String] = []
	var question_ids: Array[String] = []
	question_ids.assign(data.get("questions", {}).keys())

	for question_id in question_ids:
		var question_data: Dictionary = data.questions[question_id]
		errors.append_array(_validate_question_answers(question_data, question_ids))

	# Validate fallback question references
	var fallback_ids: Array = data.get("fallback_questions", [])
	for fallback_id in fallback_ids:
		if not question_ids.has(fallback_id):
			errors.append("Fallback question '" + str(fallback_id) + "' does not exist")

	return errors

func validate_all_references() -> bool:
	# Validate that all question references are valid
	var question_ids: Array[String] = []
	question_ids.assign(questions.keys())

	for question in questions.values():
		for answer in question.answers:
			if answer.has_next_question() and not question_ids.has(answer.next_question_id):
				return false

	for fallback_id in fallback_questions:
		if not question_ids.has(fallback_id):
			return false

	return true

func get_fallback_question_ids() -> Array[String]:
	# Get list of fallback question IDs
	return fallback_questions.duplicate()

func get_question_by_id(question_id: String) -> InterviewQuestion:
	# Retrieve question by ID, null if not found
	return questions.get(question_id, null)

# Private validation methods

func _validate_basic_structure(data: Dictionary) -> bool:
	# Check basic required fields
	return data.has("version") and data.has("questions") and data.has("fallback_questions")

func _validate_version(data: Dictionary) -> Array[String]:
	# Validate version format (semantic versioning)
	var errors: Array[String] = []
	var version_str: String = data.get("version", "")

	if version_str.is_empty():
		errors.append("Missing version field")
	elif not version_str.match("^\\d+\\.\\d+\\.\\d+$"):
		errors.append("Invalid version format, expected semantic versioning")

	return errors

func _validate_questions_structure(data: Dictionary) -> Array[String]:
	# Validate questions dictionary structure
	var errors: Array[String] = []
	var questions_dict: Dictionary = data.get("questions", {})

	if questions_dict.is_empty():
		errors.append("Questions dictionary cannot be empty")

	for question_id in questions_dict.keys():
		var question_data: Dictionary = questions_dict[question_id]
		errors.append_array(_validate_single_question(question_data, question_id))

	return errors

func _validate_fallback_structure(data: Dictionary) -> Array[String]:
	# Validate fallback_questions array structure
	var errors: Array[String] = []
	var fallback_array: Array = data.get("fallback_questions", [])

	if fallback_array.is_empty():
		errors.append("Must have at least one fallback question")

	return errors

func _validate_single_question(question_data: Dictionary, question_id: String) -> Array[String]:
	# Validate individual question structure
	var errors: Array[String] = []

	if not question_data.has("text") or question_data.text.is_empty():
		errors.append("Question '" + question_id + "' missing or empty text")

	if not question_data.has("answers") or question_data.answers.size() < 2:
		errors.append("Question '" + question_id + "' must have at least 2 answers")

	return errors

func _validate_question_answers(question_data: Dictionary, valid_ids: Array[String]) -> Array[String]:
	# Validate answers within a question
	var errors: Array[String] = []
	var answers: Array = question_data.get("answers", [])

	for answer in answers:
		if answer.has("next_question_id") and not answer.next_question_id.is_empty():
			if not valid_ids.has(answer.next_question_id):
				errors.append("Invalid next_question_id: " + answer.next_question_id)

	return errors

func _load_questions(questions_data: Dictionary) -> void:
	# Load questions from dictionary data
	for question_id in questions_data.keys():
		var question_data: Dictionary = questions_data[question_id]
		questions[question_id] = InterviewQuestion.from_dictionary(question_id, question_data)

func _load_fallback_questions(fallback_data: Array) -> void:
	# Load fallback question IDs
	fallback_questions.assign(fallback_data)