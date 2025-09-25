# SceneManager Service Contract
# Defines the interface for scene transition management

class_name SceneManagerInterface
extends Node

# SIGNALS - Scene transition events

## Emitted when scene transition begins
## @param from_scene: String - Current scene path
## @param to_scene: String - Target scene path
signal transition_started(from_scene: String, to_scene: String)

## Emitted when transition progress updates
## @param progress: float - Transition progress (0.0 to 1.0)
signal transition_progress_updated(progress: float)

## Emitted when scene transition completes
## @param scene_path: String - New active scene path
signal transition_completed(scene_path: String)

## Emitted when scene transition fails
## @param error_message: String - Description of failure
signal transition_failed(error_message: String)

## Emitted when scene is being prepared for transition
## @param scene_path: String - Scene being prepared
signal scene_preparing(scene_path: String)

# PUBLIC METHODS - Scene management interface

## Transition to a new scene with fade effect
## @param scene_path: String - Target scene resource path
## @param fade_duration: float - Duration of fade transition
func transition_to_scene(scene_path: String, fade_duration: float = 1.0) -> void:
	assert(false, "Must be implemented by concrete class")

## Immediately switch scenes without transition
## @param scene_path: String - Target scene resource path
func switch_scene_immediate(scene_path: String) -> void:
	assert(false, "Must be implemented by concrete class")

## Get current active scene path
## @return String - Path of currently loaded scene
func get_current_scene_path() -> String:
	assert(false, "Must be implemented by concrete class")
	return ""

## Check if transition is currently in progress
## @return bool - True if transition active
func is_transitioning() -> bool:
	assert(false, "Must be implemented by concrete class")
	return false

## Preload scene for faster transitions
## @param scene_path: String - Scene to preload
func preload_scene(scene_path: String) -> void:
	assert(false, "Must be implemented by concrete class")

## Clear preloaded scenes from memory
func clear_preloaded_scenes() -> void:
	assert(false, "Must be implemented by concrete class")

## Cancel ongoing transition
func cancel_transition() -> void:
	assert(false, "Must be implemented by concrete class")

# TRANSITION CONFIGURATION

## Transition types available
enum TransitionType {
	FADE_BLACK = 0,      ## Fade to black then fade in
	FADE_WHITE = 1,      ## Fade to white then fade in
	SLIDE_LEFT = 2,      ## Slide transition to left
	SLIDE_RIGHT = 3,     ## Slide transition to right
	IMMEDIATE = 4        ## No transition effect
}

## Default transition settings
@export var default_transition_type: TransitionType = TransitionType.FADE_BLACK
@export var default_fade_duration: float = 1.0
@export var fade_color: Color = Color.BLACK
@export var preload_next_scene: bool = true

# SCENE VALIDATION METHODS

## Validate scene path exists and is loadable
## @param scene_path: String - Path to validate
## @return bool - True if scene is valid
func validate_scene_path(scene_path: String) -> bool:
	if not scene_path.begins_with("res://"):
		push_error("Scene path must start with 'res://': " + scene_path)
		return false

	if not scene_path.ends_with(".tscn"):
		push_error("Scene path must end with '.tscn': " + scene_path)
		return false

	if not ResourceLoader.exists(scene_path):
		push_error("Scene file does not exist: " + scene_path)
		return false

	# Validate it's actually a PackedScene
	var resource = ResourceLoader.load(scene_path)
	if not resource is PackedScene:
		push_error("Resource is not a PackedScene: " + scene_path)
		return false

	return true

## Validate transition configuration
## @return bool - True if configuration is valid
func validate_transition_config() -> bool:
	if default_fade_duration < 0.1:
		push_error("default_fade_duration must be at least 0.1 seconds")
		return false

	if default_fade_duration > 5.0:
		push_warning("default_fade_duration > 5.0 seconds may feel slow to users")

	return true

# SCENE LIFECYCLE METHODS

## Called before scene transition begins
## @param from_scene: String - Current scene path
## @param to_scene: String - Target scene path
func _on_transition_begin(from_scene: String, to_scene: String) -> void:
	# Override in implementation to handle transition start
	pass

## Called during transition progress
## @param progress: float - Current progress (0.0 to 1.0)
func _on_transition_progress(progress: float) -> void:
	# Override in implementation to handle progress updates
	pass

## Called when transition completes successfully
## @param scene_path: String - New active scene path
func _on_transition_complete(scene_path: String) -> void:
	# Override in implementation to handle completion
	pass

## Called if transition fails
## @param error_message: String - Error description
func _on_transition_failed(error_message: String) -> void:
	# Override in implementation to handle failures
	pass

# PERFORMANCE CONSIDERATIONS

## Maximum number of preloaded scenes in memory
@export var max_preloaded_scenes: int = 3

## Whether to free previous scene immediately
@export var free_previous_scene: bool = true

## Memory usage threshold for automatic cleanup
@export var memory_threshold_mb: float = 100.0

## Check memory usage and cleanup if needed
func check_memory_usage() -> void:
	# Implementation should monitor memory and cleanup if needed
	pass

# DEBUGGING SUPPORT

## Enable debug logging for transitions
@export var debug_transitions: bool = false

## Log transition timing information
func _log_transition_timing(from_scene: String, to_scene: String, duration: float) -> void:
	if debug_transitions:
		print("Scene transition: %s → %s (%.2fs)" % [from_scene, to_scene, duration])
