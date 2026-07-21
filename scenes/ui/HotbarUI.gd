class_name HotbarUI
extends Control

## Sleek, compact UI displaying 9 Hotbar slots, pixel art item icons, stack counts, 6 Health Circles and 6 Food Circles

@export var hotbar_component: HotbarComponent

@onready var container: HBoxContainer = $VBoxContainer/HBoxContainer
@onready var hearts_container: HBoxContainer = $VBoxContainer/BarsContainer/HeartsContainer
@onready var food_container: HBoxContainer = $VBoxContainer/BarsContainer/FoodContainer

var slot_panels: Array[PanelContainer] = []
var slot_labels: Array[Label] = []
var slot_icon_rects: Array[TextureRect] = []
var slot_count_labels: Array[Label] = []
var cooldown_overlays: Array[ColorRect] = []

var heart_nodes: Array[ColorRect] = []
var food_nodes: Array[ColorRect] = []

func _ready() -> void:
	_create_discrete_icons()
	_create_hotbar_slots()
	if hotbar_component:
		bind_hotbar(hotbar_component)
	
	var bus = get_node_or_null("/root/EventBus")
	if bus:
		bus.player_health_changed.connect(_on_player_health_changed)
		bus.player_hunger_changed.connect(_on_player_hunger_changed)

func _create_discrete_icons() -> void:
	if not hearts_container or not food_container:
		return
		
	for child in hearts_container.get_children():
		child.queue_free()
	heart_nodes.clear()
	
	for i in range(6):
		var rect = ColorRect.new()
		rect.custom_minimum_size = Vector2(16, 16)
		rect.color = Color(0.93, 0.27, 0.27)
		hearts_container.add_child(rect)
		heart_nodes.append(rect)
	
	for child in food_container.get_children():
		child.queue_free()
	food_nodes.clear()
	
	for i in range(6):
		var rect = ColorRect.new()
		rect.custom_minimum_size = Vector2(16, 16)
		rect.color = Color(0.97, 0.45, 0.09)
		food_container.add_child(rect)
		food_nodes.append(rect)

func _create_hotbar_slots() -> void:
	if not container:
		return
		
	for child in container.get_children():
		child.queue_free()
	
	slot_panels.clear()
	slot_labels.clear()
	slot_icon_rects.clear()
	slot_count_labels.clear()
	cooldown_overlays.clear()
	
	for i in range(9):
		var panel = PanelContainer.new()
		panel.custom_minimum_size = Vector2(46, 46)
		
		var margin = MarginContainer.new()
		margin.custom_minimum_size = Vector2(40, 40)
		margin.add_theme_constant_override("margin_left", 2)
		margin.add_theme_constant_override("margin_top", 2)
		margin.add_theme_constant_override("margin_right", 2)
		margin.add_theme_constant_override("margin_bottom", 2)
		
		# Texture Icon Rect
		var icon_rect = TextureRect.new()
		icon_rect.custom_minimum_size = Vector2(36, 36)
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.visible = false
		margin.add_child(icon_rect)
		
		# Text Label Fallback
		var label = Label.new()
		label.text = "%d" % (i + 1)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.clip_text = true
		label.add_theme_font_size_override("font_size", 10)
		margin.add_child(label)
		
		var count_label = Label.new()
		count_label.text = ""
		count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		count_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		count_label.add_theme_font_size_override("font_size", 10)
		count_label.set_anchors_preset(Control.PRESET_FULL_RECT)
		
		var cooldown_overlay = ColorRect.new()
		cooldown_overlay.color = Color(0, 0, 0, 0.65)
		cooldown_overlay.visible = false
		cooldown_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
		
		panel.add_child(margin)
		panel.add_child(count_label)
		panel.add_child(cooldown_overlay)
		container.add_child(panel)
		
		slot_panels.append(panel)
		slot_labels.append(label)
		slot_icon_rects.append(icon_rect)
		slot_count_labels.append(count_label)
		cooldown_overlays.append(cooldown_overlay)
	
	update_selection(0)

