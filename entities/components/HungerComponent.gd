class_name HungerComponent
extends Node

## Manages player hunger/food level, depletion during sprinting/movement, and eating restoration

signal hunger_changed(current_hunger: float, max_hunger: float)

@export var max_hunger: float = 100.0
@export var depletion_rate: float = 2.0 # Hunger per second while walking
@export var sprint_depletion_multiplier: float = 3.0

var current_hunger: float

@onready var movement_component: MovementComponent = get_node_or_null("../MovementComponent")

func _ready() -> void:
	current_hunger = max_hunger
	call_deferred("_emit_initial_hunger")

func _emit_initial_hunger() -> void:
	var bus = get_node_or_null("/root/EventBus")
	if bus:
		bus.player_hunger_changed.emit(current_hunger, max_hunger)

func _process(delta: float) -> void:
	if not movement_component or owner is not Player:
		return
	
	# Deplete hunger while moving
	if movement_component.move_direction != Vector2.ZERO:
		var rate = depletion_rate * (sprint_depletion_multiplier if movement_component.is_sprinting else 1.0)
		deplete_hunger(rate * delta)

func deplete_hunger(amount: float) -> void:
	if current_hunger <= 0:
		return
	current_hunger = max(0.0, current_hunger - amount)
	hunger_changed.emit(current_hunger, max_hunger)
	
	var bus = get_node_or_null("/root/EventBus")
	if bus:
		bus.player_hunger_changed.emit(current_hunger, max_hunger)

func eat_food(amount: float) -> void:
	current_hunger = min(max_hunger, current_hunger + amount)
	hunger_changed.emit(current_hunger, max_hunger)
	
	var bus = get_node_or_null("/root/EventBus")
	if bus:
		bus.player_hunger_changed.emit(current_hunger, max_hunger)
