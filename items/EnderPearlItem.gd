class_name EnderPearlItem
extends HCFItemResource

## HCF Ender Pearl: Teleports player to reticle target with 15s cooldown, 10 HP fall damage, and Minecraft Ender particles

@export var fall_damage: float = 10.0

func _init() -> void:
	item_id = "ender_pearl"
	item_name = "Ender Pearl"
	cooldown = 15.0
	stack_size = 16
	icon_texture = HCFItemResource.load_item_texture("ender_pearl")

func on_active_use(user: Node2D, target_pos: Vector2) -> bool:
	if not user or user is not Player:
		return false
	
	var player = user as Player
	var origin_pos = player.global_position
	var tree = player.get_tree()
	
	# 1. Particles at Origin
	_spawn_teleport_particles(tree, origin_pos, Color(0.1, 0.85, 0.75, 0.9))
	
	# 2. Teleport Player
	player.global_position = target_pos
	
	# 3. Particles at Destination
	_spawn_teleport_particles(tree, target_pos, Color(0.6, 0.2, 0.95, 0.9))
	
	# 4. Apply 10 HP Fall Damage
	if player.health_component:
		var damage_info = DamageInfo.new(fall_damage, null, GameEnums.DamageType.FALL)
		player.health_component.take_damage(damage_info)
	
	var bus = user.get_node_or_null("/root/EventBus")
	if bus:
		bus.camera_shake_requested.emit(4.0, 0.15)
	
	return true

func _spawn_teleport_particles(tree: SceneTree, pos: Vector2, particle_color: Color) -> void:
	if not tree or not tree.current_scene:
		return
	
	var particles = CPUParticles2D.new()
	particles.global_position = pos
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 0.85
	particles.lifetime = 0.6
	particles.amount = 28
	particles.direction = Vector2.ZERO
	particles.spread = 180.0
	particles.gravity = Vector2(0, 30)
	particles.initial_velocity_min = 50.0
	particles.initial_velocity_max = 140.0
	particles.scale_amount_min = 2.5
	particles.scale_amount_max = 4.5
	particles.color = particle_color
	
	tree.current_scene.add_child(particles)
	
	var timer = tree.create_timer(1.0)
	timer.timeout.connect(particles.queue_free)
