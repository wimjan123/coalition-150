# LaunchScreenState - Manages launch screen UI state
# Implements data model with state transitions and validation

class_name LaunchScreenState
extends RefCounted

# Screen state enumeration
enum ScreenState {
	SHOWING_TITLE = 1,
	LOADING = 2,
	TRANSITIONING = 3,
	ERROR = 4,
	COMPLETED = 5
}

# Core properties
@export var current_screen_state: ScreenState = ScreenState.SHOWING_TITLE
@export var title_text: String = "Coalition 150": set = set_title_text
@export var progress_visible: bool = false
@export var can_accept_input: bool = false: set = set_can_accept_input
@export var fade_alpha: float = 0.0: set = set_fade_alpha
@export var timer_remaining: float = 10.0: set = set_timer_remaining

# UI state tracking
var error_message: String = ""
var is_transitioning: bool = false

func _init():
	_update_input_based_on_state()

# Validation setters
func set_title_text(value: String) -> void:
	if value == "":
		push_warning("Title text should not be empty, using default")
		title_text = "Coalition 150"
	else:
		title_text = value

func set_can_accept_input(value: bool) -> void:
	# Input is always disabled during loading states
	if current_screen_state == ScreenState.LOADING or current_screen_state == ScreenState.TRANSITIONING:
		can_accept_input = false
	else:
		can_accept_input = value

func set_fade_alpha(value: float) -> void:
	fade_alpha = clampf(value, 0.0, 1.0)

func set_timer_remaining(value: float) -> void:
	timer_remaining = maxf(0.0, value)

# State transition methods
func transition_to_loading() -> void:
	current_screen_state = ScreenState.LOADING
	progress_visible = true
	can_accept_input = false
	error_message = ""
	print("Launch screen: Transitioning to loading state")

func transition_to_error(message: String) -> void:
	current_screen_state = ScreenState.ERROR
	error_message = message
	progress_visible = false
	can_accept_input = false
	print("Launch screen: Error state - ", message)

func transition_to_transitioning() -> void:
	current_screen_state = ScreenState.TRANSITIONING
	is_transitioning = true
	can_accept_input = false
	progress_visible = false
	print("Launch screen: Starting scene transition")

func transition_to_completed() -> void:
	current_screen_state = ScreenState.COMPLETED
	progress_visible = false
	can_accept_input = false
	is_transitioning = false
	print("Launch screen: Completed successfully")

func return_to_title() -> void:
	current_screen_state = ScreenState.SHOWING_TITLE
	progress_visible = false
	can_accept_input = true
	error_message = ""
	is_transitioning = false
	fade_alpha = 0.0

# Helper methods
func _update_input_based_on_state() -> void:
	match current_screen_state:
		ScreenState.SHOWING_TITLE:
			can_accept_input = true
		ScreenState.LOADING, ScreenState.TRANSITIONING, ScreenState.ERROR:
			can_accept_input = false
		ScreenState.COMPLETED:
			can_accept_input = false

func should_show_progress() -> bool:
	return progress_visible and current_screen_state == ScreenState.LOADING

func should_show_error() -> bool:
	return current_screen_state == ScreenState.ERROR and error_message != ""

func is_in_loading_phase() -> bool:
	return current_screen_state in [ScreenState.LOADING, ScreenState.TRANSITIONING]

func get_state_string() -> String:
	match current_screen_state:
		ScreenState.SHOWING_TITLE: return "Showing Title"
		ScreenState.LOADING: return "Loading"
		ScreenState.TRANSITIONING: return "Transitioning"
		ScreenState.ERROR: return "Error"
		ScreenState.COMPLETED: return "Completed"
		_: return "Unknown"

# Timer management
func update_timer(delta: float) -> void:
	if current_screen_state == ScreenState.LOADING:
		timer_remaining -= delta
		timer_remaining = maxf(0.0, timer_remaining)

func is_timer_expired() -> bool:
	return timer_remaining <= 0.0 and current_screen_state == ScreenState.LOADING

func reset_timer(timeout_duration: float = 10.0) -> void:
	timer_remaining = timeout_duration

# Validation methods
func validate() -> bool:
	if title_text == "":
		push_error("Title text cannot be empty")
		return false

	if fade_alpha < 0.0 or fade_alpha > 1.0:
		push_error("Invalid fade_alpha value: " + str(fade_alpha))
		return false

	if timer_remaining < 0.0:
		push_error("Timer cannot be negative: " + str(timer_remaining))
		return false

	# Business rule: input must be disabled during loading
	if is_in_loading_phase() and can_accept_input:
		push_error("Input must be disabled during loading phases")
		return false

	return true