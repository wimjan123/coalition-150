# LaunchScreen - Main launch screen controller implementing LaunchScreenInterface
# Manages the complete launch screen experience with loading and transitions

extends Control
class_name LaunchScreen

# Interface compliance - signals
signal loading_started()
signal progress_updated(progress: float)
signal loading_completed()
signal transition_requested(target_scene: String)

# Node references
@onready var title_label: Label = $TitleLabel
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var loading_timer: Timer = $LoadingTimer
@onready var fade_overlay: ColorRect = $FadeOverlay

# State management
var launch_screen_state: LaunchScreenState
var loading_state: LoadingState
var asset_loader: AssetLoader
var transition_config: TransitionConfig

# Loading control
var is_loading_active: bool = false
var is_loading_complete: bool = false
var input_was_processed: bool = false
var has_error: bool = false
var retry_count: int = 0

func _ready():
	_initialize_launch_screen()
	_setup_ui()
	_connect_signals()
	_start_loading_sequence()

func _initialize_launch_screen() -> void:
	print("LaunchScreen: Initializing...")

	# Initialize state objects
	launch_screen_state = LaunchScreenState.new()
	loading_state = LoadingState.new()
	asset_loader = AssetLoader.new()
	transition_config = TransitionConfig.create_launch_to_menu()

	# Configure input blocking
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process_input(false)

	print("LaunchScreen: State objects initialized")

func _setup_ui() -> void:
	# Configure title
	title_label.text = launch_screen_state.title_text

	# Configure progress bar
	progress_bar.value = 0.0
	progress_bar.visible = false

	# Configure fade overlay
	fade_overlay.modulate.a = 0.0
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Apply theme
	if theme:
		print("LaunchScreen: Theme applied successfully")

func _connect_signals() -> void:
	# T027: Connect AssetLoader signals to LaunchScreen progress updates
	asset_loader.progress_updated.connect(_on_progress_updated)
	asset_loader.loading_completed.connect(_on_loading_completed)
	asset_loader.loading_failed.connect(_on_loading_failed)
	asset_loader.retry_started.connect(_on_retry_started)

	# T028: Connect LaunchScreen transition signals to SceneManager
	# (handled in _start_scene_transition method)

	# T029: Configure timeout Timer and retry mechanism
	loading_timer.wait_time = 10.0  # 10-second timeout as per spec
	loading_timer.timeout.connect(_on_loading_timeout)

	# T030: Set up MainMenu scene as transition target in SceneManager
	if SceneManager:
		SceneManager.transition_completed.connect(_on_transition_completed)
		SceneManager.transition_failed.connect(_on_transition_failed)
		SceneManager.preload_scene("res://scenes/main/MainMenu.tscn")

	print("LaunchScreen: All signal connections and integration complete")

# LaunchScreenInterface implementation
func start_loading() -> void:
	if is_loading_active:
		return

	print("LaunchScreen: Starting loading sequence")

	is_loading_active = true
	launch_screen_state.transition_to_loading()
	progress_bar.visible = true

	# Start timeout timer
	loading_timer.start()

	# Add assets to loader
	asset_loader.add_asset("res://scenes/main/MainMenu.tscn", 1)
	asset_loader.add_asset("res://assets/themes/ui_theme.tres", 2)

	# Begin loading
	asset_loader.start_loading()
	loading_started.emit()

func update_progress(progress: float) -> void:
	var clamped_progress = clampf(progress, 0.0, 1.0)
	progress_bar.value = clamped_progress * 100.0
	launch_screen_state.fade_alpha = clamped_progress * 0.1  # Subtle fade during loading

	progress_updated.emit(clamped_progress)

func show_error(error_message: String) -> void:
	print("LaunchScreen: Error - ", error_message)

	has_error = true
	launch_screen_state.transition_to_error(error_message)

	# Visual feedback for error state
	title_label.modulate = Color.RED
	progress_bar.modulate = Color.RED

func retry_loading() -> void:
	if retry_count >= 3:
		_handle_max_retries_exceeded()
		return

	retry_count += 1
	print("LaunchScreen: Retrying loading (attempt ", retry_count, "/3)")

	# Reset error state
	has_error = false
	title_label.modulate = Color.WHITE
	progress_bar.modulate = Color.WHITE

	# Reset progress
	update_progress(0.0)

	# Restart loading with exponential backoff
	var delay = 1.0 * retry_count
	await get_tree().create_timer(delay).timeout

	start_loading()

