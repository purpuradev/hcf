class_name EnderPearlItem
extends HCFItemResource

## HCF Ender Pearl: Teleports player to cursor position with fall damage and 15s cooldown

func _init() -> void:
	item_id = "ender_pearl"
	item_name = "Ender Pearl"
	cooldown = 15.0
	stack_size = 16

func on_active_use(user: Node2D, target_pos: Vector2) -> bool:
	if not user:
		return false
	
	# Teleport user to target mouse cursor position
	user.global_position = target_pos
	
	# Apply 10 HP pearl fall damage
	if user.has_node("HealthComponent"):
		var health = user.get_node("HealthComponent") as HealthComponent
		if health:
			var pearl_damage = DamageInfo.new(10.0, user, GameEnums.DamageType.ENVIRONMENTAL)
			health.take_damage(pearl_damage)
	
	var bus = user.get_node_or_null("/root/EventBus")
	if bus:
		bus.camera_shake_requested.emit(5.0, 0.2)
	return true
