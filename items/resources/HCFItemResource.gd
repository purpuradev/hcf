class_name HCFItemResource
extends Resource

## Base Resource for all HCF Items (Sugar, Ender Pearl, Gapple, Swords)

@export var item_id: String = ""
@export var item_name: String = ""
@export var cooldown: float = 0.0
@export var stack_size: int = 64
@export var icon_texture: Texture2D = null

func on_hold_tick(_user: Node2D, _delta: float) -> void:
	pass

func on_active_use(_user: Node2D, _target_pos: Vector2) -> bool:
	return true

static func load_item_texture(res_path: String) -> Texture2D:
	var abs_path = ProjectSettings.globalize_path(res_path)
	
	# 1. Try absolute OS path with Image.load()
	var img = Image.new()
	var err = img.load(abs_path)
	if err == OK and not img.is_empty():
		return ImageTexture.create_from_image(img)
	
	# 2. Try res:// path with Image.load()
	err = img.load(res_path)
	if err == OK and not img.is_empty():
		return ImageTexture.create_from_image(img)
	
	# 3. Fallback to engine loader
	if ResourceLoader.exists(res_path):
		return load(res_path) as Texture2D
		
	return null
