# MainMenu - Main menu scene with Load Game integration
# Handles navigation to player creation flow and save data management

extends Control

# UI References
@onready var start_button: Button = $MenuContainer/StartButton
@onready var load_button: Button = $MenuContainer/LoadButton
@onready var options_button: Button = $MenuContainer/OptionsButton
@onready var exit_button: Button = $MenuContainer/ExitButton
@onready var status_label: Label = $StatusLabel

func _ready() -> void:
	_setup_ui()
	_connect_signals()
	_check_save_data()

func _setup_ui() -> void:
	# Ensure theme is applied
	if theme == null:
		var theme_path: String = "res://assets/themes/ui_theme.tres"
		if ResourceLoader.exists(theme_path):
			theme = load(theme_path)

func _connect_signals() -> void:
	start_button.pressed.connect(_on_start_button_pressed)
	load_button.pressed.connect(_on_load_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)

func _check_save_data() -> void:
	# Check if save data exists and update Load Game button state
	var has_save: bool = SceneManager.has_save_data()

	load_button.disabled = not has_save

	if has_save:
		var characters: Array[CharacterData] = SceneManager.get_available_characters()
		var character_count: int = characters.size()
		status_label.text = str(character_count) + " saved character(s) available"
	else:
		status_label.text = "No saved data found"

	print("Save data check: has_save=", has_save)

func _on_start_button_pressed() -> void:
	print("Start Game pressed - navigating to character selection")
	SceneManager.change_scene_to_player_selection()

func _on_load_button_pressed() -> void:
	if not SceneManager.has_save_data():
		push_warning("Load Game pressed but no save data available")
		return

	print("Load Game pressed - navigating to character selection")
	SceneManager.change_scene_to_player_selection()

func _on_options_button_pressed() -> void:
	print("Options pressed - not implemented yet")
	# TODO: Implement options menu
	pass

func _on_exit_button_pressed() -> void:
	print("Exit pressed - closing application")
	get_tree().quit()

# Called when returning to main menu (refresh save data state)
func refresh_save_state() -> void:
	_check_save_data()

# Handle input events
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_exit_button_pressed()
