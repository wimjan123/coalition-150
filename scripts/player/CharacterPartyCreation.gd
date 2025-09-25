# CharacterPartyCreation - Scene for creating new characters and parties
# Implements CharacterCreationInterface for TDD compliance

extends Control

# UI References - Character Section
@onready var name_line_edit: LineEdit = $MainContainer/LeftPanel/ScrollContainer/FormContainer/CharacterSection/NameGroup/NameLineEdit
@onready var experience_line_edit: LineEdit = $MainContainer/LeftPanel/ScrollContainer/FormContainer/CharacterSection/ExperienceGroup/ExperienceLineEdit
@onready var backstory_text_edit: TextEdit = $MainContainer/LeftPanel/ScrollContainer/FormContainer/CharacterSection/BackstoryGroup/BackstoryTextEdit

# UI References - Party Section
@onready var party_name_line_edit: LineEdit = $MainContainer/LeftPanel/ScrollContainer/FormContainer/PartySection/PartyNameGroup/PartyNameLineEdit
@onready var slogan_line_edit: LineEdit = $MainContainer/LeftPanel/ScrollContainer/FormContainer/PartySection/SloganGroup/SloganLineEdit

# UI References - Branding Section
@onready var color_picker_button: ColorPickerButton = $MainContainer/RightPanel/PreviewContainer/ColorSection/ColorPickerButton
@onready var logo_buttons: Array[Button] = []

# UI References - Navigation
@onready var back_button: Button = $MainContainer/RightPanel/ButtonContainer/BackButton
@onready var continue_button: Button = $MainContainer/RightPanel/ButtonContainer/ContinueButton
@onready var validation_message: Label = $ValidationMessage

# Data
var character_data: CharacterData = CharacterData.new()
var party_data: PartyData = PartyData.new()
var selected_logo_index: int = 0

func _ready() -> void:
	_setup_ui()
	_connect_signals()
	_setup_logo_buttons()
	_setup_validation()

func _setup_ui() -> void:
	# Apply theme
	if theme == null:
		theme = preload("res://assets/themes/player_creation_theme.tres")

	# Set initial color
	color_picker_button.color = Color(0.2, 0.6, 0.8, 1.0)

func _connect_signals() -> void:
	# Character field signals
	name_line_edit.text_changed.connect(_on_character_field_changed)
	experience_line_edit.text_changed.connect(_on_character_field_changed)
	backstory_text_edit.text_changed.connect(_on_character_field_changed)

	# Party field signals
	party_name_line_edit.text_changed.connect(_on_party_field_changed)
	slogan_line_edit.text_changed.connect(_on_party_field_changed)

	# Branding signals
	color_picker_button.color_changed.connect(_on_color_changed)

	# Navigation signals
	back_button.pressed.connect(_on_back_pressed)
	continue_button.pressed.connect(_on_continue_pressed)

func _setup_logo_buttons() -> void:
	# Get logo buttons from the scene
	var logo_container: GridContainer = $MainContainer/RightPanel/PreviewContainer/LogoSection/LogoContainer
	for i in range(5):  # 5 logo options per spec
		var button: Button = logo_container.get_child(i) as Button
		if button:
			logo_buttons.append(button)
			button.pressed.connect(_on_logo_selected.bind(i))

	# Select first logo by default
	if logo_buttons.size() > 0:
		logo_buttons[0].button_pressed = true

func _setup_validation() -> void:
	validation_message.text = ""
	_validate_form()

# CharacterCreationInterface Implementation

func set_character_name(name: String) -> void:
	character_data.character_name = name
	name_line_edit.text = name

func set_political_experience(experience: String) -> void:
	character_data.political_experience = experience
	experience_line_edit.text = experience

func set_policy_position(policy_area: String, stance: String) -> void:
	character_data.set_policy_position(policy_area, stance)

func set_backstory(backstory: String) -> void:
	character_data.backstory = backstory
	backstory_text_edit.text = backstory

func get_character_data() -> CharacterData:
	return character_data

func set_party_name(name: String) -> void:
	party_data.party_name = name
	party_name_line_edit.text = name

func set_party_slogan(slogan: String) -> void:
	party_data.slogan = slogan
	slogan_line_edit.text = slogan

func set_party_color(color: Color) -> void:
	party_data.primary_color = color
	color_picker_button.color = color

func set_party_logo(logo_index: int) -> void:
	if logo_index >= 0 and logo_index < logo_buttons.size():
		# Deselect all logos
		for button in logo_buttons:
			button.button_pressed = false

		# Select the specified logo
		logo_buttons[logo_index].button_pressed = true
		selected_logo_index = logo_index
		party_data.logo_index = logo_index

func get_party_data() -> PartyData:
	return party_data

