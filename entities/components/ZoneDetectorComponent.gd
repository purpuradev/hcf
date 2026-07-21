class_name ZoneDetectorComponent
extends Area2D

## Scans ZoneArea nodes and enforces Safezone entry restrictions when combat tagged

signal zone_changed(zone: ZoneArea)

var current_zone: ZoneArea = null
var previous_position: Vector2 = Vector2.ZERO

@onready var combat_tag_component: CombatTagComponent = get_node_or_null("../CombatTagComponent")
@onready var movement_component: MovementComponent = get_node_or_null("../MovementComponent")

func _ready() -> void:
	collision_layer = 0
	collision_mask = 4
	area_entered.connect(_on_zone_entered)
	if owner is Node2D:
		previous_position = (owner as Node2D).global_position

func _physics_process(_delta: float) -> void:
	if owner is Node2D and current_zone and current_zone.pvp_enabled:
		previous_position = (owner as Node2D).global_position

func _on_zone_entered(area: Area2D) -> void:
	if area is ZoneArea:
		if area.faction_type == GameEnums.FactionType.SAFEZONE and combat_tag_component and combat_tag_component.is_tagged:
			_reject_safezone_entry(area)
			return
		
		current_zone = area
		zone_changed.emit(current_zone)
		var bus = get_node_or_null("/root/EventBus")
		if bus:
			bus.zone_entered.emit(area.zone_name, area.faction_type)

func _reject_safezone_entry(safezone_area: Area2D) -> void:
	if owner is Node2D and movement_component:
		var player_pos = (owner as Node2D).global_position
		var push_dir = (player_pos - safezone_area.global_position).normalized()
		if push_dir == Vector2.ZERO:
			push_dir = Vector2.RIGHT
		
		movement_component.apply_knockback(push_dir * 120.0)
		var bus = get_node_or_null("/root/EventBus")
		if bus:
			bus.camera_shake_requested.emit(2.0, 0.1)
