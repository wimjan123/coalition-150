# MediaInterview - Scene for conducting media interviews with the character
# Implements MediaInterviewInterface for TDD compliance

extends Control

# UI References
@onready var progress_label: Label = $MainContainer/Header/ProgressContainer/ProgressLabel
@onready var progress_bar: ProgressBar = $MainContainer/Header/ProgressContainer/ProgressBar
@onready var question_label: Label = $MainContainer/ContentContainer/QuestionSection/QuestionLabel
@onready var answer_buttons: Array[Button] = []
@onready var question_section: VBoxContainer = $MainContainer/ContentContainer/QuestionSection
@onready var summary_section: VBoxContainer = $MainContainer/ContentContainer/SummarySection
@onready var back_button: Button = $MainContainer/NavigationContainer/BackButton
@onready var next_button: Button = $MainContainer/NavigationContainer/NextButton
@onready var finish_button: Button = $MainContainer/NavigationContainer/FinishButton
@onready var responses_container: VBoxContainer = $MainContainer/ContentContainer/SummarySection/ResponsesList/ScrollContainer/ResponsesContainer

# Interview Data
var current_character: CharacterData = null
var questions: Array[Dictionary] = []
var current_question_index: int = 0
var interview_responses: Array[InterviewResponse] = []
var selected_answer_index: int = -1
var question_generator: InterviewQuestionGenerator = null

# Signals for interview flow and navigation
signal interview_started(character: CharacterData)
signal question_answered(question_index: int, answer_text: String)
signal interview_completed(responses: Array[InterviewResponse])
signal proceed_to_main_game_requested()
signal return_to_creation_requested()

func _ready() -> void:
	question_generator = InterviewQuestionGenerator.new()
	_setup_ui()
	_connect_signals()
	_initialize_interview()

func _setup_ui() -> void:
	# Get answer buttons
	var answer_container: VBoxContainer = $MainContainer/ContentContainer/QuestionSection/AnswerContainer
	for child in answer_container.get_children():
		if child is Button:
			answer_buttons.append(child)

	# Apply theme
	if theme == null:
		theme = preload("res://assets/themes/player_creation_theme.tres")

func _connect_signals() -> void:
	# Answer button signals
	for i in range(answer_buttons.size()):
		answer_buttons[i].pressed.connect(_on_answer_selected.bind(i))

	# Navigation signals
	back_button.pressed.connect(_on_back_pressed)
	next_button.pressed.connect(_on_next_pressed)
	finish_button.pressed.connect(_on_finish_pressed)

func _initialize_interview() -> void:
	# Get current character from SceneManager
	current_character = SceneManager.get_current_character()

	if current_character:
		start_interview(current_character)
	else:
		push_error("No character data available for interview")

# MediaInterviewInterface Implementation

func start_interview(character: CharacterData) -> void:
	current_character = character
	questions = generate_questions_for_character(character)
	current_question_index = 0
	interview_responses.clear()

	# Create empty responses for all questions
	for question in questions:
		var response: InterviewResponse = InterviewResponse.new()
		response.set_question_info(question.question_id, question.text, question.get("category", ""))
		interview_responses.append(response)

	display_question(0)
	interview_started.emit(character)
	print("Interview started for character: ", character.character_name)

func generate_questions_for_character(character: CharacterData) -> Array[Dictionary]:
	if not character:
		push_error("Cannot generate questions for null character")
		return []

	if not question_generator:
		question_generator = InterviewQuestionGenerator.new()

	# Configure question generation based on interview context
	var settings: Dictionary = {
		"difficulty": "mixed",
		"bias": "balanced",
		"count": 5,
		"followup": true
	}

	# Use advanced question generator
	var generated_questions: Array[Dictionary] = question_generator.generate_interview_questions(character, settings)

	# Fallback to basic questions if generator fails
	if generated_questions.is_empty():
		push_warning("Question generator failed, using fallback questions")
		generated_questions = _generate_fallback_questions(character)

	return generated_questions

func display_question(question_index: int) -> void:
	if question_index < 0 or question_index >= questions.size():
		push_error("Invalid question index: " + str(question_index))
		return

	current_question_index = question_index
	var question: Dictionary = questions[question_index]

	# Update UI with enhanced question information
	question_label.text = question.text
	progress_label.text = "Question " + str(question_index + 1) + " of " + str(questions.size())

	# Show question difficulty and category if available
	if question.has("category") and question.has("difficulty"):
		progress_label.text += " (" + question.category.capitalize() + " - " + question.difficulty.capitalize() + ")"

	progress_bar.max_value = questions.size()
	progress_bar.value = question_index + 1

	# Update answer buttons with enhanced styling
	var answers: Array = question.answers
	for i in range(answer_buttons.size()):
		if i < answers.size():
			answer_buttons[i].text = answers[i]
			answer_buttons[i].visible = true
			answer_buttons[i].button_pressed = false

			# Add tooltip for answer context if available
			if question.has("context"):
				answer_buttons[i].tooltip_text = "Answer option " + str(i + 1)

		else:
			answer_buttons[i].visible = false

	# Update navigation buttons
	back_button.disabled = (question_index == 0)
	next_button.disabled = true  # Enable after answer selection
	selected_answer_index = -1

	# Check if this question was already answered
	if question_index < interview_responses.size():
		var response: InterviewResponse = interview_responses[question_index]
		if response.is_answered():
			selected_answer_index = response.answer_index
			if selected_answer_index >= 0 and selected_answer_index < answer_buttons.size():
				answer_buttons[selected_answer_index].button_pressed = true
				next_button.disabled = false

