class_name AbilitySystemComponent
extends Node

## Manages equipped ability slots, cooldowns, and activation triggers

signal ability_used(slot: GameEnums.AbilitySlot, ability: AbilityResource)
signal ability_failed(slot: GameEnums.AbilitySlot, reason: String)

@export var slot_1: AbilityResource
@export var slot_2: AbilityResource
@export var slot_3: AbilityResource

var cooldown_timers: Dictionary = {}

func _ready() -> void:
	_init_cooldown_timers()

func _init_cooldown_timers() -> void:
	for slot in [GameEnums.AbilitySlot.SLOT_1, GameEnums.AbilitySlot.SLOT_2, GameEnums.AbilitySlot.SLOT_3]:
		var timer = Timer.new()
		timer.one_shot = true
		add_child(timer)
		cooldown_timers[slot] = timer
		timer.timeout.connect(func(): EventBus.ability_cooldown_ended.emit(slot))

func get_ability_in_slot(slot: GameEnums.AbilitySlot) -> AbilityResource:
	match slot:
		GameEnums.AbilitySlot.SLOT_1: return slot_1
		GameEnums.AbilitySlot.SLOT_2: return slot_2
		GameEnums.AbilitySlot.SLOT_3: return slot_3
		_: return null

func activate_ability(slot: GameEnums.AbilitySlot) -> bool:
	var ability = get_ability_in_slot(slot)
	if not ability:
		ability_failed.emit(slot, "No ability equipped in slot.")
		return false
	
	var timer: Timer = cooldown_timers.get(slot)
	if timer and timer.time_left > 0:
		ability_failed.emit(slot, "Ability is on cooldown (%.1fs left)." % timer.time_left)
		return false
	
	# Execute ability effect
	var caster = owner as Node2D
	var success = ability.execute(caster)
	
	if success:
		if timer and ability.cooldown > 0:
			timer.start(ability.cooldown)
			EventBus.ability_cooldown_started.emit(slot, ability.cooldown)
		
		ability_used.emit(slot, ability)
		EventBus.ability_activated.emit(slot, ability)
		return true
	else:
		ability_failed.emit(slot, "Failed to cast ability.")
		return false

func is_on_cooldown(slot: GameEnums.AbilitySlot) -> bool:
	var timer: Timer = cooldown_timers.get(slot)
	return timer != null and timer.time_left > 0

func get_cooldown_remaining(slot: GameEnums.AbilitySlot) -> float:
	var timer: Timer = cooldown_timers.get(slot)
	return timer.time_left if timer else 0.0
