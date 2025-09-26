# GameManager - Global game state management autoload
# Manages overall game state, settings, and coordination between systems

extends Node

# Game state tracking
enum AppState {
	INITIALIZING = 0,
	LAUNCH_SCREEN = 1,
	MAIN_MENU = 2,
	IN_GAME = 3,
	PAUSED = 4,
	SETTINGS = 5
}

var current_game_state: AppState = AppState.INITIALIZING
var previous_game_state: AppState = AppState.INITIALIZING

# Performance tracking
var performance_metrics: Dictionary = {
	"fps_current": 0.0,
	"fps_average": 0.0,
	"memory_usage_mb": 0.0,
	"scene_load_time_ms": 0.0
}

# Game settings
var game_settings: Dictionary = {
	"window_fullscreen": false,
	"audio_master_volume": 1.0,
	"debug_mode": false
}

# Loading management
var loading_timeout_seconds: float = 10.0
var max_loading_retries: int = 3
var is_loading_active: bool = false

signal game_state_changed(new_state: AppState, old_state: AppState)
signal performance_warning(metric: String, value: float)
signal loading_timeout_exceeded()

func _ready():
	set_name("GameManager")
	set_process(true)
	_initialize_game_manager()

func _initialize_game_manager() -> void:
	print("GameManager: Initializing...")

	# Load game settings
	_load_game_settings()

	# Connect to scene manager signals
	if SceneManager:
		SceneManager.transition_completed.connect(_on_scene_transition_completed)
		SceneManager.transition_failed.connect(_on_scene_transition_failed)

	# Start performance monitoring
	_start_performance_monitoring()

	# Transition to launch screen state
	change_game_state(AppState.LAUNCH_SCREEN)

	print("GameManager: Initialization complete")

func _process(_delta: float) -> void:
	_update_performance_metrics()

# Game state management
func change_game_state(new_state: AppState) -> void:
	if new_state == current_game_state:
		return

	var old_state = current_game_state
	previous_game_state = old_state
	current_game_state = new_state

	print("GameManager: State change: ", _get_state_string(old_state), " → ", _get_state_string(new_state))

	game_state_changed.emit(new_state, old_state)
	_handle_state_transition(new_state, old_state)

func get_current_state() -> AppState:
	return current_game_state

func get_previous_state() -> AppState:
	return previous_game_state

func can_transition_to(target_state: AppState) -> bool:
	# Define valid state transitions
	match current_game_state:
		AppState.INITIALIZING:
			return target_state == AppState.LAUNCH_SCREEN
		AppState.LAUNCH_SCREEN:
			return target_state in [AppState.MAIN_MENU, AppState.INITIALIZING]
		AppState.MAIN_MENU:
			return target_state in [AppState.IN_GAME, AppState.SETTINGS, AppState.LAUNCH_SCREEN]
		AppState.IN_GAME:
			return target_state in [AppState.PAUSED, AppState.MAIN_MENU]
		AppState.PAUSED:
			return target_state in [AppState.IN_GAME, AppState.MAIN_MENU]
		AppState.SETTINGS:
			return target_state in [AppState.MAIN_MENU, AppState.IN_GAME]
		_:
			return false

# Loading management
func start_game_loading() -> void:
	if is_loading_active:
		push_warning("Loading already active")
		return

	print("GameManager: Starting game loading sequence")
	is_loading_active = true

	# Start loading timeout timer
	var timeout_timer = get_tree().create_timer(loading_timeout_seconds)
	timeout_timer.timeout.connect(_on_loading_timeout)

func complete_game_loading() -> void:
	if not is_loading_active:
		return

	print("GameManager: Game loading completed")
	is_loading_active = false

func _on_loading_timeout() -> void:
	if is_loading_active:
		print("GameManager: Loading timeout exceeded")
		loading_timeout_exceeded.emit()
		is_loading_active = false

# Performance monitoring
func _start_performance_monitoring() -> void:
	var performance_timer = Timer.new()
	performance_timer.wait_time = 1.0  # Update every second
	performance_timer.timeout.connect(_update_performance_metrics)
	performance_timer.autostart = true
	add_child(performance_timer)

func _update_performance_metrics() -> void:
	# FPS monitoring
	performance_metrics.fps_current = Engine.get_frames_per_second()

	# Memory monitoring (using available Godot 4.5 methods)
	var memory_usage = OS.get_static_memory_usage()
	performance_metrics.memory_usage_mb = memory_usage / (1024 * 1024)

	# Performance warnings
	if performance_metrics.fps_current < 55.0:
		performance_warning.emit("fps", performance_metrics.fps_current)

	if performance_metrics.memory_usage_mb > 200.0:
		performance_warning.emit("memory", performance_metrics.memory_usage_mb)

func get_performance_metrics() -> Dictionary:
	return performance_metrics.duplicate()

# Settings management
func _load_game_settings() -> void:
	# In a full implementation, this would load from a config file
	print("GameManager: Loading game settings")
	game_settings["debug_mode"] = OS.is_debug_build()

func save_game_settings() -> void:
	# In a full implementation, this would save to a config file
	print("GameManager: Saving game settings")

func get_setting(key: String, default_value = null):
	return game_settings.get(key, default_value)

func set_setting(key: String, value) -> void:
	game_settings[key] = value
	print("GameManager: Setting updated: ", key, " = ", value)

# State transition handlers
func _handle_state_transition(new_state: AppState, old_state: AppState) -> void:
	match new_state:
		AppState.LAUNCH_SCREEN:
			_handle_launch_screen_entry()
		AppState.MAIN_MENU:
			_handle_main_menu_entry()
		AppState.IN_GAME:
			_handle_game_entry()

func _handle_launch_screen_entry() -> void:
	print("GameManager: Entering launch screen state")
	start_game_loading()

func _handle_main_menu_entry() -> void:
	print("GameManager: Entering main menu state")
	complete_game_loading()

func _handle_game_entry() -> void:
	print("GameManager: Entering game state")

# Scene manager integration
func _on_scene_transition_completed(scene_path: String) -> void:
	print("GameManager: Scene transition completed to: ", scene_path)

	# Update game state based on new scene
	if scene_path.contains("MainMenu"):
		change_game_state(AppState.MAIN_MENU)
	elif scene_path.contains("LaunchScreen"):
		change_game_state(AppState.LAUNCH_SCREEN)

func _on_scene_transition_failed(error_message: String) -> void:
	push_error("GameManager: Scene transition failed: " + error_message)

# Utility methods
func _get_state_string(state: AppState) -> String:
	match state:
		AppState.INITIALIZING: return "Initializing"
		AppState.LAUNCH_SCREEN: return "Launch Screen"
		AppState.MAIN_MENU: return "Main Menu"
		AppState.IN_GAME: return "In Game"
		AppState.PAUSED: return "Paused"
		AppState.SETTINGS: return "Settings"
		_: return "Unknown"

func is_in_game() -> bool:
	return current_game_state == AppState.IN_GAME

func is_loading() -> bool:
	return is_loading_active or current_game_state == AppState.LAUNCH_SCREEN

# Debug methods
func debug_print_state() -> void:
	print("GameManager Debug State:")
	print("  Current State: ", _get_state_string(current_game_state))
	print("  Previous State: ", _get_state_string(previous_game_state))
	print("  Loading Active: ", is_loading_active)
	print("  Performance: ", performance_metrics)

func simulate_performance_issue() -> void:
	print("GameManager: Simulating performance issue")
	performance_warning.emit("fps", 30.0)
