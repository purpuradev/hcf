class_name ZoneDetectorComponent
extends Area2D

## Detects map zone transitions and enforces solid Spawn Castle force-field during Combat Tag

signal zone_changed(current_zone: Area2D)

var current_zone: Area2D = null

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(area: Area2D) -> void:
	if area is ZoneArea:
		var zone = area as ZoneArea
		current_zone = zone
		zone_changed.emit(zone)
		
		var bus = get_node_or_null("/root/EventBus")
		if bus:
			bus.zone_entered.emit(zone.zone_name, zone.faction_type)
	elif area is RoadArea:
		var road = area as RoadArea
		var bus = get_node_or_null("/root/EventBus")
		if bus:
			bus.zone_entered.emit("%s Road" % road.road_direction, GameEnums.FactionType.WARZONE)

func _on_area_exited(area: Area2D) -> void:
	if current_zone == area:
		current_zone = null

func _physics_process(_delta: float) -> void:
	# Enforce Spawn Castle solid barrier every frame when Combat Tagged
	if not owner or owner is not Player:
		return
	
	var player = owner as Player
	if player.combat_tag_component and player.combat_tag_component.is_combat_tagged():
		var tree = player.get_tree()
		if tree and tree.current_scene:
			var spawn = tree.current_scene.find_child("SpawnCastle", true, false) as Area2D
			if spawn and is_instance_valid(spawn):
				_enforce_spawn_force_field(player, spawn)

func _enforce_spawn_force_field(player: Player, spawn: Area2D) -> void:
	var spawn_center = spawn.global_position
	var to_player = player.global_position - spawn_center
	var barrier_dist = 205.0 # Solid boundary just outside 200px green Spawn square
	
	if abs(to_player.x) < 200.0 and abs(to_player.y) < 200.0:
		var new_pos = player.global_position
		if abs(to_player.x) > abs(to_player.y):
			new_pos.x = spawn_center.x + (1.0 if to_player.x >= 0 else -1.0) * barrier_dist
		else:
			new_pos.y = spawn_center.y + (1.0 if to_player.y >= 0 else -1.0) * barrier_dist
		
		player.global_position = new_pos
		player.velocity = Vector2.ZERO
		
		var bus = player.get_node_or_null("/root/EventBus")
		if bus:
			bus.camera_shake_requested.emit(4.0, 0.1)
