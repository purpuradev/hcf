class_name HCFItemResource
extends Resource

## Base Resource for all HCF Items & Sprites (Real PNG Image Loader)

@export var item_id: String = ""
@export var item_name: String = ""
@export var cooldown: float = 0.0
@export var stack_size: int = 64
@export var icon_texture: Texture2D = null

func on_hold_tick(_user: Node2D, _delta: float) -> void:
	pass

func on_active_use(_user: Node2D, _target_pos: Vector2) -> bool:
	return true

static func load_item_texture(id: String) -> Texture2D:
	var path_map = {
		"diamond_sword": "res://assets/sprites/diamond_sword.png",
		"rogue_backstab": "res://assets/sprites/rogue_dagger.png",
		"ender_pearl": "res://assets/sprites/ender_pearl.png",
		"golden_apple": "res://assets/sprites/golden_apple.png",
		"bard_sugar": "res://assets/sprites/bard_sugar.png",
		"koth_key": "res://assets/sprites/koth_key.png",
		"player_character": "res://assets/sprites/player_character.png",
		"target_dummy": "res://assets/sprites/target_dummy.png",
		"koth_crate": "res://assets/sprites/koth_crate.png",
		"vote_crate": "res://assets/sprites/vote_crate.png"
	}
	
	if not path_map.has(id):
		return null
		
	var res_path = path_map[id]
	var abs_path = ProjectSettings.globalize_path(res_path)
	
	if FileAccess.file_exists(abs_path):
		var img = Image.load_from_file(abs_path)
		if img and not img.is_empty():
			return ImageTexture.create_from_image(img)
	
	if FileAccess.file_exists(res_path):
		var img2 = Image.load_from_file(res_path)
		if img2 and not img2.is_empty():
			return ImageTexture.create_from_image(img2)
			
	if ResourceLoader.exists(res_path):
		return load(res_path) as Texture2D
		
	return null