# Signal handlers
func _on_progress_updated(progress: float, assets_loaded: int, total_assets: int) -> void:
	update_progress(progress)
	print("LaunchScreen: Progress ", int(progress * 100), "% (", assets_loaded, "/", total_assets, ")")

func _on_loading_completed(success: bool) -> void:
	if not success:
		show_error("Loading failed")
		return

	print("LaunchScreen: Loading completed successfully")

	is_loading_complete = true
	loading_timer.stop()

	launch_screen_state.transition_to_completed()
	loading_completed.emit()

	# Start transition after brief pause
	await get_tree().create_timer(0.5).timeout
	_start_scene_transition()

func _on_loading_failed(error_message: String) -> void:
	show_error(error_message)

	if retry_count < 3:
		await get_tree().create_timer(2.0).timeout  # Brief pause before retry
		retry_loading()
	else:
		_handle_max_retries_exceeded()

func _on_retry_started(attempt: int) -> void:
	print("LaunchScreen: Retry started, attempt: ", attempt)

func _on_loading_timeout() -> void:
	if is_loading_complete:
		return

	print("LaunchScreen: Loading timeout exceeded (10 seconds)")

	# T029: Configure timeout Timer and retry mechanism implementation
	show_error("Loading timeout - retrying...")

	# Stop current loading
	asset_loader.stop_loading()

	# Reset timer for next attempt
	launch_screen_state.reset_timer(10.0)

	# Attempt automatic retry with exponential backoff
	retry_loading()

func _on_transition_completed(scene_path: String) -> void:
	print("LaunchScreen: Scene transition completed to: ", scene_path)

func _on_transition_failed(error_message: String) -> void:
	print("LaunchScreen: Scene transition failed: ", error_message)
	show_error("Transition failed: " + error_message)

# Scene transition
func _start_scene_transition() -> void:
	if not transition_config.can_transition():
		show_error("Invalid transition configuration")
		return

	print("LaunchScreen: Starting scene transition")

	launch_screen_state.transition_to_transitioning()
	transition_requested.emit(transition_config.target_scene_path)

	# Execute fade transition
	await _execute_fade_transition()

	# Request scene change
	if SceneManager:
		SceneManager.transition_to_scene(
			transition_config.target_scene_path,
			transition_config.fade_duration
		)

func _execute_fade_transition() -> void:
	var tween = create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 1.0, transition_config.fade_duration / 2.0)
	await tween.finished

# Error handling
func _handle_max_retries_exceeded() -> void:
	print("LaunchScreen: Maximum retries exceeded, showing permanent error")

	show_error("Loading failed after 3 attempts")

	# Display retry instructions (in a full implementation)
	var error_label = Label.new()
	error_label.text = "Please restart the application"
	error_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(error_label)

# Input handling (blocked during loading)
func _input(event: InputEvent) -> void:
	input_was_processed = false  # Always false during loading

	# Block all input during loading states
	if launch_screen_state.is_in_loading_phase():
		get_viewport().set_input_as_handled()
		return

# Automatic loading start
func _start_loading_sequence() -> void:
	print("LaunchScreen: Auto-starting loading sequence")

	# Brief delay to ensure UI is ready
	await get_tree().process_frame
	await get_tree().create_timer(0.5).timeout

	start_loading()

# Debug and testing methods
func simulate_slow_loading(delay_seconds: float) -> void:
	print("LaunchScreen: Simulating slow loading (", delay_seconds, "s)")
	asset_loader.simulate_slow_loading(delay_seconds)

func simulate_loading_error() -> void:
	print("LaunchScreen: Simulating loading error")
	asset_loader.simulate_loading_error()

func simulate_successful_retry() -> void:
	print("LaunchScreen: Simulating successful retry")
	# Reset error state and complete loading
	has_error = false
	title_label.modulate = Color.WHITE
	progress_bar.modulate = Color.WHITE
	asset_loader.complete_loading_immediately()

func complete_loading_immediately() -> void:
	print("LaunchScreen: Completing loading immediately for testing")
	asset_loader.complete_loading_immediately()

# Utility methods
func get_progress() -> float:
	return progress_bar.value / 100.0

func get_retry_count() -> int:
	return retry_count

func is_retrying() -> bool:
	return has_error and retry_count > 0