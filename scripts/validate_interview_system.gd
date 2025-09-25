extends SceneTree

# Validation script for interview system
# Run with: godot --headless --script scripts/validate_interview_system.gd

func _init() -> void:
	print("=== Interview System Validation ===")

	# Test 1: Validate InterviewManager autoload
	if not validate_interview_manager():
		quit(1)
		return

	# Test 2: Validate JSON data loading
	if not validate_json_loading():
		quit(1)
		return

	# Test 3: Validate data models
	if not validate_data_models():
		quit(1)
		return

	# Test 4: Validate interview flow
	if not validate_interview_flow():
		quit(1)
		return

	print("✅ All validation tests passed!")
	quit(0)

func validate_interview_manager() -> bool:
	print("🔍 Testing InterviewManager autoload...")

	# Check if InterviewManager exists
	if not has_singleton("InterviewManager"):
		print("❌ InterviewManager autoload not found")
		return false

	var manager = get_singleton("InterviewManager")
	if not manager:
		print("❌ Could not get InterviewManager singleton")
		return false

	# Check required properties
	if not manager.has_method("load_interview_data"):
		print("❌ InterviewManager missing load_interview_data method")
		return false

	if not manager.has_method("start_interview"):
		print("❌ InterviewManager missing start_interview method")
		return false

	if not manager.has_method("submit_answer"):
		print("❌ InterviewManager missing submit_answer method")
		return false

	print("✅ InterviewManager validation passed")
	return true

func validate_json_loading() -> bool:
	print("🔍 Testing JSON data loading...")

	var manager = get_singleton("InterviewManager")
	var json_path = "res://interviews.json"

	# Test loading valid JSON
	var loaded = manager.load_interview_data(json_path)
	if not loaded:
		print("❌ Failed to load interview JSON data")
		return false

	# Check that questions were loaded
	if manager.interview_data.questions.is_empty():
		print("❌ No questions loaded from JSON")
		return false

	# Check fallback questions exist
	if manager.interview_data.fallback_questions.is_empty():
		print("❌ No fallback questions loaded")
		return false

	print("✅ JSON loading validation passed")
	return true

func validate_data_models() -> bool:
	print("🔍 Testing data model classes...")

	# Test GameEffects
	var effects = GameEffects.new({"strength": 2}, {"brave": true}, ["sword_mastery"])
	if not effects.is_valid():
		print("❌ GameEffects validation failed")
		return false

	if not effects.has_effects():
		print("❌ GameEffects.has_effects() failed")
		return false

	# Test AnswerChoice
	var answer = AnswerChoice.new("Test answer", effects, "next_question")
	if not answer.is_valid():
		print("❌ AnswerChoice validation failed")
		return false

	if not answer.has_next_question():
		print("❌ AnswerChoice.has_next_question() failed")
		return false

	# Test InterviewQuestion
	var question = InterviewQuestion.new("test_id", "Test question?", ["warrior"], [answer])
	if not question.is_valid():
		print("❌ InterviewQuestion validation failed")
		return false

	if not question.matches_tags(["warrior"]):
		print("❌ InterviewQuestion.matches_tags() failed")
		return false

	# Test InterviewSession
	var session = InterviewSession.new(["warrior"], 5)
	if not session.is_valid():
		print("❌ InterviewSession validation failed")
		return false

	if session.is_complete():
		print("❌ InterviewSession should not be complete initially")
		return false

	print("✅ Data model validation passed")
	return true

func validate_interview_flow() -> bool:
	print("🔍 Testing interview flow...")

	var manager = get_singleton("InterviewManager")

	# Start interview with test tags
	var first_question_id = manager.start_interview(["warrior"])
	if first_question_id.is_empty():
		print("❌ Failed to start interview")
		return false

	if not manager.is_interview_active:
		print("❌ Interview should be active after starting")
		return false

	# Get current question
	var question_data = manager.get_current_question()
	if question_data.is_empty():
		print("❌ Could not get current question data")
		return false

	# Verify question structure
	if not question_data.has("text"):
		print("❌ Question data missing text field")
		return false

	if not question_data.has("answers"):
		print("❌ Question data missing answers field")
		return false

	var answers = question_data.answers
	if answers.size() < 2:
		print("❌ Question should have at least 2 answers")
		return false

	# Submit answer
	var result = manager.submit_answer(0)
	if result.is_empty():
		print("❌ Failed to submit answer")
		return false

	# Check session progress
	var progress = manager.get_session_progress()
	if progress.get("questions_answered", 0) != 1:
		print("❌ Progress should show 1 question answered")
		return false

	print("✅ Interview flow validation passed")
	return true

func has_singleton(name: String) -> bool:
	# Check if singleton exists in autoload list
	return Engine.has_singleton(name)

func get_singleton(name: String) -> Node:
	# Get singleton instance
	return Engine.get_singleton(name)