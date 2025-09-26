# Character and Interaction Resources
# Handles character relationships and interactions

class_name Character
extends Resource

@export var character_id: String
@export var name: String
@export var portrait: Texture2D
@export var title: String             # Political position
@export var political_party: String   # Party affiliation
@export var trust_level: float = 50.0 # 0-100 trust with player
@export var political_alignment: GameEnums.PoliticalAlignment
@export var recent_interactions: Array[Interaction] = []

func get_character_name() -> String:
	return name

func set_character_name(value: String) -> void:
	name = value

func is_valid() -> bool:
	"""Validate character values"""
	if trust_level < 0.0 or trust_level > 100.0:
		return false

	if name.is_empty() or character_id.is_empty():
		return false

	return true

func update_trust(change: float) -> void:
	"""Update trust level with bounds checking"""
	trust_level = clampf(trust_level + change, 0.0, 100.0)

func add_interaction(interaction: Interaction) -> void:
	"""Add a new interaction"""
	if interaction:
		recent_interactions.append(interaction)

		# Keep only last 10 interactions
		if recent_interactions.size() > 10:
			recent_interactions.remove_at(0)

func get_trust_description() -> String:
	"""Get descriptive trust level"""
	if trust_level >= 80.0:
		return "High Trust"
	elif trust_level >= 60.0:
		return "Good Trust"
	elif trust_level >= 40.0:
		return "Moderate Trust"
	elif trust_level >= 20.0:
		return "Low Trust"
	else:
		return "Very Low Trust"

func get_alignment_description() -> String:
	"""Get descriptive political alignment"""
	match political_alignment:
		GameEnums.PoliticalAlignment.FAR_LEFT: return "Far Left"
		GameEnums.PoliticalAlignment.LEFT: return "Left"
		GameEnums.PoliticalAlignment.CENTER: return "Center"
		GameEnums.PoliticalAlignment.RIGHT: return "Right"
		GameEnums.PoliticalAlignment.FAR_RIGHT: return "Far Right"
		_: return "Unknown"

func is_ally() -> bool:
	"""Check if character is considered an ally (high trust)"""
	return trust_level >= 70.0

func is_opponent() -> bool:
	"""Check if character is considered an opponent (low trust)"""
	return trust_level <= 30.0

func get_recent_interaction_count() -> int:
	"""Get number of recent interactions"""
	return recent_interactions.size()


# Interaction class - inner class for Character interactions
class Interaction:
	extends Resource

@export var interaction_date: GameDate
@export var interaction_type: String
@export var trust_impact: float  # Change in trust level
@export var description: String

func _init(date: GameDate = null, type: String = "", impact: float = 0.0, desc: String = ""):
	interaction_date = date if date else GameDate.new()
	interaction_type = type
	trust_impact = impact
	description = desc

func get_impact_description() -> String:
	"""Get descriptive impact"""
	if trust_impact > 5.0:
		return "Very Positive"
	elif trust_impact > 0.0:
		return "Positive"
	elif trust_impact < -5.0:
		return "Very Negative"
	elif trust_impact < 0.0:
		return "Negative"
	else:
		return "Neutral"