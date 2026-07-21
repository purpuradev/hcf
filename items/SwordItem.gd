class_name SwordItem
extends HCFItemResource

## HCF Diamond Sword Item: Rapid melee attacks with zero cooldown

@export var attack_damage: float = 15.0

func _init() -> void:
	item_id = "diamond_sword"
	item_name = "Diamond Sword"
	cooldown = 0.0
	stack_size = 1
	icon_texture = HCFItemResource.load_item_texture("res://assets/sprites/diamond_sword.png")

func on_active_use(user: Node2D, _target_pos: Vector2) -> bool:
	if not user or user is not Player:
		return false
	
	var player = user as Player
	var world = player.get_tree().current_scene
	if world:
		var dummy = world.find_child("DummyTarget", true, false) as Node2D
		if dummy:
			var dist = player.global_position.distance_to(dummy.global_position)
			if dist <= 140.0:
				player.attack_target(dummy)
				return true
	
	var bus = user.get_node_or_null("/root/EventBus")
	if bus:
		bus.camera_shake_requested.emit(1.0, 0.05)
	return true
