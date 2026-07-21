class_name AbilityResource
extends Resource

## Data Resource defining abilities for Hardcore Factions classes & items

@export var id: String = "ability_id"
@export var name: String = "Ability Name"
@export_multiline var description: String = "Ability description."
@export var icon: Texture2D
@export var cooldown: float = 5.0
@export var stamina_cost: float = 10.0

## Virtual method: Override this method in custom ability scripts to implement logic
func execute(caster: Node2D) -> bool:
	push_warning("AbilityResource: Base execute() called for %s. Override this in custom ability resources." % name)
	return true