func get_current_question() -> Dictionary:
	if current_question_index >= 0 and current_question_index < questions.size():
		return questions[current_question_index]
	return {}

func get_total_questions() -> int:
	return questions.size()

func get_current_question_index() -> int:
	return current_question_index

func submit_answer(answer_index: int) -> void:
	if answer_index < 0 or answer_index >= answer_buttons.size():
		push_error("Invalid answer index: " + str(answer_index))
		return

	var question: Dictionary = get_current_question()
	var answer_text: String = question.answers[answer_index]

	# Update response
	if current_question_index < interview_responses.size():
		var response: InterviewResponse = interview_responses[current_question_index]
		response.set_response(answer_text, answer_index)

	selected_answer_index = answer_index
	next_button.disabled = false

	question_answered.emit(current_question_index, answer_text)
	print("Answer submitted for question ", current_question_index, ": ", answer_text)

func get_selected_answer() -> String:
	if selected_answer_index >= 0 and selected_answer_index < answer_buttons.size():
		return answer_buttons[selected_answer_index].text
	return ""

func can_change_answer() -> bool:
	return true  # Allow changing answers during interview

func proceed_to_next_question() -> void:
	if current_question_index < questions.size() - 1:
		display_question(current_question_index + 1)
	else:
		finish_interview()

func go_back_to_previous_question() -> void:
	if current_question_index > 0:
		display_question(current_question_index - 1)

func finish_interview() -> void:
	# Validate all questions are answered
	if not validate_all_questions_answered():
		push_warning("Interview not complete - some questions unanswered")
		return

	# Show summary section
	question_section.visible = false
	summary_section.visible = true
	back_button.visible = false
	next_button.visible = false
	finish_button.visible = true

	# Populate summary
	_populate_summary()

	# Compile and analyze interview data
	_analyze_interview_performance()

	# Save responses to character
	save_responses_to_character(current_character)

	interview_completed.emit(compile_interview_responses())
	print("Interview completed for character: ", current_character.character_name)

func show_question_ui() -> void:
	question_section.visible = true
	summary_section.visible = false

func show_summary_ui() -> void:
	question_section.visible = false
	summary_section.visible = true

func update_progress_display() -> void:
	progress_label.text = "Question " + str(current_question_index + 1) + " of " + str(questions.size())
	progress_bar.value = current_question_index + 1

func compile_interview_responses() -> Array[InterviewResponse]:
	return interview_responses

func save_responses_to_character(character: CharacterData) -> void:
	if not character:
		push_error("Cannot save responses to null character")
		return

	character.interview_responses = interview_responses.duplicate()
	print("Responses saved to character: ", character.character_name)

func validate_all_questions_answered() -> bool:
	for response in interview_responses:
		if not response.is_answered():
			return false
	return true

func is_interview_complete() -> bool:
	return validate_all_questions_answered()

func get_experience_questions() -> Array[Dictionary]:
	return [_generate_experience_question("Generic experience")]

func get_policy_questions(policies: Dictionary) -> Array[Dictionary]:
	return [_generate_policy_question(policies)]

func get_backstory_questions(backstory: String) -> Array[Dictionary]:
	return [_generate_backstory_question(backstory)]

func get_interview_progress() -> float:
	if questions.size() == 0:
		return 0.0
	return float(current_question_index + 1) / float(questions.size())

func get_answers_summary() -> Array[String]:
	var summary: Array[String] = []
	for response in interview_responses:
		if response.is_answered():
			summary.append(response.selected_answer)
		else:
			summary.append("Not answered")
	return summary

# Fallback and Helper Functions

func _generate_fallback_questions(character: CharacterData) -> Array[Dictionary]:
	var profile: Dictionary = character.get_political_profile()
	var fallback_questions: Array[Dictionary] = []

	# Generate basic questions as fallback
	fallback_questions.append(_generate_experience_question(profile.get("experience", "community member")))
	fallback_questions.append(_generate_policy_question(profile.get("policies", {})))
	fallback_questions.append(_generate_backstory_question(profile.get("backstory", "community involvement")))
	fallback_questions.append(_generate_leadership_question(character.character_name))
	fallback_questions.append(_generate_vision_question(profile.get("party_name", "our party")))

	return fallback_questions

