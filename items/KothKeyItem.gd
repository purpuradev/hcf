class_name KothKeyItem
extends HCFItemResource

## HCF KOTH Key: Used to unlock KOTH Crates in Spawn Castle for legendary loot

func _init() -> void:
	item_id = "koth_key"
	item_name = "KOTH Key"
	cooldown = 0.0
	stack_size = 16
	icon_texture = HCFItemResource.load_item_texture("koth_key")

static func _draw_koth_key_32(img: Image) -> void:
	var cyan = Color(0.18, 0.85, 0.85)
	var gold = Color(0.98, 0.78, 0.14)
	
	# Key Ring
	for x in range(8, 14):
		for y in range(8, 14):
			img.set_pixel(x, y, gold)
	img.set_pixel(10, 10, Color(0, 0, 0, 0))
	img.set_pixel(11, 10, Color(0, 0, 0, 0))
	img.set_pixel(10, 11, Color(0, 0, 0, 0))
	img.set_pixel(11, 11, Color(0, 0, 0, 0))
	
	# Shaft
	for i in range(13, 24):
		img.set_pixel(i, i, cyan)
		img.set_pixel(i+1, i, gold)
	
	# Key Teeth
	img.set_pixel(22, 20, gold)
	img.set_pixel(23, 21, gold)
