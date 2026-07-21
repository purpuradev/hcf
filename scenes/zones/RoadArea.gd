class_name RoadArea
extends Area2D

## Defines an HCF Cardinal Road (North, South, East, West) extending from Spawn Castle into Warzone

@export var road_name: String = "North Road"
@export var road_direction: String = "NORTH"

func _ready() -> void:
	collision_layer = 4 # Zone layer
	collision_mask = 0  # Scanned by ZoneDetectorComponent
