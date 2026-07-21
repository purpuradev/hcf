class_name CrateBox
extends Area2D

## Interactive KOTH / Vote Loot Crate placed inside Spawn Castle (Authentic Minecraft 128x PNG Sprites)

@export var crate_type: String = "koth" # "koth" or "vote"
@export var crate_name: String = "KOTH Crate"

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	if sprite:
		var tex_id = "koth_crate" if crate_type == "koth" else "vote_crate"
		sprite.texture = HCFItemResource.load_item_texture(tex_id)
		sprite.scale = Vector2(0.25, 0.25)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var player = body as Player
		_try_open_crate(player)

func _try_open_crate(player: Player) -> void:
	if not player.hotbar_component:
		return
	
	var held = player.hotbar_component.get_held_item()
	if crate_type == "koth":
		if held and held.item_id == "koth_key":
			player.hotbar_component.consume_held_item(1)
			_reward_player(player, "¡KOTH Key Usada!\n+16x Ender Pearls & +64x Gapples!")
		else:
			_show_crate_info("¡KOTH Crate!\n(Equipa KOTH Key en Slot 6 y entra)")
	else:
		_reward_player(player, "¡Vote Crate Abierto!\nRecompensa Diaria Concedida!")

func _reward_player(player: Player, msg: String) -> void:
	if player.hotbar_component:
		player.hotbar_component.set_slot_item(2, EnderPearlItem.new(), 16)
		player.hotbar_component.set_slot_item(3, GoldenAppleItem.new(), 64)
	
	var tree = get_tree()
	if tree and tree.current_scene:
		var particles = CPUParticles2D.new()
		particles.global_position = global_position
		particles.emitting = true
		particles.one_shot = true
		particles.explosiveness = 0.9
		particles.lifetime = 0.8
		particles.amount = 36
		particles.direction = Vector2.ZERO
		particles.spread = 180.0
		particles.gravity = Vector2(0, 40)
		particles.initial_velocity_min = 60.0
		particles.initial_velocity_max = 160.0
		particles.color = Color(0.98, 0.78, 0.14)
		tree.current_scene.add_child(particles)
		
		var timer = tree.create_timer(1.2)
		timer.timeout.connect(particles.queue_free)
	
	if label:
		label.text = msg
		label.modulate = Color.YELLOW
		var reset_timer = get_tree().create_timer(3.0)
		reset_timer.timeout.connect(func(): label.text = crate_name)

func _show_crate_info(msg: String) -> void:
	if label:
		label.text = msg
		label.modulate = Color.CYAN
		var reset_timer = get_tree().create_timer(2.5)
		reset_timer.timeout.connect(func(): label.text = crate_name)
