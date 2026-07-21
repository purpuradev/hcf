extends Node

## Handles asynchronous scene transitions and loading

@export var default_transition_duration: float = 0.3

var is_transitioning: bool = false

func _ready() -> void:
	var bus = get_node_or_null("/root/EventBus")
	if bus:
		bus.scene_change_requested.connect(change_scene)

func change_scene(target_scene_path: String) -> void:
	if is_transitioning:
		return
	
	is_transitioning = true
	
	# Load and instantiate new scene
	var error = get_tree().change_scene_to_file(target_scene_path)
	if error != OK:
		push_error("SceneManager: Failed to load scene at path: %s (Error code: %d)" % [target_scene_path, error])
	
	is_transitioning = false
