# LoadingState - Tracks asset loading process state
# Implements data model with validation rules and state transitions

class_name LoadingState
extends RefCounted

# Core properties
@export var current_progress: float = 0.0: set = set_current_progress
@export var assets_loaded: int = 0: set = set_assets_loaded
@export var total_assets: int = 0
@export var is_complete: bool = false
@export var has_error: bool = false
@export var retry_count: int = 0: set = set_retry_count
@export var loading_start_time: float = 0.0
@export var estimated_time_remaining: float = 0.0

# State enumeration
enum State {
	INITIALIZING = 0,
	LOADING = 1,
	COMPLETED = 2,
	ERROR = 3,
	RETRYING = 4,
	FAILED = 5
}

var current_state: State = State.INITIALIZING

func _init():
	loading_start_time = Time.get_time_dict_from_system()["unix"]

# Validation setters
func set_current_progress(value: float) -> void:
	current_progress = clampf(value, 0.0, 1.0)
	_update_completion_status()

func set_assets_loaded(value: int) -> void:
	assets_loaded = maxi(0, mini(value, total_assets))
	_update_completion_status()

func set_retry_count(value: int) -> void:
	retry_count = clampi(value, 0, 3)

# State management methods
func start_loading() -> void:
	current_state = State.LOADING
	has_error = false
	loading_start_time = Time.get_time_dict_from_system()["unix"]

func set_error(error_message: String) -> void:
	current_state = State.ERROR
	has_error = true
	print("Loading error: ", error_message)

func retry_loading() -> void:
	if retry_count < 3:
		retry_count += 1
		current_state = State.RETRYING
		has_error = false
		current_progress = 0.0
		assets_loaded = 0
		print("Retrying loading (attempt ", retry_count, "/3)")
	else:
		current_state = State.FAILED
		print("Loading failed after maximum retries")

func complete_loading() -> void:
	current_state = State.COMPLETED
	is_complete = true
	current_progress = 1.0
	has_error = false

# Helper methods
func _update_completion_status() -> void:
	if total_assets > 0:
		is_complete = (assets_loaded >= total_assets)
		current_progress = float(assets_loaded) / float(total_assets)

func get_progress_percentage() -> int:
	return int(current_progress * 100)

func get_elapsed_time() -> float:
	return Time.get_time_dict_from_system()["unix"] - loading_start_time

func estimate_remaining_time() -> float:
	if current_progress <= 0.0:
		return 0.0

	var elapsed = get_elapsed_time()
	var total_estimated = elapsed / current_progress
	estimated_time_remaining = maxf(0.0, total_estimated - elapsed)
	return estimated_time_remaining

func is_within_timeout(timeout_seconds: float) -> bool:
	return get_elapsed_time() <= timeout_seconds

# Validation methods
func validate() -> bool:
	if current_progress < 0.0 or current_progress > 1.0:
		push_error("Invalid progress value: " + str(current_progress))
		return false

	if assets_loaded < 0 or assets_loaded > total_assets:
		push_error("Invalid assets_loaded: " + str(assets_loaded) + "/" + str(total_assets))
		return false

	if retry_count < 0 or retry_count > 3:
		push_error("Invalid retry_count: " + str(retry_count))
		return false

	return true