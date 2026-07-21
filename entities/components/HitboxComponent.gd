class_name HitboxComponent
extends Area2D

## Area2D specialized in delivering damage to HurtboxComponent targets

signal hit_delivered(target: HurtboxComponent, damage_info: DamageInfo)

@export var damage_amount: float = 10.0
@export var damage_type: GameEnums.DamageType = GameEnums.DamageType.PHYSICAL
@export var base_knockback: float = 100.0

func _ready() -> void:
	collision_layer = 0   # Doesn't get scanned
	collision_mask = 2    # Scans Hurtbox layer by default
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is HurtboxComponent:
		var knockback_dir = (area.global_position - global_position).normalized()
		var damage_info = DamageInfo.new(
			damage_amount,
			owner as Node2D,
			damage_type,
			knockback_dir * base_knockback
		)
		area.receive_hit(damage_info)
		hit_delivered.emit(area, damage_info)
