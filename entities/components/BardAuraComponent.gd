class_name BardAuraComponent
extends Area2D

## Emits HCF Bard musical team auras (Speed II, Strength I, Resistance) to nearby allies

signal aura_pulsed(buff_type: String, affected_count: int)

@export var aura_radius: float = 250.0
@export var is_active: bool = false
@export var current_aura: String = "Speed II"

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	_update_aura_radius()

func _update_aura_radius() -> void:
	if collision_shape and collision_shape.shape is CircleShape2D:
		(collision_shape.shape as CircleShape2D).radius = aura_radius

func pulse_aura() -> void:
	if not is_active:
		return
	
	var overlapping_bodies = get_overlapping_bodies()
	var affected = 0
	
	for body in overlapping_bodies:
		if body is CharacterBody2D:
			affected += 1
	
	aura_pulsed.emit(current_aura, affected)
	var bus = get_node_or_null("/root/EventBus")
	if bus:
		bus.camera_shake_requested.emit(1.5, 0.1)
