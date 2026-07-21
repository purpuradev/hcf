class_name HCFItemResource
extends Resource

## Data Resource defining HCF items with Passive Hold and Active Click mechanics

@export var item_id: String = "item_id"
@export var item_name: String = "HCF Item"
@export var icon: Texture2D
@export var cooldown: float = 0.0
@export var stack_size: int = 64

## Virtual method: Processed every frame while held in active hotbar slot
func on_hold_tick(_holder: Node2D, _delta: float) -> void:
	pass

## Virtual method: Triggered when right-clicking while holding item
func on_active_use(_user: Node2D, _target_position: Vector2) -> bool:
	return true
