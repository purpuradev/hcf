class_name EnderPearlItem
extends HCFItemResource

## HCF Ender Pearl: Teleports player to cursor position with 15s cooldown and 10 HP fall damage

@export var fall_damage: float = 10.0

func _init() -> void:
	item_id = "ender_pearl"
	item_name = "Ender Pearl"
	cooldown = 15.0
	stack_size = 16
	icon_texture = HCFItemResource.load_item_texture("res://assets/sprites/ender_pearl.png")

func on_active_use(user: Node2D, target_pos: Vector2) -> bool:
	if not user or user is not Player:
		return false
	
	var player = user as Player
	player.global_position = target_pos
	
	if player.health_component:
		var damage_info = DamageInfo.new(fall_damage, null, GameEnums.DamageType.FALL)
		player.health_component.take_damage(damage_info)
	
	var bus = user.get_node_or_null("/root/EventBus")
	if bus:
		bus.camera_shake_requested.emit(4.0, 0.15)
	
	return true
