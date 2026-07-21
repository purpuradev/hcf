class_name BackstabComponent
extends Node

## Calculates Rogue Backstab mechanics when attacking enemies from behind

signal backstab_dealt(target: Node2D, damage_info: DamageInfo)

@export var backstab_multiplier: float = 2.5

func is_behind_target(attacker: Node2D, target: Node2D) -> bool:
	if not attacker or not target:
		return false
	
	# Determine target facing direction (Vector2.RIGHT by default unless flipped)
	var target_facing = Vector2.RIGHT
	if target.has_node("Sprite2D"):
		var sprite = target.get_node("Sprite2D") as Sprite2D
		if sprite and sprite.flip_h:
			target_facing = Vector2.LEFT
	
	# Direction vector from target towards attacker
	var dir_to_attacker = (attacker.global_position - target.global_position).normalized()
	
	# Dot product < 0 means attacker is behind target's back!
	var dot = target_facing.dot(dir_to_attacker)
	return dot < -0.1

func process_backstab(attacker: Node2D, target: Node2D, damage_info: DamageInfo) -> void:
	damage_info.amount *= backstab_multiplier
	damage_info.is_critical = true
	backstab_dealt.emit(target, damage_info)
	
	var bus = get_node_or_null("/root/EventBus")
	if bus:
		bus.camera_shake_requested.emit(6.0, 0.25)
