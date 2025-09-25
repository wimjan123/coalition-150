# ProgressBar - Custom progress bar component with theme styling
# Provides enhanced progress display with smooth animations

extends Control
class_name ProgressBarComponent

# Node references
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var percentage_label: Label = $PercentageLabel
@onready var loading_animation: AnimationPlayer = $LoadingAnimation
@onready var background: NinePatchRect = $Background

# Configuration
@export var animate_progress: bool = true
@export var show_percentage_text: bool = true
@export var smooth_transition_duration: float = 0.3

# State
var current_value: float = 0.0
var target_value: float = 0.0
var progress_tween: Tween

signal progress_changed(value: float)
signal progress_completed()

func _ready():
	_initialize_progress_bar()
	_setup_styling()

func _initialize_progress_bar() -> void:
	print("ProgressBarComponent: Initializing custom progress bar")

	# Configure progress bar
	progress_bar.value = 0.0
	progress_bar.min_value = 0.0
	progress_bar.max_value = 100.0

	# Configure percentage label
	percentage_label.visible = show_percentage_text

	print("ProgressBarComponent: Initialization complete")

func _setup_styling() -> void:
	# Apply theme styling if available
	if theme:
		print("ProgressBarComponent: Theme styling applied")

	# Configure visual appearance
	background.modulate = Color(0.3, 0.3, 0.3, 0.8)

# Public methods
func set_progress(value: float, animate: bool = true) -> void:
	target_value = clampf(value * 100.0, 0.0, 100.0)

	if animate and animate_progress:
		_animate_to_value(target_value)
	else:
		_set_immediate_value(target_value)

func set_progress_percentage(percentage: int) -> void:
	set_progress(percentage / 100.0)

func get_progress() -> float:
	return current_value / 100.0

func get_progress_percentage() -> int:
	return int(current_value)

func reset_progress() -> void:
	set_progress(0.0, false)

func complete_progress() -> void:
	set_progress(1.0, true)
	await progress_tween.finished if progress_tween
	progress_completed.emit()

# Animation methods
func _animate_to_value(new_value: float) -> void:
	if progress_tween:
		progress_tween.kill()

	progress_tween = create_tween()
	progress_tween.set_ease(Tween.EASE_OUT)
	progress_tween.set_trans(Tween.TRANS_QUART)

	progress_tween.parallel().tween_method(_update_progress_value, current_value, new_value, smooth_transition_duration)
	progress_tween.parallel().tween_method(_update_percentage_text, current_value, new_value, smooth_transition_duration)

func _set_immediate_value(new_value: float) -> void:
	_update_progress_value(new_value)
	_update_percentage_text(new_value)

func _update_progress_value(value: float) -> void:
	current_value = value
	progress_bar.value = value

	# Emit progress change signal
	progress_changed.emit(value / 100.0)

func _update_percentage_text(value: float) -> void:
	if show_percentage_text:
		percentage_label.text = str(int(value)) + "%"

# Visual effects
func start_loading_animation() -> void:
	if loading_animation and loading_animation.has_animation("loading_pulse"):
		loading_animation.play("loading_pulse")

func stop_loading_animation() -> void:
	if loading_animation:
		loading_animation.stop()

func set_progress_color(color: Color) -> void:
	if progress_bar:
		progress_bar.modulate = color

func pulse_effect() -> void:
	var pulse_tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.tween_property(self, "modulate:a", 0.7, 0.5)
	pulse_tween.tween_property(self, "modulate:a", 1.0, 0.5)

# Error state visualization
func show_error_state() -> void:
	set_progress_color(Color.RED)
	pulse_effect()

func show_success_state() -> void:
	set_progress_color(Color.GREEN)
	var success_tween = create_tween()
	success_tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.2)
	success_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)

func reset_visual_state() -> void:
	set_progress_color(Color.WHITE)
	modulate = Color.WHITE
	scale = Vector2.ONE

# Configuration setters
func set_smooth_transitions(enabled: bool) -> void:
	animate_progress = enabled

func set_percentage_visibility(visible: bool) -> void:
	show_percentage_text = visible
	if percentage_label:
		percentage_label.visible = visible

func set_transition_duration(duration: float) -> void:
	smooth_transition_duration = maxf(0.1, duration)

# Utility methods
func is_complete() -> bool:
	return current_value >= 100.0

func is_empty() -> bool:
	return current_value <= 0.0

func get_remaining_percentage() -> float:
	return 100.0 - current_value

# Debug methods
func debug_set_random_progress() -> void:
	var random_progress = randf()
	set_progress(random_progress)
	print("ProgressBarComponent: Debug set random progress: ", int(random_progress * 100), "%")

func debug_simulate_loading() -> void:
	print("ProgressBarComponent: Debug simulating loading sequence")

	for i in range(0, 101, 10):
		set_progress(i / 100.0)
		await get_tree().create_timer(0.2).timeout

	show_success_state()
	print("ProgressBarComponent: Debug loading simulation complete")