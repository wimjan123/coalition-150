# SceneManager - Scene transition management autoload service
# Implements SceneManagerInterface for smooth scene transitions

extends Node

# Transition state
var current_transition: Tween
var fade_overlay: ColorRect
var is_transition_active: bool = false
var preloaded_scenes: Dictionary = {}
var current_scene_node: Node

# Configuration properties
var fade_color: Color = Color.BLACK
var default_fade_duration: float = 0.5
var memory_threshold_mb: int = 512
var max_preloaded_scenes: int = 3
var debug_transitions: bool = false
var free_previous_scene: bool = true

# Scene transition signals (from SceneManagerInterface)
signal scene_change_started(from_scene: String, to_scene: String)
signal scene_change_completed(scene_path: String)
signal transition_fade_started()
signal transition_fade_completed()

# Additional transition signals
signal transition_failed(error_message: String)
signal transition_started(from_scene: String, to_scene: String)
signal transition_completed(scene_path: String)
signal scene_preparing(scene_path: String)
signal transition_progress_updated(progress: float)

func _ready():
	set_name("SceneManager")
	_setup_fade_overlay()
	current_scene_node = get_tree().current_scene

func _setup_fade_overlay() -> void:
	# Create fade overlay for transitions
	fade_overlay = ColorRect.new()
	fade_overlay.name = "FadeOverlay"
	fade_overlay.color = fade_color
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_overlay.modulate.a = 0.0

	# Add as CanvasLayer for proper overlay
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100  # High layer to ensure overlay
	canvas_layer.add_child(fade_overlay)
	add_child(canvas_layer)

	# Make overlay cover full screen
	fade_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

# SceneManagerInterface implementation
func transition_to_scene(scene_path: String, fade_duration: float = 1.0) -> void:
	if is_transition_active:
		push_warning("Transition already in progress, ignoring request")
		return

	if not validate_scene_path(scene_path):
		transition_failed.emit("Invalid scene path: " + scene_path)
		return

	print("Starting transition to: ", scene_path)
	is_transition_active = true

	var from_scene = get_current_scene_path()
	transition_started.emit(from_scene, scene_path)

	await _execute_fade_transition(scene_path, fade_duration)

func switch_scene_immediate(scene_path: String) -> void:
	if not validate_scene_path(scene_path):
		transition_failed.emit("Invalid scene path: " + scene_path)
		return

	print("Immediate scene switch to: ", scene_path)

	var from_scene = get_current_scene_path()
	transition_started.emit(from_scene, scene_path)

	_change_scene_immediate(scene_path)

func get_current_scene_path() -> String:
	if current_scene_node and current_scene_node.scene_file_path:
		return current_scene_node.scene_file_path
	return ""

func is_transitioning() -> bool:
	return is_transition_active

func preload_scene(scene_path: String) -> void:
	if preloaded_scenes.has(scene_path):
		return  # Already preloaded

	if not validate_scene_path(scene_path):
		push_error("Cannot preload invalid scene: " + scene_path)
		return

	print("Preloading scene: ", scene_path)
	scene_preparing.emit(scene_path)

	var resource = load(scene_path)
	if resource is PackedScene:
		preloaded_scenes[scene_path] = resource
		print("Scene preloaded: ", scene_path)
	else:
		push_error("Failed to preload scene: " + scene_path)

func clear_preloaded_scenes() -> void:
	print("Clearing ", preloaded_scenes.size(), " preloaded scenes")
	preloaded_scenes.clear()

func cancel_transition() -> void:
	if is_transition_active and current_transition:
		current_transition.kill()
		_reset_transition_state()
		print("Transition cancelled")

# Transition execution
func _execute_fade_transition(scene_path: String, duration: float) -> void:
	# Phase 1: Fade out
	current_transition = create_tween()
	current_transition.tween_method(_update_transition_progress, 0.0, 0.5, duration / 2.0)
	current_transition.tween_property(fade_overlay, "modulate:a", 1.0, duration / 2.0)

	await current_transition.finished

	if not is_transition_active:
		return  # Cancelled

	# Phase 2: Change scene
	_change_scene_immediate(scene_path)

	# Phase 3: Fade in
	current_transition = create_tween()
	current_transition.tween_method(_update_transition_progress, 0.5, 1.0, duration / 2.0)
	current_transition.tween_property(fade_overlay, "modulate:a", 0.0, duration / 2.0)

	await current_transition.finished

	_complete_transition(scene_path)

func _change_scene_immediate(scene_path: String) -> void:
	var new_scene: PackedScene

	# Use preloaded scene if available
	if preloaded_scenes.has(scene_path):
		new_scene = preloaded_scenes[scene_path]
		print("Using preloaded scene: ", scene_path)
	else:
		new_scene = load(scene_path)

	if not new_scene:
		transition_failed.emit("Failed to load scene: " + scene_path)
		_reset_transition_state()
		return

	# Free current scene if configured
	if free_previous_scene and current_scene_node:
		current_scene_node.queue_free()

	# Instantiate and set new scene
	var new_scene_instance = new_scene.instantiate()
	get_tree().current_scene = new_scene_instance
	get_tree().root.add_child(new_scene_instance)
	current_scene_node = new_scene_instance

	print("Scene changed to: ", scene_path)