func _analyze_interview_performance() -> void:
	var performance_data: Dictionary = {}

	# Calculate response consistency
	var political_alignment: Dictionary = {}
	for response in interview_responses:
		var category: String = response.question_category
		if not political_alignment.has(category):
			political_alignment[category] = []
		political_alignment[category].append(response.selected_answer)

	# Store analysis in character data for game mechanics
	if current_character:
		performance_data["response_categories"] = political_alignment.keys()
		performance_data["total_questions"] = interview_responses.size()
		performance_data["completion_rate"] = get_interview_progress()
		current_character.set_interview_performance(performance_data)

	print("Interview performance analyzed: ", performance_data)

# Question Generation Helpers

func _generate_experience_question(experience: String) -> Dictionary:
	var base_questions: Array[String] = [
		"How has your experience as a %s prepared you for higher office?",
		"What specific skills from your role as %s will you bring to governance?",
		"Can you describe your biggest achievement as a %s?"
	]

	var question_text: String = base_questions[randi() % base_questions.size()] % [experience]

	return {
		"question_id": "exp_001",
		"text": question_text,
		"category": "experience",
		"answers": [
			"I've learned to work with diverse stakeholders and build consensus.",
			"My experience taught me the importance of fiscal responsibility.",
			"I've developed strong leadership skills through managing complex projects.",
			"I understand the challenges facing our community firsthand."
		]
	}

func _generate_policy_question(policies: Dictionary) -> Dictionary:
	var policy_areas: Array = ["healthcare", "education", "economy", "environment"]
	var chosen_area: String = policy_areas[randi() % policy_areas.size()]

	var question_text: String = "What is your position on %s policy?" % [chosen_area]

	return {
		"question_id": "pol_001",
		"text": question_text,
		"category": "policy",
		"answers": [
			"We need bold, progressive reforms to address current challenges.",
			"A balanced approach that considers all stakeholders is essential.",
			"Market-based solutions with targeted government intervention work best.",
			"Evidence-based policy making should guide our decisions."
		]
	}

func _generate_backstory_question(backstory: String) -> Dictionary:
	return {
		"question_id": "back_001",
		"text": "How has your personal background shaped your political views?",
		"category": "backstory",
		"answers": [
			"My experiences have shown me the importance of helping those in need.",
			"I believe in the value of hard work and personal responsibility.",
			"Community involvement has taught me the power of collective action.",
			"I've seen how good policy can make a real difference in people's lives."
		]
	}

func _generate_leadership_question(name: String) -> Dictionary:
	return {
		"question_id": "lead_001",
		"text": "What leadership style do you bring to politics?",
		"category": "leadership",
		"answers": [
			"I believe in collaborative leadership that brings people together.",
			"Strong, decisive leadership is what our community needs.",
			"I lead by example and always put principles first.",
			"Adaptive leadership that responds to changing circumstances is key."
		]
	}

func _generate_vision_question(party_name: String) -> Dictionary:
	return {
		"question_id": "vis_001",
		"text": "What is your vision for the future under " + party_name + " leadership?",
		"category": "vision",
		"answers": [
			"A more inclusive society where everyone has opportunity to succeed.",
			"Strong economic growth that benefits all members of our community.",
			"Sustainable development that protects our environment for future generations.",
			"Transparent, accountable government that serves the people's interests."
		]
	}

# Event Handlers

func _on_answer_selected(answer_index: int) -> void:
	# Deselect other buttons
	for button in answer_buttons:
		button.button_pressed = false

	# Select chosen button
	if answer_index < answer_buttons.size():
		answer_buttons[answer_index].button_pressed = true

	submit_answer(answer_index)

func _on_back_pressed() -> void:
	go_back_to_previous_question()

func _on_next_pressed() -> void:
	proceed_to_next_question()

func _on_finish_pressed() -> void:
	# Save character and proceed to main game
	var save_success: bool = SceneManager.save_system.quick_save_character(current_character)

	if save_success:
		proceed_to_main_game_requested.emit()
		SceneManager.change_scene_to_main_game()
	else:
		push_error("Failed to save character data")

func _populate_summary() -> void:
	# Clear existing responses
	for child in responses_container.get_children():
		child.queue_free()

	# Add response summaries
	for i in range(interview_responses.size()):
		if i < questions.size():
			var response: InterviewResponse = interview_responses[i]
			var question: Dictionary = questions[i]

			var response_label: Label = Label.new()
			response_label.text = "Q" + str(i + 1) + ": " + question.text + "\nA: " + response.selected_answer
			response_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			response_label.add_theme_stylebox_override("normal", StyleBoxFlat.new())

			responses_container.add_child(response_label)

# Input handling
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		return_to_creation_requested.emit()
		SceneManager.change_scene_to_player_creation()