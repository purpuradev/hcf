class_name GameCamera
extends Camera2D

## Camera system with target tracking, smooth lag, and screenshake support

@export var target: Node2D
@export var follow_speed: float = 10.0
@export var position_offset: Vector2 = Vector2.ZERO

var shake_intensity: float = 0.0
var shake_duration: float = 0.0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	
	var bus = get_node_or_null("/root/EventBus")
	if bus:
		bus.player_spawned.connect(_on_player_spawned)
		bus.camera_shake_requested.connect(shake)
	
	# Fallback: if player spawned before camera ready, find player directly
	if not target:
		call_deferred("_find_player_target")

func _find_player_target() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]
	else:
		var scene_root = get_tree().current_scene
		if scene_root:
			target = scene_root.find_child("Player", true, false) as Node2D
	
	if target:
		global_position = target.global_position + position_offset

func _on_player_spawned(player_node: Node2D) -> void:
	target = player_node
	if target:
		global_position = target.global_position + position_offset

func _process(delta: float) -> void:
	# Target Follow Interpolation
	if target and is_instance_valid(target):
		var target_pos = target.global_position + position_offset
		global_position = global_position.lerp(target_pos, follow_speed * delta)
	
	# Screenshake processing
	if shake_duration > 0:
		shake_duration -= delta
		var offset_shake = Vector2(
			rng.randf_range(-shake_intensity, shake_intensity),
			rng.randf_range(-shake_intensity, shake_intensity)
		)
		offset = offset_shake
	else:
		offset = Vector2.ZERO

func shake(intensity: float, duration: float) -> void:
	shake_intensity = intensity
	shake_duration = duration