func _complete_transition(scene_path: String) -> void:
	_reset_transition_state()
	transition_completed.emit(scene_path)
	print("Transition completed successfully to: ", scene_path)

	# Clean up preloaded scenes if needed
	check_memory_usage()

func _reset_transition_state() -> void:
	is_transition_active = false
	current_transition = null

func _update_transition_progress(progress: float) -> void:
	transition_progress_updated.emit(progress)

# Memory management
func check_memory_usage() -> void:
	var memory_usage = OS.get_static_memory_usage()
	var total_mb = memory_usage / (1024 * 1024)

	if total_mb > memory_threshold_mb:
		print("Memory usage high (", total_mb, "MB), clearing preloaded scenes")
		clear_preloaded_scenes()

	if preloaded_scenes.size() > max_preloaded_scenes:
		print("Too many preloaded scenes (", preloaded_scenes.size(), "), clearing oldest")
		clear_preloaded_scenes()

# Validation methods
func validate_scene_path(scene_path: String) -> bool:
	if scene_path.is_empty():
		return false

	if not scene_path.begins_with("res://"):
		return false

	if not scene_path.ends_with(".tscn"):
		return false

	return ResourceLoader.exists(scene_path)

# Lifecycle callbacks (can be overridden)
func _on_transition_begin(from_scene: String, to_scene: String) -> void:
	if debug_transitions:
		_log_transition_timing(from_scene, to_scene, default_fade_duration)

func _log_transition_timing(from_scene: String, to_scene: String, duration: float) -> void:
	var timestamp: String = Time.get_datetime_string_from_system()
	print("[%s] Scene transition: %s -> %s (duration: %.2fs)" % [timestamp, from_scene, to_scene, duration])

func _on_transition_complete(scene_path: String) -> void:
	pass  # Override for custom logic

func _on_transition_failed(error_message: String) -> void:
	push_error("Scene transition failed: " + error_message)

# Debug and testing methods
func simulate_transition_failure() -> void:
	transition_failed.emit("Simulated transition failure for testing")

func get_fade_overlay() -> ColorRect:
	return fade_overlay

func force_cleanup() -> void:
	clear_preloaded_scenes()
	if current_transition:
		current_transition.kill()
	_reset_transition_state()

# Player Creation Flow Implementation - SceneManagerInterface methods
var current_character: CharacterData = null
var save_system: SaveSystem = null

func _init_save_system() -> void:
	if not save_system:
		save_system = SaveSystem.new()

func change_scene_to_player_selection() -> void:
	transition_to_scene("res://scenes/player/CharacterPartySelection.tscn")

func change_scene_to_player_creation() -> void:
	transition_to_scene("res://scenes/player/CharacterPartyCreation.tscn")

func change_scene_to_interview() -> void:
	transition_to_scene("res://scenes/player/MediaInterview.tscn")

func change_scene_to_main_menu() -> void:
	transition_to_scene("res://scenes/main/MainMenu.tscn")

func change_scene_to_main_game() -> void:
	# TODO: Implement main game scene when available
	push_warning("Main game scene not yet implemented")
	transition_to_scene("res://scenes/main/MainMenu.tscn")

func set_transition_duration(duration: float) -> void:
	default_fade_duration = duration

func has_save_data() -> bool:
	_init_save_system()
	return save_system.has_save_data()

func get_available_characters() -> Array[CharacterData]:
	_init_save_system()
	var player_data: PlayerData = save_system.load_player_data()
	if player_data:
		return player_data.characters
	return []

func set_current_character(character: CharacterData) -> void:
	current_character = character

func get_current_character() -> CharacterData:
	return current_character

func clear_session() -> void:
	current_character = null

func validate_scene_transition(from_scene: String, to_scene: String) -> bool:
	# Define valid transition paths for player creation flow
	var valid_transitions: Dictionary = {
		"res://scenes/main/MainMenu.tscn": [
			"res://scenes/player/CharacterPartySelection.tscn"
		],
		"res://scenes/player/CharacterPartySelection.tscn": [
			"res://scenes/player/CharacterPartyCreation.tscn",
			"res://scenes/main/MainMenu.tscn"
		],
		"res://scenes/player/CharacterPartyCreation.tscn": [
			"res://scenes/player/MediaInterview.tscn",
			"res://scenes/player/CharacterPartySelection.tscn"
		],
		"res://scenes/player/MediaInterview.tscn": [
			"res://scenes/main/MainMenu.tscn",
			"res://scenes/player/CharacterPartyCreation.tscn"
		]
	}

	if from_scene in valid_transitions:
		return to_scene in valid_transitions[from_scene]

	return true  # Allow other transitions by default