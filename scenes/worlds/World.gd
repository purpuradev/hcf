extends Node2D

@onready var player: Player = $Player
@onready var dummy: DummyTarget = $DummyTarget
@onready var camera: GameCamera = $GameCamera
@onready var class_label: Label = $CanvasLayer/HUD/VBoxContainer/ClassLabel
@onready var zone_label: Label = $CanvasLayer/HUD/VBoxContainer/ZoneLabel
@onready var combat_tag_label: Label = $CanvasLayer/HUD/VBoxContainer/CombatTagLabel
@onready var hotbar_ui: HotbarUI = $CanvasLayer/HUD/HotbarUI
@onready var crosshair: Label = $CanvasLayer/HUD/Crosshair

var rogue_class: ClassResource
var bard_class: ClassResource
var miner_class: ClassResource

func _ready() -> void:
	# Hide system mouse cursor and use crosshair '+' reticle
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	_init_classes()
	_spawn_crates()
	
	# Equip Rogue by default
	if player and player.class_system:
		player.class_system.equip_class(rogue_class)
	
	# Populate Player Hotbar:
	# Slot 1: Diamond Sword
	# Slot 2: Daga Rogue Backstab
	# Slot 3: Ender Pearl (16)
	# Slot 4: Golden Apple (64)
	# Slot 5: Bard Sugar (64)
	# Slot 6: KOTH Key (1)
	if player and player.hotbar_component:
		player.hotbar_component.set_slot_item(0, SwordItem.new(), 1)
		player.hotbar_component.set_slot_item(1, RogueBackstabItem.new(), 1)
		player.hotbar_component.set_slot_item(2, EnderPearlItem.new(), 16)
		player.hotbar_component.set_slot_item(3, GoldenAppleItem.new(), 64)
		player.hotbar_component.set_slot_item(4, BardSugarItem.new(), 64)
		player.hotbar_component.set_slot_item(5, KothKeyItem.new(), 1)
		
		if hotbar_ui:
			hotbar_ui.bind_hotbar(player.hotbar_component)
	
	# Connect HUD signals
	var bus = get_node_or_null("/root/EventBus")
	if bus:
		bus.zone_entered.connect(_on_zone_entered)
		bus.combat_tag_updated.connect(_on_combat_tag_updated)
		if player and player.health_component:
			bus.player_health_changed.emit(player.health_component.current_health, player.health_component.max_health)
		if player and player.hunger_component:
			bus.player_hunger_changed.emit(player.hunger_component.current_hunger, player.hunger_component.max_hunger)
	
	if player and player.class_system:
		player.class_system.class_changed.connect(_on_class_changed)

func _process(_delta: float) -> void:
	# Update Crosshair Reticle Position
	if crosshair:
		crosshair.global_position = get_viewport().get_mouse_position() - Vector2(10, 10)

func _spawn_crates() -> void:
	# KOTH Crate at (70, -70) inside Spawn Castle
	var koth_crate = Area2D.new()
	koth_crate.name = "KothCrate"
	koth_crate.script = load("res://scenes/interactables/CrateBox.gd")
	koth_crate.set("crate_type", "koth")
	koth_crate.set("crate_name", "KOTH Crate\n(Necesita Key)")
	koth_crate.global_position = Vector2(70, -70)
	
	var koth_col = CollisionShape2D.new()
	var koth_shape = CircleShape2D.new()
	koth_shape.radius = 28.0
	koth_col.shape = koth_shape
	koth_crate.add_child(koth_col)
	
	var koth_sprite = Sprite2D.new()
	koth_sprite.name = "Sprite2D"
	koth_crate.add_child(koth_sprite)
	
	var koth_label = Label.new()
	koth_label.name = "Label"
	koth_label.text = "KOTH Crate\n(Necesita Key)"
	koth_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	koth_label.add_theme_font_size_override("font_size", 10)
	koth_label.position = Vector2(-40, -45)
	koth_crate.add_child(koth_label)
	
	add_child(koth_crate)
	
	# Vote Crate at (-70, -70) inside Spawn Castle
	var vote_crate = Area2D.new()
	vote_crate.name = "VoteCrate"
	vote_crate.script = load("res://scenes/interactables/CrateBox.gd")
	vote_crate.set("crate_type", "vote")
	vote_crate.set("crate_name", "Vote Crate\n(Diario Gratis)")
	vote_crate.global_position = Vector2(-70, -70)
	
	var vote_col = CollisionShape2D.new()
	var vote_shape = CircleShape2D.new()
	vote_shape.radius = 28.0
	vote_col.shape = vote_shape
	vote_crate.add_child(vote_col)
	
	var vote_sprite = Sprite2D.new()
	vote_sprite.name = "Sprite2D"
	vote_crate.add_child(vote_sprite)
	
	var vote_label = Label.new()
	vote_label.name = "Label"
	vote_label.text = "Vote Crate\n(Diario Gratis)"
	vote_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vote_label.add_theme_font_size_override("font_size", 10)
	vote_label.position = Vector2(-40, -45)
	vote_crate.add_child(vote_label)
	
	add_child(vote_crate)

func _init_classes() -> void:
	rogue_class = ClassResource.new()
	rogue_class.class_id = "rogue"
	rogue_class.display_name = "Rogue"
	rogue_class.speed_multiplier = 1.3
	
	bard_class = ClassResource.new()
	bard_class.class_id = "bard"
	bard_class.display_name = "Bard"
	bard_class.speed_multiplier = 1.15
	
	miner_class = ClassResource.new()
	miner_class.class_id = "miner"
	miner_class.display_name = "Miner"
	miner_class.speed_multiplier = 1.0

func _unhandled_input(event: InputEvent) -> void:
	if not player or not player.class_system:
		return
	
	# Class Switcher Keys
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_Z:
			player.class_system.equip_class(rogue_class)
		elif event.keycode == KEY_X:
			player.class_system.equip_class(bard_class)
		elif event.keycode == KEY_C:
			player.class_system.equip_class(miner_class)
		elif event.keycode == KEY_T:
			if player.combat_tag_component:
				player.combat_tag_component.trigger_combat_tag(15.0)

func _on_class_changed(new_class: ClassResource) -> void:
	if class_label and new_class:
		class_label.text = "Clase: %s (Velocidad: %.1fx)" % [new_class.display_name, new_class.speed_multiplier]
		class_label.modulate = Color.CYAN if new_class.class_id == "rogue" else (Color.GOLD if new_class.class_id == "bard" else Color.WHITE)

func _on_zone_entered(zone_name: String, faction_type: GameEnums.FactionType) -> void:
	if zone_label:
		var type_str = "SAFEZONE" if faction_type == GameEnums.FactionType.SAFEZONE else ("WARZONE" if faction_type == GameEnums.FactionType.WARZONE else "WILDERNESS")
		zone_label.text = "Zona: %s [%s]" % [zone_name, type_str]
		zone_label.modulate = Color.GREEN if faction_type == GameEnums.FactionType.SAFEZONE else (Color.RED if faction_type == GameEnums.FactionType.WARZONE else Color.WHITE)

func _on_combat_tag_updated(remaining: float, is_active: bool) -> void:
	if combat_tag_label:
		if is_active:
			combat_tag_label.text = "COMBAT TAG: %.1fs" % remaining
			combat_tag_label.modulate = Color.RED
		else:
			combat_tag_label.text = "COMBAT TAG: Inactivo"
			combat_tag_label.modulate = Color.GREEN
