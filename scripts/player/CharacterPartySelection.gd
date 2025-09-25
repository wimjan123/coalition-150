# CharacterPartySelection - Scene for selecting or creating characters and parties
# Implements the player's first step in the creation flow

extends Control

# UI References
@onready var save_status_label: Label = $MainContainer/SaveDataInfo/SaveStatusLabel
@onready var character_list_container: VBoxContainer = $MainContainer/SaveDataInfo/CharacterList/ScrollContainer/CharacterListContainer
@onready var create_new_button: Button = $MainContainer/ButtonContainer/CreateNewButton
@onready var load_selected_button: Button = $MainContainer/ButtonContainer/LoadSelectedButton
@onready var back_button: Button = $MainContainer/BackButton

# State
var available_characters: Array[CharacterData] = []
var selected_character: CharacterData = null
var character_buttons: Array[Button] = []

# Signals for navigation
signal character_selected(character: CharacterData)
signal create_new_requested()
signal load_character_requested(character: CharacterData)
signal return_to_menu_requested()

func _ready() -> void:
	_setup_ui()
	_connect_signals()
	_load_available_characters()

func _setup_ui() -> void:
	# Apply theme and initial UI state
	if theme == null:
		theme = preload("res://assets/themes/player_creation_theme.tres")

func _connect_signals() -> void:
	create_new_button.pressed.connect(_on_create_new_pressed)
	load_selected_button.pressed.connect(_on_load_selected_pressed)
	back_button.pressed.connect(_on_back_pressed)

func _load_available_characters() -> void:
	# Get characters from SceneManager
	available_characters = SceneManager.get_available_characters()

	if available_characters.is_empty():
		save_status_label.text = "No saved characters found"
		load_selected_button.disabled = true
	else:
		save_status_label.text = str(available_characters.size()) + " character(s) found"
		_populate_character_list()

func _populate_character_list() -> void:
	# Clear existing character buttons
	for button in character_buttons:
		if is_instance_valid(button):
			button.queue_free()
	character_buttons.clear()

	# Create button for each character
	for character in available_characters:
		var button: Button = Button.new()
		button.text = character.get_display_summary()
		button.custom_minimum_size = Vector2(0, 40)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT

		# Connect button to selection handler
		button.pressed.connect(_on_character_button_pressed.bind(character, button))

		character_list_container.add_child(button)
		character_buttons.append(button)

func _on_character_button_pressed(character: CharacterData, button: Button) -> void:
	# Deselect previous selection
	for btn in character_buttons:
		btn.button_pressed = false

	# Select new character
	selected_character = character
	button.button_pressed = true
	load_selected_button.disabled = false

	character_selected.emit(character)
	print("Character selected: ", character.character_name)

func _on_create_new_pressed() -> void:
	print("Create new character requested")
	create_new_requested.emit()
	SceneManager.change_scene_to_player_creation()

func _on_load_selected_pressed() -> void:
	if not selected_character:
		push_warning("No character selected for loading")
		return

	print("Loading character: ", selected_character.character_name)
	load_character_requested.emit(selected_character)

	# Set current character in SceneManager and go to main game
	SceneManager.set_current_character(selected_character)
	SceneManager.change_scene_to_main_game()

func _on_back_pressed() -> void:
	print("Returning to main menu")
	return_to_menu_requested.emit()
	SceneManager.change_scene_to_main_menu()

# Refresh character list (called when returning from creation)
func refresh_character_list() -> void:
	_load_available_characters()

# Get selected character for external access
func get_selected_character() -> CharacterData:
	return selected_character

# Validate selection state
func has_selection() -> bool:
	return selected_character != null

# Focus management for accessibility
func _on_focus_entered() -> void:
	if available_characters.is_empty():
		create_new_button.grab_focus()
	elif character_buttons.size() > 0:
		character_buttons[0].grab_focus()

# Handle input events
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()