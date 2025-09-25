# TransitionConfig - Configuration for scene transition effects
# Implements data model with validation and configuration helpers

class_name TransitionConfig
extends RefCounted

# Transition type enumeration
enum TransitionType {
	FADE_OUT_IN = 1,
	IMMEDIATE = 2
}

# Core properties
@export var fade_duration: float = 1.0: set = set_fade_duration
@export var fade_color: Color = Color.BLACK: set = set_fade_color
@export var target_scene_path: String = "": set = set_target_scene_path
@export var transition_type: TransitionType = TransitionType.FADE_OUT_IN

func _init(duration: float = 1.0, color: Color = Color.BLACK, target: String = ""):
	fade_duration = duration
	fade_color = color
	target_scene_path = target

# Validation setters
func set_fade_duration(value: float) -> void:
	if value <= 0.0:
		push_error("Fade duration must be positive: " + str(value))
		fade_duration = 1.0  # Default fallback
	else:
		fade_duration = value

	if value > 5.0:
		push_warning("Fade duration > 5.0 seconds may feel slow to users: " + str(value))

func set_fade_color(value: Color) -> void:
	fade_color = value
	# Ensure alpha is 1.0 for proper fade effect
	if fade_color.a != 1.0:
		push_warning("Fade color alpha should be 1.0 for proper fade effect, got: " + str(fade_color.a))
		fade_color.a = 1.0

func set_target_scene_path(value: String) -> void:
	if value != "" and not validate_target_scene(value):
		push_error("Invalid target scene path: " + value)
		return
	target_scene_path = value

# Configuration helper methods
func set_fade_to_black(duration: float = 1.0) -> void:
	fade_duration = duration
	fade_color = Color.BLACK
	transition_type = TransitionType.FADE_OUT_IN

func set_fade_to_white(duration: float = 1.0) -> void:
	fade_duration = duration
	fade_color = Color.WHITE
	transition_type = TransitionType.FADE_OUT_IN

func set_immediate_transition(target: String = "") -> void:
	transition_type = TransitionType.IMMEDIATE
	fade_duration = 0.0
	if target != "":
		target_scene_path = target

# Validation methods
func validate_target_scene(path: String) -> bool:
	if path == "":
		return true  # Empty is valid (no transition)

	if not path.begins_with("res://"):
		return false

	if not path.ends_with(".tscn"):
		return false

	# Check if file exists (optional validation)
	return ResourceLoader.exists(path)

func validate() -> bool:
	if fade_duration <= 0.0:
		push_error("Invalid fade_duration: " + str(fade_duration))
		return false

	if target_scene_path != "" and not validate_target_scene(target_scene_path):
		push_error("Invalid target_scene_path: " + target_scene_path)
		return false

	if fade_color.a != 1.0:
		push_warning("Fade color alpha should be 1.0, got: " + str(fade_color.a))
		return false

	return true

# Utility methods
func get_transition_type_string() -> String:
	match transition_type:
		TransitionType.FADE_OUT_IN: return "Fade Out/In"
		TransitionType.IMMEDIATE: return "Immediate"
		_: return "Unknown"

func get_fade_color_string() -> String:
	if fade_color == Color.BLACK:
		return "Black"
	elif fade_color == Color.WHITE:
		return "White"
	else:
		return "Custom (%s)" % fade_color

func is_immediate_transition() -> bool:
	return transition_type == TransitionType.IMMEDIATE

func get_effective_duration() -> float:
	if is_immediate_transition():
		return 0.0
	return fade_duration

# Scene management helpers
func can_transition() -> bool:
	return target_scene_path != "" and validate_target_scene(target_scene_path)

func get_target_scene_name() -> String:
	if target_scene_path == "":
		return "None"
	return target_scene_path.get_file().get_basename()

func get_transition_description() -> String:
	return "[%s] %s → %s (%.1fs)" % [
		get_transition_type_string(),
		get_fade_color_string(),
		get_target_scene_name(),
		get_effective_duration()
	]

# Preset configurations
static func create_launch_to_menu() -> TransitionConfig:
	var config = TransitionConfig.new()
	config.set_fade_to_black(1.0)
	config.target_scene_path = "res://scenes/main/MainMenu.tscn"
	return config

static func create_error_recovery() -> TransitionConfig:
	var config = TransitionConfig.new()
	config.set_immediate_transition()
	return config