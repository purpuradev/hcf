class_name GoldenAppleItem
extends HCFItemResource

## HCF Golden Apple: Restores HP, Hunger, and applies regeneration (No Cooldown)

func _init() -> void:
	item_id = "golden_apple"
	item_name = "Golden Apple"
	cooldown = 0.0 # No cooldown for instant eating
	stack_size = 64

func on_active_use(user: Node2D, _target_pos: Vector2) -> bool:
	if not user:
		return false
	
	var success = false
	
	if user.has_node("HealthComponent"):
		var health = user.get_node("HealthComponent") as HealthComponent
		if health:
			health.heal(30.0)
			success = true
	
	if user.has_node("HungerComponent"):
		var hunger = user.get_node("HungerComponent") as HungerComponent
		if hunger:
			hunger.eat_food(40.0)
			success = true
	
	if success:
		var bus = user.get_node_or_null("/root/EventBus")
		if bus:
			bus.camera_shake_requested.emit(1.5, 0.1)
		return true
	
	return false
