class_name ClassResource
extends Resource

## Resource defining an HCF Class (Rogue, Bard, Miner, Archer, Diamond)

@export var class_id: String = "rogue"
@export var display_name: String = "Rogue"
@export var speed_multiplier: float = 1.0
@export var damage_multiplier: float = 1.0
@export var defense_multiplier: float = 1.0

@export var primary_ability: AbilityResource
@export var secondary_ability: AbilityResource