func validate_character_fields() -> bool:
	if character_data.character_name.is_empty():
		return false
	if character_data.political_experience.is_empty():
		return false
	if character_data.backstory.is_empty():
		return false
	return true

func validate_party_fields() -> bool:
	if party_data.party_name.is_empty():
		return false
	if party_data.slogan.is_empty():
		return false
	return true

func validate_party_name_unique(name: String) -> bool:
	# Check against SceneManager's save system
	return SceneManager.save_system.is_party_name_unique(name) if SceneManager.save_system else true

func show_character_section() -> void:
	# Focus on character section (scroll to top)
	var scroll_container: ScrollContainer = $MainContainer/LeftPanel/ScrollContainer
	scroll_container.scroll_vertical = 0

func show_party_section() -> void:
	# Focus on party section (scroll down)
	var scroll_container: ScrollContainer = $MainContainer/LeftPanel/ScrollContainer
	scroll_container.scroll_vertical = 200

func show_summary_section() -> void:
	# Could show a summary dialog or scroll to bottom
	pass

func reset_form() -> void:
	# Clear all form fields
	name_line_edit.text = ""
	experience_line_edit.text = ""
	backstory_text_edit.text = ""
	party_name_line_edit.text = ""
	slogan_line_edit.text = ""

	# Reset branding
	color_picker_button.color = Color(0.2, 0.6, 0.8, 1.0)
	if logo_buttons.size() > 0:
		for button in logo_buttons:
			button.button_pressed = false
		logo_buttons[0].button_pressed = true

	# Reset data
	character_data = CharacterData.new()
	party_data = PartyData.new()
	selected_logo_index = 0

	_validate_form()

func populate_form_from_character(character: CharacterData) -> void:
	if not character:
		return

	character_data = character
	set_character_name(character.character_name)
	set_political_experience(character.political_experience)
	set_backstory(character.backstory)

	if character.party:
		party_data = character.party
		set_party_name(character.party.party_name)
		set_party_slogan(character.party.slogan)
		set_party_color(character.party.primary_color)
		set_party_logo(character.party.logo_index)

	_validate_form()

func get_available_logos() -> Array[Texture2D]:
	# Return placeholder textures for now
	var logos: Array[Texture2D] = []
	for i in range(5):
		# TODO: Load actual logo textures
		logos.append(null)
	return logos

func preview_logo(logo_index: int) -> void:
	set_party_logo(logo_index)

func get_completion_percentage() -> float:
	var total_fields: int = 5  # name, experience, backstory, party_name, slogan
	var completed_fields: int = 0

	if not character_data.character_name.is_empty():
		completed_fields += 1
	if not character_data.political_experience.is_empty():
		completed_fields += 1
	if not character_data.backstory.is_empty():
		completed_fields += 1
	if not party_data.party_name.is_empty():
		completed_fields += 1
	if not party_data.slogan.is_empty():
		completed_fields += 1

	return float(completed_fields) / float(total_fields)

func is_creation_complete() -> bool:
	return validate_character_fields() and validate_party_fields()

# Event Handlers

func _on_character_field_changed(_new_text: String = "") -> void:
	# Update character data from form fields
	character_data.character_name = name_line_edit.text
	character_data.political_experience = experience_line_edit.text
	character_data.backstory = backstory_text_edit.text

	_validate_form()
	character_creation_completed.emit(character_data)

func _on_party_field_changed(_new_text: String = "") -> void:
	# Update party data from form fields
	party_data.party_name = party_name_line_edit.text
	party_data.slogan = slogan_line_edit.text

	_validate_form()
	party_creation_completed.emit(party_data)

func _on_color_changed(color: Color) -> void:
	party_data.primary_color = color

func _on_logo_selected(logo_index: int) -> void:
	set_party_logo(logo_index)

func _on_back_pressed() -> void:
	return_to_selection_requested.emit()
	SceneManager.change_scene_to_player_selection()

func _on_continue_pressed() -> void:
	if not is_creation_complete():
		validation_failed.emit("form", "Please complete all required fields")
		return

	# Validate party name uniqueness
	if not validate_party_name_unique(party_data.party_name):
		validation_failed.emit("party_name", "Party name already exists")
		validation_message.text = "Party name already exists. Please choose a different name."
		return

	# Link party to character
	character_data.party = party_data

	# Proceed to interview
	proceed_to_interview_requested.emit()

	# Set current character in SceneManager for interview
	SceneManager.set_current_character(character_data)
	SceneManager.change_scene_to_interview()

func _validate_form() -> void:
	var is_valid: bool = is_creation_complete()
	var unique_name: bool = validate_party_name_unique(party_data.party_name) if not party_data.party_name.is_empty() else true

	continue_button.disabled = not (is_valid and unique_name)

	if not unique_name:
		validation_message.text = "Party name already exists"
	else:
		validation_message.text = ""

# Input handling
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()