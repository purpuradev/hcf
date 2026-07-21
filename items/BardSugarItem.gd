class_name BardSugarItem
extends HCFItemResource

## HCF Bard Item: Sugar (Speed II Hold / Speed III Active Burst)

func _init() -> void:
	item_id = "bard_sugar"
	item_name = "Sugar (Speed)"
	cooldown = 15.0
	stack_size = 64

func on_hold_tick(holder: Node2D, _delta: float) -> void:
	# Passive Hold Effect: Bard Speed II
	if holder and holder.has_node("BardAuraComponent"):
		var bard_aura = holder.get_node("BardAuraComponent") as BardAuraComponent
		if bard_aura and bard_aura.is_active:
			bard_aura.current_aura = "Speed II (Pasiva)"

func on_active_use(user: Node2D, _target_pos: Vector2) -> bool:
	if not user or not user.has_node("MovementComponent"):
		return false
	
	var movement = user.get_node("MovementComponent") as MovementComponent
	if movement:
		# Speed III active burst (temporary knockback impulse / boost)
		var dir = movement.move_direction
		if dir == Vector2.ZERO:
			dir = Vector2.RIGHT
		movement.apply_knockback(dir.normalized() * 350.0)
		
		var bus = user.get_node_or_null("/root/EventBus")
		if bus:
			bus.camera_shake_requested.emit(3.0, 0.15)
		return true
	return false
