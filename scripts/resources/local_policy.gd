# LocalPolicy Resource
# Represents a local policy position

class_name LocalPolicy
extends Resource

@export var policy_id: String
@export var name: String
@export var description: String
@export var support_impact: float = 0.0  # Impact on regional support

func _init(id: String = "", policy_name: String = "", desc: String = "", impact: float = 0.0):
	policy_id = id
	name = policy_name
	description = desc
	support_impact = impact