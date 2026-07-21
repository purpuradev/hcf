class_name BardSugarItem
extends HCFItemResource

## HCF Bard Sugar: Passive Speed II on hold | Active Speed III on Right-Click

@export var passive_speed_multiplier: float = 1.2
@export var active_speed_multiplier: float = 1.6
@export var active_duration: float = 5.0

func _init() -> void:
	item_id = "bard_sugar"
	item_name = "Bard Sugar"
	cooldown = 10.0
	stack_size = 64
	icon_texture = HCFItemResource.load_item_texture("res://assets/sprites/bard_sugar.png")

func on_hold_tick(user: Node2D, _delta: float) -> void:
	if not user or user is not Player:
		return
	
	var player = user as Player
	if player.class_system and player.class_system.current_class and player.class_system.current_class.class_id == "bard":
		if player.movement_component:
			player.movement_component.apply_speed_modifier("bard_sugar_passive", passive_speed_multiplier, 0.2)

func on_active_use(user: Node2D, _target_pos: Vector2) -> bool:
	if not user or user is not Player:
		return false
	
	var player = user as Player
	if not player.class_system or not player.class_system.current_class or player.class_system.current_class.class_id != "bard":
		return false
	
	if player.movement_component:
		player.movement_component.apply_speed_modifier("bard_sugar_active", active_speed_multiplier, active_duration)
		
		var bus = user.get_node_or_null("/root/EventBus")
		if bus:
			bus.camera_shake_requested.emit(3.0, 0.1)
		return true
	
	return false
