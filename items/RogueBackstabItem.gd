class_name RogueBackstabItem
extends HCFItemResource

## HCF Rogue Backstab Dagger: Deals 2.5x Backstab damage from behind and triggers 10s cooldown

func _init() -> void:
	item_id = "rogue_backstab"
	item_name = "Rogue Dagger"
	cooldown = 10.0
	stack_size = 1
	icon_texture = HCFItemResource.load_item_texture("rogue_backstab")

func on_active_use(user: Node2D, _target_pos: Vector2) -> bool:
	if not user or user is not Player:
		return false
	
	var player = user as Player
	var world = player.get_tree().current_scene
	if not world:
		return false
	
	var dummy = world.find_child("DummyTarget", true, false) as Node2D
	if not dummy or not is_instance_valid(dummy):
		return false
	
	var dist = player.global_position.distance_to(dummy.global_position)
	if dist > 140.0:
		return false
	
	var damage_info = DamageInfo.new(15.0, player, GameEnums.DamageType.PHYSICAL)
	var is_backstab = false
	
	if player.backstab_component:
		if player.backstab_component.is_behind_target(player, dummy):
			player.backstab_component.process_backstab(player, dummy, damage_info)
			is_backstab = true
	
	if dummy.has_node("HurtboxComponent"):
		var hurtbox = dummy.get_node("HurtboxComponent") as HurtboxComponent
		hurtbox.receive_hit(damage_info)
		return is_backstab
	
	return false
