class_name MovementComponent
extends Node

## Handles 8-way directional movement, acceleration, friction, sprinting, and knockback

@export var max_speed: float = 200.0
@export var sprint_multiplier: float = 1.5
@export var acceleration: float = 1200.0
@export var friction: float = 1400.0
@export var knockback_decay: float = 1000.0

var move_direction: Vector2 = Vector2.ZERO
var is_sprinting: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO

@onready var character_body: CharacterBody2D = owner as CharacterBody2D

func _physics_process(delta: float) -> void:
	if not character_body:
		return
	
	# Process knockback decay
	if knockback_velocity.length() > 0:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)
	
	# Calculate target speed
	var current_max_speed = max_speed * (sprint_multiplier if is_sprinting else 1.0)
	var target_velocity = move_direction.normalized() * current_max_speed
	
	# Apply acceleration or friction
	if move_direction != Vector2.ZERO:
		character_body.velocity = character_body.velocity.move_toward(target_velocity, acceleration * delta)
	else:
		character_body.velocity = character_body.velocity.move_toward(Vector2.ZERO, friction * delta)
	
	# Add knockback overlay
	var total_velocity = character_body.velocity + knockback_velocity
	character_body.velocity = total_velocity
	character_body.move_and_slide()

func set_movement_direction(dir: Vector2) -> void:
	move_direction = dir

func apply_knockback(force: Vector2) -> void:
	knockback_velocity += force
