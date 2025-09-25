# LaunchScreen Scene Contract
# Defines the public interface for the launch screen scene

class_name LaunchScreenInterface
extends Control

# SIGNALS - External communication interface

## Emitted when loading process begins
signal loading_started()

## Emitted when loading progress updates
## @param progress: float - Progress percentage (0.0 to 1.0)
signal loading_progress_updated(progress: float)

## Emitted when loading completes successfully
signal loading_completed()

## Emitted when loading fails after all retries
signal loading_failed(error_message: String)

## Emitted when scene transition begins
signal transition_started(target_scene: String)

## Emitted when fade transition completes
signal transition_completed()

# PUBLIC METHODS - Scene control interface

## Initialize the launch screen with configuration
## @param config: LaunchConfig - Loading and display configuration
func initialize(config: LaunchConfig) -> void:
	assert(false, "Must be implemented by concrete class")

## Start the loading process
func start_loading() -> void:
	assert(false, "Must be implemented by concrete class")

## Stop loading and clean up resources
func stop_loading() -> void:
	assert(false, "Must be implemented by concrete class")

## Trigger scene transition to target
## @param scene_path: String - Path to target scene
func transition_to_scene(scene_path: String) -> void:
	assert(false, "Must be implemented by concrete class")

## Show error message with retry option
## @param message: String - Error message to display
func show_error(message: String) -> void:
	assert(false, "Must be implemented by concrete class")

# PROPERTIES - Configuration interface

## Maximum loading timeout in seconds
@export var timeout_seconds: float = 10.0

## Whether to show progress bar
@export var show_progress_bar: bool = true

## Title text to display
@export var title_text: String = "Coalition 150"

## Target scene for transition
@export var target_scene_path: String = "res://scenes/main/MainMenu.tscn"

## Fade transition duration
@export var fade_duration: float = 1.0

# VALIDATION RULES

## Validates scene configuration before use
func validate_configuration() -> bool:
	if timeout_seconds <= 0:
		push_error("timeout_seconds must be positive")
		return false

	if title_text.is_empty():
		push_error("title_text cannot be empty")
		return false

	if not ResourceLoader.exists(target_scene_path):
		push_error("target_scene_path does not exist: " + target_scene_path)
		return false

	if fade_duration < 0.1:
		push_error("fade_duration must be at least 0.1 seconds")
		return false

	return true

## Required nodes that must exist in scene hierarchy
func _validate_scene_structure() -> bool:
	var required_nodes = [
		"Background",     # ColorRect for background
		"TitleLabel",     # Label for game title
		"ProgressBar",    # ProgressBar for loading
		"LoadingTimer",   # Timer for timeout
		"FadeOverlay"     # ColorRect for transitions
	]

	for node_name in required_nodes:
		if not has_node(node_name):
			push_error("Required node missing: " + node_name)
			return false

	return true