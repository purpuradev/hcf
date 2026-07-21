class_name HotbarComponent
extends Node

## Manages 9 Minecraft-style hotbar slots, stack counts, passive hold tick, and Right-Click/Left-Click item mechanics

signal slot_selected(index: int, item: HCFItemResource, count: int)
signal hotbar_updated(slots: Array, counts: Array)
signal cooldown_updated(item_id: String, remaining: float, total: float)

@export var max_slots: int = 9
@export var eat_duration: float = 0.25 # Time in seconds holding Right Click to eat food

var slots: Array[HCFItemResource] = []
var slot_counts: Array[int] = []
var selected_slot: int = 0
var cooldowns: Dictionary = {}

var is_right_click_held: bool = false
var eat_timer: float = 0.0

func _ready() -> void:
	slots.resize(max_slots)
	slot_counts.resize(max_slots)
	for i in range(max_slots):
		slot_counts[i] = 0

func _input(event: InputEvent) -> void:
	if not is_inside_tree() or not owner:
		return
		
	# Mouse Wheel Slot Scrolling
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				select_slot((selected_slot - 1 + max_slots) % max_slots)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				select_slot((selected_slot + 1) % max_slots)
			elif event.button_index == MouseButton.MOUSE_BUTTON_RIGHT:
				is_right_click_held = true
				eat_timer = 0.0
				_handle_right_click_press()
			elif event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
				_handle_left_click_press()
		else:
			if event.button_index == MouseButton.MOUSE_BUTTON_RIGHT:
				is_right_click_held = false
				eat_timer = 0.0

func _handle_left_click_press() -> void:
	var item = get_held_item()
	# Left Click with Weapon vs Fist/Consumable Punch
	if item and (item.item_id == "diamond_sword" or item.item_id == "rogue_backstab"):
		use_held_item()
	else:
		_trigger_primary_attack()

func _handle_right_click_press() -> void:
	var item = get_held_item()
	if not item or get_held_count() <= 0:
		return
	
	# Ender Pearl & Bard Sugar activate immediately on Right Click
	if item.item_id == "ender_pearl" or item.item_id == "bard_sugar":
		use_held_item()

func _physics_process(delta: float) -> void:
	# Process Cooldown Timers
	for item_id in cooldowns.keys():
		var data = cooldowns[item_id]
		data["remaining"] -= delta
		if data["remaining"] <= 0:
			cooldowns.erase(item_id)
			cooldown_updated.emit(item_id, 0.0, 1.0)
		else:
			cooldown_updated.emit(item_id, data["remaining"], data["total"])
	
	# Process Food Eating on holding Right Click
	if is_right_click_held:
		var held_item = get_held_item()
		if held_item and held_item.item_id == "golden_apple":
			eat_timer += delta
			if eat_timer >= eat_duration:
				eat_timer = 0.0
				use_held_item()
	
	# Process Passive Hold Tick for currently selected item
	var held = get_held_item()
	if held and owner is Node2D:
		held.on_hold_tick(owner as Node2D, delta)

func _trigger_primary_attack() -> void:
	if not is_inside_tree() or not owner or owner is not Player:
		return
	
	var user = owner as Player
	var tree = user.get_tree()
	if not tree:
		return
	var world = tree.current_scene
	if not world:
		return
	
	var dummy = world.find_child("DummyTarget", true, false) as Node2D
	if dummy and is_instance_valid(dummy):
		var mouse_pos = user.get_global_mouse_position()
		var dist_to_dummy = mouse_pos.distance_to(dummy.global_position)
		var player_dist = user.global_position.distance_to(dummy.global_position)
		if dist_to_dummy <= 80.0 or player_dist <= 140.0:
			user.attack_target(dummy)

func select_slot(index: int) -> void:
	if index >= 0 and index < max_slots:
		selected_slot = index
		slot_selected.emit(selected_slot, get_held_item(), get_held_count())

func set_slot_item(index: int, item: HCFItemResource, count: int = -1) -> void:
	if index >= 0 and index < max_slots:
		slots[index] = item
		slot_counts[index] = item.stack_size if (count < 0 and item) else max(0, count)
		hotbar_updated.emit(slots, slot_counts)

func get_held_item() -> HCFItemResource:
	if selected_slot >= 0 and selected_slot < slots.size():
		return slots[selected_slot]
	return null

func get_held_count() -> int:
	if selected_slot >= 0 and selected_slot < slot_counts.size():
		return slot_counts[selected_slot]
	return 0

func is_on_cooldown(item_id: String) -> bool:
	return cooldowns.has(item_id) and cooldowns[item_id]["remaining"] > 0

func use_held_item() -> bool:
	var item = get_held_item()
	if not item or get_held_count() <= 0:
		return false
	
	if is_on_cooldown(item.item_id):
		return false
	
	var user = owner as Node2D
	var target_pos = user.get_global_mouse_position() if user else Vector2.ZERO
	var success = item.on_active_use(user, target_pos)
	
	if success:
		if item.item_id != "diamond_sword" and item.item_id != "rogue_backstab":
			slot_counts[selected_slot] -= 1
			if slot_counts[selected_slot] <= 0:
				slot_counts[selected_slot] = 0
				slots[selected_slot] = null
		
		if item.cooldown > 0:
			cooldowns[item.item_id] = {"remaining": item.cooldown, "total": item.cooldown}
			cooldown_updated.emit(item.item_id, item.cooldown, item.cooldown)
		
		hotbar_updated.emit(slots, slot_counts)
	
	return success
