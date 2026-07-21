extends Node

## Central EventBus signal hub for decoupled architecture

# Player & Health Signals
signal player_spawned(player: Node2D)
signal player_health_changed(current_health: float, max_health: float)
signal player_hunger_changed(current_hunger: float, max_hunger: float)
signal player_died(player: Node2D)
signal player_stamina_changed(current_stamina: float, max_stamina: float)

# Combat & Damage Signals
signal entity_damaged(target: Node2D, damage_info: Variant)
signal entity_healed(target: Node2D, amount: float)

# Ability Signals
signal ability_activated(slot: GameEnums.AbilitySlot, ability_resource: Resource)
signal ability_cooldown_started(slot: GameEnums.AbilitySlot, duration: float)
signal ability_cooldown_ended(slot: GameEnums.AbilitySlot)

# Camera & Effects Signals
signal camera_shake_requested(intensity: float, duration: float)

# World & Faction Signals
signal zone_entered(zone_name: String, faction_type: GameEnums.FactionType)
signal scene_change_requested(scene_path: String)
signal faction_dtr_changed(faction_id: String, dtr: float, is_raidable: bool)
signal combat_tag_updated(remaining_seconds: float, is_active: bool)

func _ready() -> void:
	_setup_default_input_map()

func _setup_default_input_map() -> void:
	var default_inputs = {
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"move_up": [KEY_W, KEY_UP],
		"move_down": [KEY_S, KEY_DOWN],
		"sprint": [KEY_SHIFT],
		"ability_1": [KEY_1],
		"ability_2": [KEY_2],
		"ability_3": [KEY_3],
	}
	
	for action_name in default_inputs:
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
			for key in default_inputs[action_name]:
				var event = InputEventKey.new()
				event.physical_keycode = key
				InputMap.action_add_event(action_name, event)
