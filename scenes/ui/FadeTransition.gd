# FadeTransition - Tween-based fade transition effects
# Provides smooth fade in/out transitions for scene changes

extends CanvasLayer
class_name FadeTransition

# Node references
@onready var fade_rect: ColorRect = $FadeRect
var transition_tween: Tween

# Configuration
@export var default_duration: float = 1.0
@export var fade_color: Color = Color.BLACK

# State
var is_transition_active: bool = false
var current_alpha: float = 0.0

signal fade_in_started()
signal fade_in_completed()
signal fade_out_started()
signal fade_out_completed()
signal transition_completed()

func _ready():
	_initialize_fade_transition()

func _initialize_fade_transition() -> void:
	print("FadeTransition: Initializing fade transition system")

	# Ensure proper layering
	layer = 100

	# Configure fade rectangle
	fade_rect.color = fade_color
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.modulate.a = 0.0

	# Ensure full screen coverage
	fade_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	print("FadeTransition: Initialization complete")

# Public fade methods
func fade_out(duration: float = default_duration) -> void:
	if is_transition_active:
		print("FadeTransition: Fade already in progress, queuing request")
		await transition_completed

	print("FadeTransition: Starting fade out (", duration, "s)")

	is_transition_active = true
	fade_out_started.emit()

	# Create and configure tween
	if transition_tween:
		transition_tween.kill()

	transition_tween = create_tween()
	transition_tween.set_ease(Tween.EASE_IN_OUT)
	transition_tween.set_trans(Tween.TRANS_QUART)

	# Animate fade out
	transition_tween.tween_method(_update_fade_alpha, current_alpha, 1.0, duration)
	await transition_tween.finished

	current_alpha = 1.0
	is_transition_active = false
	fade_out_completed.emit()

func fade_in(duration: float = default_duration) -> void:
	if is_transition_active:
		print("FadeTransition: Fade already in progress, queuing request")
		await transition_completed

	print("FadeTransition: Starting fade in (", duration, "s)")

	is_transition_active = true
	fade_in_started.emit()

	# Create and configure tween
	if transition_tween:
		transition_tween.kill()

	transition_tween = create_tween()
	transition_tween.set_ease(Tween.EASE_IN_OUT)
	transition_tween.set_trans(Tween.TRANS_QUART)

	# Animate fade in
	transition_tween.tween_method(_update_fade_alpha, current_alpha, 0.0, duration)
	await transition_tween.finished

	current_alpha = 0.0
	is_transition_active = false
	fade_in_completed.emit()

func fade_out_in(duration: float = default_duration) -> void:
	print("FadeTransition: Starting fade out/in sequence (", duration, "s total)")

	var half_duration = duration / 2.0

	# Fade out
	await fade_out(half_duration)

	# Signal midpoint (scene can change here)
	transition_completed.emit()

	# Fade in
	await fade_in(half_duration)

func instant_fade_out() -> void:
	print("FadeTransition: Instant fade out")
	_set_fade_alpha(1.0)

func instant_fade_in() -> void:
	print("FadeTransition: Instant fade in")
	_set_fade_alpha(0.0)

func instant_clear() -> void:
	print("FadeTransition: Instant clear")
	_set_fade_alpha(0.0)

# Alpha control methods
func _update_fade_alpha(alpha: float) -> void:
	current_alpha = clampf(alpha, 0.0, 1.0)
	fade_rect.modulate.a = current_alpha

func _set_fade_alpha(alpha: float) -> void:
	current_alpha = clampf(alpha, 0.0, 1.0)
	fade_rect.modulate.a = current_alpha

func get_fade_alpha() -> float:
	return current_alpha

# Configuration methods
func set_fade_color(color: Color) -> void:
	fade_color = color
	if fade_rect:
		fade_rect.color = color

func set_default_duration(duration: float) -> void:
	default_duration = maxf(0.1, duration)

# State queries
func is_fully_transparent() -> bool:
	return current_alpha <= 0.0

func is_fully_opaque() -> bool:
	return current_alpha >= 1.0

func is_fading() -> bool:
	return is_transition_active

# Advanced transition effects
func pulse_fade(intensity: float = 0.3, duration: float = 0.5) -> void:
	if is_transition_active:
		return

	print("FadeTransition: Pulse fade effect")

	is_transition_active = true
	var start_alpha = current_alpha

	if transition_tween:
		transition_tween.kill()

	transition_tween = create_tween()
	transition_tween.tween_method(_update_fade_alpha, start_alpha, intensity, duration / 2.0)
	transition_tween.tween_method(_update_fade_alpha, intensity, start_alpha, duration / 2.0)

	await transition_tween.finished
	is_transition_active = false

func flicker_effect(flicker_count: int = 3, flicker_duration: float = 0.1) -> void:
	if is_transition_active:
		return

	print("FadeTransition: Flicker effect (", flicker_count, " flickers)")

	is_transition_active = true
	var original_alpha = current_alpha

	for i in flicker_count:
		_set_fade_alpha(1.0)
		await get_tree().create_timer(flicker_duration).timeout
		_set_fade_alpha(original_alpha)
		await get_tree().create_timer(flicker_duration).timeout

	is_transition_active = false

# Cancel and cleanup
func cancel_transition() -> void:
	if transition_tween:
		transition_tween.kill()

	is_transition_active = false
	print("FadeTransition: Transition cancelled")

func reset() -> void:
	cancel_transition()
	instant_clear()
	print("FadeTransition: Reset to clear state")

# Debug methods
func debug_test_transitions() -> void:
	print("FadeTransition: Testing all transition types")

	await fade_out(1.0)
	await get_tree().create_timer(1.0).timeout

	await fade_in(1.0)
	await get_tree().create_timer(1.0).timeout

	await fade_out_in(2.0)

	print("FadeTransition: Transition tests complete")

func debug_show_fade_info() -> void:
	print("FadeTransition Debug Info:")
	print("  Current Alpha: ", current_alpha)
	print("  Is Active: ", is_transition_active)
	print("  Fade Color: ", fade_color)
	print("  Default Duration: ", default_duration)