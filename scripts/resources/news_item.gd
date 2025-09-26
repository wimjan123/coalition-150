# NewsItem and ResponseOption Resources
# Handles news events and player responses

class_name NewsItem
extends Resource

@export var news_id: String
@export var headline: String
@export var content: String
@export var publication_date: GameDate
@export var urgency_level: GameEnums.UrgencyLevel = GameEnums.UrgencyLevel.NORMAL
@export var response_options: Array[ResponseOption] = []
@export var player_response: GameEnums.ResponseType = GameEnums.ResponseType.NO_RESPONSE
@export var consequences_applied: bool = false

func get_headline() -> String:
	return headline

func set_headline(value: String) -> void:
	headline = value

func is_valid() -> bool:
	"""Validate news item"""
	if headline.is_empty():
		return false

	if news_id.is_empty():
		return false

	return true

func is_urgent() -> bool:
	"""Check if news item requires urgent attention"""
	return urgency_level == GameEnums.UrgencyLevel.CRITICAL

func add_response_option(option: ResponseOption) -> void:
	"""Add a response option"""
	if option:
		response_options.append(option)

func get_response_option(response_type: GameEnums.ResponseType) -> ResponseOption:
	"""Get response option by type"""
	for option in response_options:
		if option is ResponseOption and option.response_type == response_type:
			return option
	return null

func respond(response_type: GameEnums.ResponseType) -> bool:
	"""Set player response"""
	if player_response != GameEnums.ResponseType.NO_RESPONSE:
		return false  # Already responded

	var option = get_response_option(response_type)
	if not option:
		return false  # Invalid response type

	player_response = response_type
	return true

func get_urgency_description() -> String:
	"""Get descriptive urgency level"""
	match urgency_level:
		GameEnums.UrgencyLevel.LOW: return "Low Priority"
		GameEnums.UrgencyLevel.NORMAL: return "Normal"
		GameEnums.UrgencyLevel.HIGH: return "High Priority"
		GameEnums.UrgencyLevel.CRITICAL: return "Critical"
		_: return "Unknown"

func get_response_description() -> String:
	"""Get descriptive response type"""
	match player_response:
		GameEnums.ResponseType.NO_RESPONSE: return "No Response"
		GameEnums.ResponseType.PUBLIC_STATEMENT: return "Public Statement"
		GameEnums.ResponseType.PRIVATE_ACTION: return "Private Action"
		GameEnums.ResponseType.COALITION_CONSULTATION: return "Coalition Consultation"
		GameEnums.ResponseType.EMERGENCY_LEGISLATION: return "Emergency Legislation"
		GameEnums.ResponseType.MEDIA_CAMPAIGN: return "Media Campaign"
		_: return "Unknown"


class_name ResponseOption
extends Resource

@export var response_type: GameEnums.ResponseType
@export var description: String
@export var cost: int = 0
@export var expected_outcomes: Array[Consequence] = []

func add_outcome(consequence: Consequence) -> void:
	"""Add an expected outcome"""
	if consequence:
		expected_outcomes.append(consequence)