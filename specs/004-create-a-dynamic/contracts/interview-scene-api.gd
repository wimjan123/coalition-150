# InterviewScene API Contract
# This file defines the expected interface for the Interview scene

class_name InterviewSceneContract

# UI update methods
func display_question(question_data: Dictionary) -> void:
	# Updates UI with new question and answer options
	# question_data format: {id: String, text: String, answers: Array[Dictionary]}
	pass

func show_progress(current: int, maximum: int) -> void:
	# Updates progress indicator showing interview completion
	pass

func display_effects_feedback(effects: Dictionary) -> void:
	# Shows visual feedback for applied game effects
	# effects format: {stats: Dictionary, flags: Dictionary, unlocks: Array}
	pass

func show_completion_screen(summary: Dictionary) -> void:
	# Displays interview completion summary and transition options
	pass

# User interaction handling
func _on_answer_selected(answer_index: int) -> void:
	# Handles player answer selection
	# Connects to answer button signals
	pass

func _on_skip_interview_pressed() -> void:
	# Handles interview skip request (if allowed)
	pass

func _on_continue_pressed() -> void:
	# Handles transition to next game phase after completion
	pass

# Scene lifecycle
func _ready() -> void:
	# Initialize scene and connect to InterviewManager
	# Load interview data and start session
	pass

func _exit_tree() -> void:
	# Clean up connections and resources
	pass

# UI components (expected nodes in scene)
@onready var question_label: Label
@onready var answer_container: VBoxContainer
@onready var progress_bar: ProgressBar
@onready var effects_panel: Panel
@onready var completion_panel: Panel
@onready var skip_button: Button
@onready var continue_button: Button

# Button template for dynamic answer options
var answer_button_template: PackedScene

# Signals for scene transitions
signal interview_scene_completed()
signal interview_skipped()