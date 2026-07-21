class_name HurtboxComponent
extends Area2D

## Area2D specialized in receiving damage and forwarding to HealthComponent

@export var health_component: HealthComponent
@export var movement_component: MovementComponent

func _ready() -> void:
	collision_layer = 2  # Hurtbox layer by default
	collision_mask = 0   # Doesn't scan, gets scanned by Hitbox

func receive_hit(damage_info: DamageInfo) -> void:
	if health_component:
		health_component.take_damage(damage_info)
	
	if movement_component and damage_info.knockback_force != Vector2.ZERO:
		movement_component.apply_knockback(damage_info.knockback_force)
