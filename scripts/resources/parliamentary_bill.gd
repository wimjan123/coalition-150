# ParliamentaryBill Resource
# Represents a bill in the parliamentary system

class_name ParliamentaryBill
extends Resource

@export var bill_id: String
@export var title: String
@export var full_text: String
@export var summary: String
@export var party_position: GameEnums.BillPosition = GameEnums.BillPosition.NEUTRAL
@export var predicted_consequences: Array[Consequence] = []
@export var public_opinion: float = 50.0    # 0-100 support
@export var coalition_stance: GameEnums.BillPosition = GameEnums.BillPosition.NEUTRAL
@export var voting_deadline: GameDate
@export var vote_cast: GameEnums.BillVote = GameEnums.BillVote.NOT_VOTED
@export var vote_result: GameEnums.BillResult = GameEnums.BillResult.PENDING

func get_title() -> String:
	return title

func set_title(value: String) -> void:
	title = value

func can_vote(current_date: GameDate) -> bool:
	"""Check if voting is still allowed"""
	if not voting_deadline or not current_date:
		return false

	return current_date.compare(voting_deadline) <= 0

func is_urgent() -> bool:
	"""Check if bill requires urgent attention"""
	if not voting_deadline:
		return false

	# Simplified urgency check - could be enhanced with time comparison
	return vote_cast == GameEnums.BillVote.NOT_VOTED

func cast_vote(vote: GameEnums.BillVote) -> bool:
	"""Cast a vote on this bill"""
	if vote_cast != GameEnums.BillVote.NOT_VOTED:
		return false  # Already voted

	vote_cast = vote
	return true

func add_consequence(consequence: Consequence) -> void:
	"""Add a predicted consequence"""
	if consequence:
		predicted_consequences.append(consequence)

func get_position_description() -> String:
	"""Get descriptive party position"""
	match party_position:
		GameEnums.BillPosition.STRONGLY_OPPOSE: return "Strongly Oppose"
		GameEnums.BillPosition.OPPOSE: return "Oppose"
		GameEnums.BillPosition.NEUTRAL: return "Neutral"
		GameEnums.BillPosition.SUPPORT: return "Support"
		GameEnums.BillPosition.STRONGLY_SUPPORT: return "Strongly Support"
		_: return "Unknown"

func get_vote_description() -> String:
	"""Get descriptive vote cast"""
	match vote_cast:
		GameEnums.BillVote.NOT_VOTED: return "Not Voted"
		GameEnums.BillVote.YES: return "Yes"
		GameEnums.BillVote.NO: return "No"
		GameEnums.BillVote.ABSTAIN: return "Abstain"
		_: return "Unknown"

func get_public_opinion_description() -> String:
	"""Get descriptive public opinion"""
	if public_opinion >= 80.0:
		return "Strong Support"
	elif public_opinion >= 60.0:
		return "Support"
	elif public_opinion >= 40.0:
		return "Mixed"
	elif public_opinion >= 20.0:
		return "Opposition"
	else:
		return "Strong Opposition"