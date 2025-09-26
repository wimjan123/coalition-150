# Strategy Resource
# Represents a campaign strategy

class_name Strategy
extends Resource

@export var strategy_id: String
@export var name: String
@export var description: String
@export var cost_multiplier: float = 1.0  # Affects action costs
@export var effectiveness: float = 1.0    # Affects action results

func _init(id: String = "", strategy_name: String = "", desc: String = "", cost_mult: float = 1.0, eff: float = 1.0):
	strategy_id = id
	name = strategy_name
	description = desc
	cost_multiplier = cost_mult
	effectiveness = eff