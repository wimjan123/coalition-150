# Consequence Resource
# Represents the impact of decisions and events

class_name Consequence
extends Resource

@export var description: String
@export var impact_type: GameEnums.ImpactType
@export var magnitude: float      # -100 to +100
@export var affected_stat: GameEnums.StatType

func _init(desc: String = "", type: GameEnums.ImpactType = GameEnums.ImpactType.APPROVAL_RATING, mag: float = 0.0, stat: GameEnums.StatType = GameEnums.StatType.APPROVAL_RATING):
	description = desc
	impact_type = type
	magnitude = mag
	affected_stat = stat

func is_positive() -> bool:
	"""Check if consequence is positive"""
	return magnitude > 0.0

func is_negative() -> bool:
	"""Check if consequence is negative"""
	return magnitude < 0.0

func get_magnitude_description() -> String:
	"""Get descriptive magnitude"""
	var abs_mag = abs(magnitude)
	var prefix = "Increase" if magnitude > 0 else "Decrease"

	if abs_mag >= 50.0:
		return "%s (Major)" % prefix
	elif abs_mag >= 20.0:
		return "%s (Moderate)" % prefix
	elif abs_mag >= 5.0:
		return "%s (Minor)" % prefix
	else:
		return "%s (Minimal)" % prefix