class_name CombatTagComponent
extends Node

## Manages active PvP Combat Tag timer (prevents logging out / entering safezone)

@export var default_tag_duration: float = 30.0

var remaining_time: float = 0.0
var is_tagged: bool = false

func _ready() -> void:
	var health = get_node_or_null("../HealthComponent") as HealthComponent
	if health:
		health.damaged.connect(func(_info): trigger_combat_tag())

func _get_event_bus() -> Node:
	return get_node_or_null("/root/EventBus")

func _process(delta: float) -> void:
	if remaining_time > 0:
		remaining_time -= delta
		var bus = _get_event_bus()
		if remaining_time <= 0:
			remaining_time = 0.0
			is_tagged = false
			if bus:
				bus.combat_tag_updated.emit(0.0, false)
		else:
			if bus:
				bus.combat_tag_updated.emit(remaining_time, true)

func trigger_combat_tag(duration: float = -1.0) -> void:
	var tag_duration = default_tag_duration if duration < 0 else duration
	remaining_time = max(remaining_time, tag_duration)
	is_tagged = true
	var bus = _get_event_bus()
	if bus:
		bus.combat_tag_updated.emit(remaining_time, true)
