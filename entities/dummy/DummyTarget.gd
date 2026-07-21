class_name DummyTarget
extends CharacterBody2D

## Test Target Dummy for HCF combat, damage, and backstab testing (Authentic Minecraft 128x PNG Sprites)

@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label

func _ready() -> void:
	if sprite:
		sprite.texture = HCFItemResource.load_item_texture("target_dummy")
		sprite.scale = Vector2(0.25, 0.25)
	
	if hurtbox_component and health_component:
		hurtbox_component.health_component = health_component
	
	if health_component:
		health_component.damaged.connect(_on_damaged)

func _on_damaged(damage_info: DamageInfo) -> void:
	if label:
		if damage_info.is_critical:
			label.text = "CRITICAL BACKSTAB!\n-%.1f HP" % damage_info.amount
			label.modulate = Color.YELLOW
		else:
			label.text = "-%.1f HP" % damage_info.amount
			label.modulate = Color.RED
		
		# Reset label text after 1.5 seconds
		var timer = get_tree().create_timer(1.5)
		timer.timeout.connect(func(): label.text = "Dummy Target\n(Espalda hacia Izq)")
