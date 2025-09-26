# Candidate Resource
# Represents a political candidate for regional campaigns

class_name Candidate
extends Resource

@export var name: String
@export var portrait: Texture2D
@export var political_alignment: GameEnums.PoliticalAlignment
@export var experience_level: int = 1  # 1-5 skill level
@export var specialties: Array[String] = []  # Policy areas
@export var popularity: float = 50.0   # Regional popularity

func is_valid() -> bool:
	"""Validate candidate values"""
	if experience_level < 1 or experience_level > 5:
		return false

	if popularity < 0.0 or popularity > 100.0:
		return false

	if name.is_empty():
		return false

	return true

func get_name() -> String:
	return name

func set_name(value: String) -> void:
	name = value

func add_specialty(specialty: String) -> void:
	"""Add a policy specialty"""
	if not specialty.is_empty() and not specialties.has(specialty):
		specialties.append(specialty)

func remove_specialty(specialty: String) -> bool:
	"""Remove a policy specialty"""
	var index = specialties.find(specialty)
	if index >= 0:
		specialties.remove_at(index)
		return true
	return false

func has_specialty(specialty: String) -> bool:
	"""Check if candidate has specific specialty"""
	return specialties.has(specialty)

func get_experience_description() -> String:
	"""Get descriptive experience level"""
	match experience_level:
		1: return "Novice"
		2: return "Beginner"
		3: return "Experienced"
		4: return "Expert"
		5: return "Master"
		_: return "Unknown"

func get_alignment_description() -> String:
	"""Get descriptive political alignment"""
	match political_alignment:
		GameEnums.PoliticalAlignment.FAR_LEFT: return "Far Left"
		GameEnums.PoliticalAlignment.LEFT: return "Left"
		GameEnums.PoliticalAlignment.CENTER: return "Center"
		GameEnums.PoliticalAlignment.RIGHT: return "Right"
		GameEnums.PoliticalAlignment.FAR_RIGHT: return "Far Right"
		_: return "Unknown"

func calculate_fit_score(province_data: RegionalData) -> float:
	"""Calculate how well this candidate fits the province (0-100)"""
	if not province_data:
		return 0.0

	var base_score := popularity * 0.6  # 60% based on popularity
	var experience_bonus := experience_level * 5.0  # Experience adds up to 25 points
	var specialty_bonus := 0.0

	# Bonus for relevant specialties (simplified)
	if specialties.size() > 0:
		specialty_bonus = min(specialties.size() * 3.0, 15.0)  # Up to 15 points

	return clampf(base_score + experience_bonus + specialty_bonus, 0.0, 100.0)