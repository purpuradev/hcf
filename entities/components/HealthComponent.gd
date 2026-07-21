class_name HealthComponent
extends Node

## Handles health, damage calculations, healing, and death signals for entities

signal health_changed(current_hp: float, max_hp: float)
signal damaged(damage_info: DamageInfo)
signal healed(amount: float)
signal died

@export var max_health: float = 100.0
@export var is_invulnerable: bool = false

var current_health: float

func _ready() -> void:
	current_health = max_health

func _get_event_bus() -> Node:
	return get_node_or_null("/root/EventBus")

func take_damage(damage_info: DamageInfo) -> void:
	if is_invulnerable or current_health <= 0:
		return
	
	current_health = max(0.0, current_health - damage_info.amount)
	damaged.emit(damage_info)
	health_changed.emit(current_health, max_health)
	
	if owner is Player:
		var bus = _get_event_bus()
		if bus:
			bus.player_health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		die()

func heal(amount: float) -> void:
	if current_health <= 0:
		return
	
	current_health = min(max_health, current_health + amount)
	healed.emit(amount)
	health_changed.emit(current_health, max_health)
	
	if owner is Player:
		var bus = _get_event_bus()
		if bus:
			bus.player_health_changed.emit(current_health, max_health)

func die() -> void:
	died.emit()
	if owner is Player:
		var bus = _get_event_bus()
		if bus:
			bus.player_died.emit(owner)
