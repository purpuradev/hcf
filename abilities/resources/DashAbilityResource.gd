class_name DashAbilityResource
extends AbilityResource

## Example HCF Rogue Dash / Speed Burst Ability

@export var dash_force: float = 220.0

func _init() -> void:
	id = "rogue_dash"
	name = "Rogue Dash"
	description = "Grants a quick burst of movement forward."
	cooldown = 3.0
	stamina_cost = 15.0

func execute(caster: Node2D) -> bool:
	if not caster or not (caster is Player):
		return false
	
	var player = caster as Player
	var movement = player.movement_component
	if not movement:
		return false
	
	var dash_direction = movement.move_direction
	if dash_direction == Vector2.ZERO:
		dash_direction = Vector2.LEFT if player.sprite.flip_h else Vector2.RIGHT
	
	movement.apply_knockback(dash_direction.normalized() * dash_force)
	
	var bus = caster.get_node_or_null("/root/EventBus")
	if bus:
		bus.camera_shake_requested.emit(4.0, 0.15)
	return true
