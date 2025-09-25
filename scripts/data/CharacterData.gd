# CharacterData - Political character data for campaign
# Stores character's political profile and interview responses

class_name CharacterData
extends Resource

# Character's display name
@export var character_name: String = ""

# Political background/experience
@export var political_experience: String = ""

# Policy positions as key-value pairs (area -> stance)
@export var policy_positions: Dictionary = {}

# Character's personal backstory
@export var backstory: String = ""

# Associated political party
@export var party: PartyData = null

# Responses to media interview questions
@export var interview_responses: Array[InterviewResponse] = []

# Character creation timestamp
@export var created_at: String = ""

func _init(p_name: String = "", p_experience: String = "", p_backstory: String = "") -> void:
	character_name = p_name
	political_experience = p_experience
	backstory = p_backstory
	created_at = Time.get_datetime_string_from_system()

# Set a policy position for a specific area
func set_policy_position(policy_area: String, stance: String) -> void:
	if policy_area.is_empty():
		push_error("Policy area cannot be empty")
		return

	policy_positions[policy_area] = stance
	emit_changed()

# Get a policy position for a specific area
func get_policy_position(policy_area: String) -> String:
	return policy_positions.get(policy_area, "")

# Get all policy areas this character has positions on
func get_policy_areas() -> Array:
	return policy_positions.keys()

# Add an interview response
func add_interview_response(response: InterviewResponse) -> void:
	if not response:
		push_error("Cannot add null interview response")
		return

	interview_responses.append(response)
	emit_changed()

# Get interview response by question ID
func get_interview_response(question_id: String) -> InterviewResponse:
	for response in interview_responses:
		if response.question_id == question_id:
			return response
	return null

# Check if character has completed interview
func has_completed_interview() -> bool:
	return interview_responses.size() >= 5  # Expect 5 questions per spec

# Get interview completion percentage (0.0 to 1.0)
func get_interview_completion() -> float:
	var expected_questions: int = 5
	var completed: int = interview_responses.size()
	return min(completed / float(expected_questions), 1.0)

# Clear all interview responses (for retaking interview)
func clear_interview_responses() -> void:
	interview_responses.clear()
	emit_changed()

# Validate character data
func validate() -> bool:
	# Check required fields
	if character_name.is_empty():
		push_error("Character name is required")
		return false

	if political_experience.is_empty():
		push_error("Political experience is required")
		return false

	if backstory.is_empty():
		push_error("Backstory is required")
		return false

	# Validate party if present
	if party and not party.validate():
		return false

	# Validate interview responses
	for response in interview_responses:
		if not response.validate():
			return false

	return true

# Get character summary for UI display
func get_display_summary() -> String:
	var summary: String = character_name
	if party:
		summary += " (" + party.party_name + ")"
	summary += " - " + political_experience
	return summary

# Check if character has specific policy position
func has_policy_position(policy_area: String) -> bool:
	return policy_area in policy_positions

# Get character's political profile for question generation
func get_political_profile() -> Dictionary:
	return {
		"name": character_name,
		"experience": political_experience,
		"policies": policy_positions,
		"backstory": backstory,
		"party_name": party.party_name if party else "",
		"interview_complete": has_completed_interview()
	}