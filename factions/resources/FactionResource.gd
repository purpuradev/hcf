class_name FactionResource
extends Resource

## Data resource representing an HCF Faction, its members, and DTR status

@export var faction_id: String = "faction_id"
@export var faction_name: String = "Faction Name"
@export var dtr: float = 1.1
@export var max_dtr: float = 5.5
@export var members: Array[String] = []
@export var color: Color = Color.CORNFLOWER_BLUE
@export var home_location: Vector2 = Vector2.ZERO

var dtr_regen_rate: float = 0.1 # DTR per minute
var dtr_freeze_timer: float = 0.0 # Seconds remaining before DTR regenerates

func _get_event_bus() -> Node:
	if Engine.get_main_loop():
		return Engine.get_main_loop().root.get_node_or_null("EventBus")
	return null

func is_raidable() -> bool:
	return dtr <= 0.0

func apply_death_penalty(penalty: float = 1.0, freeze_seconds: float = 2700.0) -> void:
	dtr = max(-1.0, dtr - penalty)
	dtr_freeze_timer = freeze_seconds
	var bus = _get_event_bus()
	if bus:
		bus.faction_dtr_changed.emit(faction_id, dtr, is_raidable())

func process_dtr_regen(delta: float) -> void:
	if dtr_freeze_timer > 0:
		dtr_freeze_timer -= delta
	elif dtr < max_dtr:
		dtr = min(max_dtr, dtr + (dtr_regen_rate / 60.0) * delta)
		var bus = _get_event_bus()
		if bus:
			bus.faction_dtr_changed.emit(faction_id, dtr, is_raidable())
