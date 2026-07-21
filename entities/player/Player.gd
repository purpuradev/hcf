class_name Player
extends CharacterBody2D

## Main Player controller for 2D Hardcore Factions (Authentic Minecraft 128x PNG Sprites)

@onready var movement_component: MovementComponent = $MovementComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var hunger_component: HungerComponent = $HungerComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var ability_system: AbilitySystemComponent = $AbilitySystemComponent
@onready var combat_tag_component: CombatTagComponent = $CombatTagComponent
@onready var zone_detector_component: ZoneDetectorComponent = $ZoneDetectorComponent
@onready var class_system: ClassSystemComponent = $ClassSystemComponent
@onready var backstab_component: BackstabComponent = $BackstabComponent
@onready var bard_aura: BardAuraComponent = $BardAuraComponent
@onready var hotbar_component: HotbarComponent = $HotbarComponent
@onready var sprite: Sprite2D = $Sprite2D

var current_state: GameEnums.PlayerState = GameEnums.PlayerState.IDLE

func _ready() -> void:
	add_to_group("player")
	
	if sprite:
		sprite.texture = HCFItemResource.load_item_texture("player_character")
		sprite.scale = Vector2(0.25, 0.25)
	
	var bus = get_node_or_null("/root/EventBus")
	if bus:
		bus.player_spawned.emit(self)
	
	if health_component:
		health_component.died.connect(_on_died)
	
	if hurtbox_component and health_component and movement_component:
		hurtbox_component.health_component = health_component
		hurtbox_component.movement_component = movement_component

func _unhandled_input(event: InputEvent) -> void:
	if current_state == GameEnums.PlayerState.DEAD:
		return
	
	# Hotbar number key selection (Keys 1 to 9)
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode >= KEY_1 and event.keycode <= KEY_9:
			var slot_idx = event.keycode - KEY_1
			if hotbar_component:
				hotbar_component.select_slot(slot_idx)

func _physics_process(_delta: float) -> void:
	if current_state == GameEnums.PlayerState.DEAD:
		return
	
	# Fetch input movement vector
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var is_sprinting = Input.is_action_pressed("sprint")
	
	movement_component.set_movement_direction(input_dir)
	movement_component.is_sprinting = is_sprinting
	
	# Update visual orientation
	if input_dir.x != 0 and sprite:
		sprite.flip_h = input_dir.x < 0
	
	# Update state
	if input_dir != Vector2.ZERO:
		current_state = GameEnums.PlayerState.RUNNING if is_sprinting else GameEnums.PlayerState.WALKING
	else:
		current_state = GameEnums.PlayerState.IDLE

func attack_target(target: Node2D) -> void:
	if not target:
		return
	
	# Standard attack damage (15 HP with Diamond Sword, 5 HP with Fist)
	var base_damage: float = 5.0
	if hotbar_component:
		var held = hotbar_component.get_held_item()
		if held and held.item_id == "diamond_sword":
			base_damage = 15.0
	
	var damage_info = DamageInfo.new(base_damage, self, GameEnums.DamageType.PHYSICAL)
	
	if target.has_node("HurtboxComponent"):
		var hurtbox = target.get_node("HurtboxComponent") as HurtboxComponent
		hurtbox.receive_hit(damage_info)

func _on_died() -> void:
	current_state = GameEnums.PlayerState.DEAD
	movement_component.set_movement_direction(Vector2.ZERO)
	modulate = Color(0.4, 0.4, 0.4, 0.8) # Visual graying out on death
