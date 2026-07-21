class_name ZoneArea
extends Area2D

## Defines map territory zones (Safezone, Warzone, Wilderness, Faction Claims)

@export var zone_name: String = "Wilderness"
@export var faction_type: GameEnums.FactionType = GameEnums.FactionType.WILDERNESS
@export var pvp_enabled: bool = true
@export var faction_id: String = ""

func _ready() -> void:
	collision_layer = 4  # Zone layer
	collision_mask = 0   # Doesn't scan, gets scanned by ZoneDetectorComponent
