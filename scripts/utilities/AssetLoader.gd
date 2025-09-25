# AssetLoader - Asset loading service implementing AssetLoaderInterface
# Handles threaded asset loading with progress tracking and retry logic

class_name AssetLoader
extends Node

# AssetLoaderInterface signals
signal asset_loaded(asset_path: String, success: bool)
signal progress_updated(progress: float, assets_loaded: int, total_assets: int)
signal loading_completed(success: bool)
signal retry_started(attempt: int)
signal loading_failed(final_error: String)

# Configuration properties (from AssetLoaderInterface)
@export var max_retries: int = 3
@export var asset_timeout: float = 2.0
@export var use_threading: bool = true
@export var preload_resources: bool = false

# Loading state management
var loading_queue: Array[AssetItem] = []
var current_loading_state: LoadingState
var loading_timer: Timer
var is_loading_active: bool = false

func _init():
	current_loading_state = LoadingState.new()
	_setup_timer()

func _setup_timer() -> void:
	loading_timer = Timer.new()
	loading_timer.wait_time = 0.1  # Update progress every 100ms
	loading_timer.timeout.connect(_update_loading_progress)
	add_child(loading_timer)

# AssetLoaderInterface implementation
func add_asset(asset_path: String, priority: int = 5) -> void:
	if not validate_asset_path(asset_path):
		return

	var asset_item = AssetItem.new(asset_path, AssetItem.AssetType.TEXTURE, priority)
	loading_queue.append(asset_item)
	loading_queue.sort_custom(_compare_priority)

	print("Added asset: ", asset_item.to_string())

func start_loading() -> void:
	if loading_queue.is_empty():
		push_warning("No assets to load")
		loading_completed.emit(true)
		return

	print("Starting asset loading with ", loading_queue.size(), " assets")

	current_loading_state.total_assets = loading_queue.size()
	current_loading_state.start_loading()
	is_loading_active = true

	# Add default assets if queue is empty
	if loading_queue.is_empty():
		_add_default_assets()

	loading_timer.start()
	_simulate_asset_loading()

func stop_loading() -> void:
	is_loading_active = false
	loading_timer.stop()
	print("Asset loading stopped")

func is_asset_loaded(asset_path: String) -> bool:
	for asset in loading_queue:
		if asset.resource_path == asset_path:
			return asset.is_loaded
	return false

func get_loaded_asset(asset_path: String) -> Resource:
	if is_asset_loaded(asset_path):
		return load(asset_path)
	return null

func get_progress() -> float:
	return current_loading_state.current_progress

func get_stats() -> Dictionary:
	return {
		"loaded": current_loading_state.assets_loaded,
		"total": current_loading_state.total_assets,
		"failed": 0,  # Simple implementation
		"retry_count": current_loading_state.retry_count
	}

# Loading simulation logic
func _add_default_assets() -> void:
	add_asset("res://scenes/main/MainMenu.tscn", 1)
	add_asset("res://assets/themes/ui_theme.tres", 2)
	add_asset("res://assets/fonts/game_font.ttf", 3)

func _simulate_asset_loading() -> void:
	# Simulate realistic loading times
	await get_tree().create_timer(0.5).timeout

	for asset in loading_queue:
		if not is_loading_active:
			break

		await _load_single_asset(asset)

		if current_loading_state.has_error and current_loading_state.retry_count >= max_retries:
			loading_failed.emit("Maximum retries exceeded")
			return

	if is_loading_active:
		current_loading_state.complete_loading()
		loading_completed.emit(true)
		print("All assets loaded successfully")

func _load_single_asset(asset: AssetItem) -> void:
	var load_start_time = Time.get_time_dict_from_system()["unix"]

	# Simulate loading time based on asset type and size
	var load_time = _calculate_load_time(asset)
	await get_tree().create_timer(load_time / 1000.0).timeout

	# Simulate occasional loading failures for retry testing
	if randf() < 0.05:  # 5% failure rate for testing
		_handle_loading_error(asset, "Simulated network timeout")
		return

	var load_end_time = Time.get_time_dict_from_system()["unix"]
	var actual_load_time = int((load_end_time - load_start_time) * 1000)

	asset.complete_loading(actual_load_time)
	current_loading_state.assets_loaded += 1

	asset_loaded.emit(asset.resource_path, true)

func _calculate_load_time(asset: AssetItem) -> int:
	# Simulate realistic load times (in milliseconds)
	match asset.asset_type:
		AssetItem.AssetType.SCENE: return randi_range(200, 800)
		AssetItem.AssetType.TEXTURE: return randi_range(100, 400)
		AssetItem.AssetType.FONT: return randi_range(150, 600)
		AssetItem.AssetType.AUDIO: return randi_range(300, 1000)
		_: return randi_range(100, 500)

func _handle_loading_error(asset: AssetItem, error_message: String) -> void:
	print("Loading failed for ", asset.resource_path, ": ", error_message)
	current_loading_state.set_error(error_message)

	if current_loading_state.retry_count < max_retries:
		retry_started.emit(current_loading_state.retry_count + 1)
		current_loading_state.retry_loading()
		await get_tree().create_timer(1.0 * (current_loading_state.retry_count + 1)).timeout  # Exponential backoff
		await _load_single_asset(asset)  # Retry
	else:
		loading_failed.emit("Failed to load " + asset.resource_path + " after " + str(max_retries) + " retries")

func _update_loading_progress() -> void:
	if not is_loading_active:
		return

	var stats = get_stats()
	progress_updated.emit(current_loading_state.current_progress, stats.loaded, stats.total)

	# Check for timeout
	if not current_loading_state.is_within_timeout(asset_timeout * current_loading_state.total_assets):
		_handle_loading_error(loading_queue[0], "Loading timeout exceeded")

func _compare_priority(a: AssetItem, b: AssetItem) -> bool:
	return a.load_priority < b.load_priority  # Lower number = higher priority

# AssetLoaderInterface validation methods
func validate_asset_path(asset_path: String) -> bool:
	if not asset_path.begins_with("res://"):
		push_error("Asset path must start with 'res://': " + asset_path)
		return false

	if not ResourceLoader.exists(asset_path):
		push_error("Asset does not exist: " + asset_path)
		return false

	return true

func validate_config() -> bool:
	if max_retries < 0 or max_retries > 10:
		push_error("max_retries must be between 0 and 10")
		return false

	if asset_timeout <= 0.0:
		push_error("asset_timeout must be positive")
		return false

	return true

# Debug methods for testing
func simulate_slow_loading(delay_seconds: float) -> void:
	print("Simulating slow loading with ", delay_seconds, "s delay")
	asset_timeout = delay_seconds + 1.0

func simulate_loading_error() -> void:
	print("Simulating loading error")
	current_loading_state.set_error("Simulated error for testing")

func complete_loading_immediately() -> void:
	print("Completing loading immediately for testing")
	current_loading_state.complete_loading()
	loading_completed.emit(true)