func bind_hotbar(component: HotbarComponent) -> void:
	hotbar_component = component
	if not hotbar_component:
		return
	
	hotbar_component.slot_selected.connect(_on_slot_selected)
	hotbar_component.hotbar_updated.connect(_on_hotbar_updated)
	hotbar_component.cooldown_updated.connect(_on_cooldown_updated)
	
	_on_hotbar_updated(hotbar_component.slots, hotbar_component.slot_counts)
	update_selection(hotbar_component.selected_slot)

func update_selection(selected_index: int) -> void:
	for i in range(slot_panels.size()):
		if i == selected_index:
			slot_panels[i].modulate = Color(1.8, 1.6, 0.4, 1.0)
		else:
			slot_panels[i].modulate = Color(1.0, 1.0, 1.0, 0.9)

func _on_player_health_changed(current: float, max_hp: float) -> void:
	if heart_nodes.size() < 6:
		return
	var ratio = clamp(current / max_hp, 0.0, 1.0) if max_hp > 0 else 0.0
	var active_count = int(ceil(ratio * 6.0))
	
	for i in range(min(6, heart_nodes.size())):
		if i < active_count:
			heart_nodes[i].color = Color(0.93, 0.27, 0.27)
		else:
			heart_nodes[i].color = Color(0.2, 0.2, 0.2, 0.4)

func _on_player_hunger_changed(current: float, max_hunger: float) -> void:
	if food_nodes.size() < 6:
		return
	var ratio = clamp(current / max_hunger, 0.0, 1.0) if max_hunger > 0 else 0.0
	var active_count = int(ceil(ratio * 6.0))
	
	for i in range(min(6, food_nodes.size())):
		if i < active_count:
			food_nodes[i].color = Color(0.97, 0.45, 0.09)
		else:
			food_nodes[i].color = Color(0.2, 0.2, 0.2, 0.4)

func _on_slot_selected(index: int, _item: HCFItemResource, _count: int) -> void:
	update_selection(index)

func _on_hotbar_updated(slots: Array, counts: Array) -> void:
	for i in range(min(slots.size(), slot_labels.size())):
		var item = slots[i] as HCFItemResource
		var count = counts[i] if i < counts.size() else 0
		
		if item and count > 0:
			if not item.icon_texture:
				item.icon_texture = _fallback_load_texture(item.item_id)
			
			if item.icon_texture:
				slot_icon_rects[i].texture = item.icon_texture
				slot_icon_rects[i].visible = true
				slot_labels[i].visible = false
			else:
				slot_icon_rects[i].visible = false
				slot_labels[i].visible = true
				var short_name = item.item_name
				if item.item_id == "diamond_sword": short_name = "Espada"
				elif item.item_id == "rogue_backstab": short_name = "Daga"
				elif item.item_id == "ender_pearl": short_name = "Perla"
				elif item.item_id == "golden_apple": short_name = "Manzana"
				elif item.item_id == "bard_sugar": short_name = "Azucar"
				slot_labels[i].text = "%s" % short_name
			
			slot_count_labels[i].text = "%d" if item.stack_size > 1 else ""
		else:
			slot_icon_rects[i].visible = false
			slot_labels[i].visible = true
			slot_labels[i].text = "%d" % (i + 1)
			slot_count_labels[i].text = ""

func _fallback_load_texture(item_id: String) -> Texture2D:
	var path_map = {
		"diamond_sword": "res://assets/sprites/diamond_sword.png",
		"rogue_backstab": "res://assets/sprites/rogue_dagger.png",
		"ender_pearl": "res://assets/sprites/ender_pearl.png",
		"golden_apple": "res://assets/sprites/golden_apple.png",
		"bard_sugar": "res://assets/sprites/bard_sugar.png"
	}
	if path_map.has(item_id):
		return HCFItemResource.load_item_texture(path_map[item_id])
	return null

func _on_cooldown_updated(item_id: String, remaining: float, total: float) -> void:
	if not hotbar_component:
		return
	
	for i in range(hotbar_component.slots.size()):
		var item = hotbar_component.slots[i]
		if item and item.item_id == item_id:
			var overlay = cooldown_overlays[i]
			if remaining > 0:
				overlay.visible = true
			else:
				overlay.visible = false
