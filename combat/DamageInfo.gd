class_name DamageInfo
extends RefCounted

## Data container representing a damage payload in combat

var amount: float = 0.0
var damage_type: GameEnums.DamageType = GameEnums.DamageType.PHYSICAL
var attacker: Node2D = null
var knockback_force: Vector2 = Vector2.ZERO
var is_critical: bool = false

func _init(p_amount: float = 0.0, p_attacker: Node2D = null, p_damage_type: GameEnums.DamageType = GameEnums.DamageType.PHYSICAL, p_knockback: Vector2 = Vector2.ZERO) -> void:
	amount = p_amount
	attacker = p_attacker
	damage_type = p_damage_type
	knockback_force = p_knockback
