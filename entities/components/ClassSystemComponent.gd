class_name ClassSystemComponent
extends Node

## Manages active HCF class, passive stats, and class abilities

signal class_changed(new_class: ClassResource)

@export var current_class: ClassResource

@onready var movement_component: MovementComponent = get_node_or_null("../MovementComponent")
@onready var ability_system: AbilitySystemComponent = get_node_or_null("../AbilitySystemComponent")
@onready var bard_aura: BardAuraComponent = get_node_or_null("../BardAuraComponent")

func _ready() -> void:
	if current_class:
		equip_class(current_class)

func equip_class(new_class: ClassResource) -> void:
	current_class = new_class
	
	if not current_class:
		return
	
	# Apply class speed multiplier to MovementComponent
	if movement_component:
		movement_component.max_speed = 200.0 * current_class.speed_multiplier
	
	# Equip class abilities to AbilitySystemComponent slots
	if ability_system:
		if current_class.primary_ability:
			ability_system.slot_1 = current_class.primary_ability
		if current_class.secondary_ability:
			ability_system.slot_2 = current_class.secondary_ability
	
	# Enable/Disable Bard Aura
	if bard_aura:
		bard_aura.is_active = (current_class.class_id == "bard")
	
	class_changed.emit(current_class)
