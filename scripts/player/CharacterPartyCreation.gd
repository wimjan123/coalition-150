# CharacterPartyCreation - Scene for creating new characters and parties
# Implements CharacterCreationInterface for TDD compliance

extends Control

# UI References - Character Section
@onready var name_line_edit: LineEdit = $MainContainer/LeftPanel/ScrollContainer/FormContainer/CharacterSection/NameGroup/NameLineEdit
@onready var experience_line_edit: LineEdit = $MainContainer/LeftPanel/ScrollContainer/FormContainer/CharacterSection/ExperienceGroup/ExperienceLineEdit
@onready var background_option_button: OptionButton = $MainContainer/LeftPanel/ScrollContainer/FormContainer/CharacterSection/BackgroundGroup/BackgroundOptionButton

# UI References - Background Preview Section
@onready var preview_container: VBoxContainer = $MainContainer/LeftPanel/ScrollContainer/FormContainer/CharacterSection/BackgroundGroup/PreviewContainer
@onready var difficulty_label: Label = $MainContainer/LeftPanel/ScrollContainer/FormContainer/CharacterSection/BackgroundGroup/PreviewContainer/DifficultyContainer/DifficultyLabel
@onready var archetype_label: Label = $MainContainer/LeftPanel/ScrollContainer/FormContainer/CharacterSection/BackgroundGroup/PreviewContainer/ArchetypeContainer/ArchetypeLabel
@onready var impact_label: Label = $MainContainer/LeftPanel/ScrollContainer/FormContainer/CharacterSection/BackgroundGroup/PreviewContainer/ImpactLabel
@onready var satirical_warning: Label = $MainContainer/LeftPanel/ScrollContainer/FormContainer/CharacterSection/BackgroundGroup/PreviewContainer/SatiricalWarning

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

# Preset System Data
var background_presets: CharacterBackgroundPresets
var selected_preset: PresetOption
var selected_background_preset_id: String = ""

# Signals for navigation and state management
signal character_creation_completed(character: CharacterData)
signal party_creation_completed(party: PartyData)
signal return_to_selection_requested()
signal validation_failed(message: String)
signal proceed_to_interview_requested(character: CharacterData)

func _ready() -> void:
	_load_preset_collection()
	_setup_ui()
	_connect_signals()
	_setup_logo_buttons()
	_populate_preset_dropdown()
	_setup_validation()

# T022: Preset loading logic implementation
func _load_preset_collection() -> void:
	"""Load the character background presets from the resource file"""
	var preset_resource_path = "res://assets/data/CharacterBackgroundPresets.tres"

	print("🔍 Attempting to load presets from: ", preset_resource_path)
	print("🔍 Resource exists: ", ResourceLoader.exists(preset_resource_path))

	if ResourceLoader.exists(preset_resource_path):
		var resource = load(preset_resource_path)
		print("🔍 Raw resource loaded: ", resource != null)
		print("🔍 Resource type: ", resource.get_class() if resource else "null")

		# Try direct cast
		background_presets = resource as CharacterBackgroundPresets
		print("🔍 Cast to CharacterBackgroundPresets: ", background_presets != null)

		if background_presets:
			print("🔍 Preset options array size: ", background_presets.preset_options.size())
			print("🔍 Collection version: ", background_presets.version)

			# Check validity
			if background_presets.is_valid():
				print("✅ Successfully loaded ", background_presets.preset_options.size(), " character background presets")
				return
			else:
				print("⚠️  Preset collection validation failed")
		else:
			print("❌ Failed to cast resource to CharacterBackgroundPresets")
	else:
		print("❌ Preset resource file not found")

	print("🔄 Creating fallback presets...")
	_create_fallback_presets()

func _create_fallback_presets() -> void:
	"""Create minimal fallback presets if resource loading fails"""
	background_presets = CharacterBackgroundPresets.new()

	# Create multiple fallback presets for testing
	var presets = []

	# Fallback 1: Easy
	var preset1 = PresetOption.new()
	preset1.id = "fallback_easy"
	preset1.display_name = "Student Activist"
	preset1.background_text = "A passionate university student organizing protests"
	preset1.character_archetype = "Grassroots Organizer"
	preset1.difficulty_rating = 1
	preset1.difficulty_label = "Very Easy"
	preset1.gameplay_impact = "High energy, limited experience"
	preset1.political_alignment = "Progressive"
	preset1.is_satirical = false
	presets.append(preset1)

	# Fallback 2: Medium
	var preset2 = PresetOption.new()
	preset2.id = "fallback_medium"
	preset2.display_name = "Local Councillor"
	preset2.background_text = "Experienced in municipal politics"
	preset2.character_archetype = "Career Politician"
	preset2.difficulty_rating = 5
	preset2.difficulty_label = "Medium"
	preset2.gameplay_impact = "Balanced experience and connections"
	preset2.political_alignment = "Centrist"
	preset2.is_satirical = false
	presets.append(preset2)

	# Fallback 3: Hard
	var preset3 = PresetOption.new()
	preset3.id = "fallback_hard"
	preset3.display_name = "Tech Entrepreneur"
	preset3.background_text = "Successful business owner entering politics"
	preset3.character_archetype = "Digital Innovator"
	preset3.difficulty_rating = 8
	preset3.difficulty_label = "Hard"
	preset3.gameplay_impact = "High scrutiny, innovative platform"
	preset3.political_alignment = "Libertarian"
	preset3.is_satirical = false
	presets.append(preset3)

	background_presets.preset_options = presets
	background_presets.version = "fallback"
	print("⚠️  Using ", presets.size(), " fallback presets due to resource loading failure")

func _setup_ui() -> void:
	# Apply theme
	if theme == null:
		theme = preload("res://assets/themes/player_creation_theme.tres")

	# Set initial color
	color_picker_button.color = Color(0.2, 0.6, 0.8, 1.0)

	# Initialize preview container as hidden
	if preview_container:
		preview_container.visible = false

# T023: Option population and sorting by difficulty implementation
func _populate_preset_dropdown() -> void:
	"""Populate the OptionButton with presets sorted by difficulty"""
	if not background_presets or not background_option_button:
		return

	# Clear existing options
	background_option_button.clear()

	# Add default "Select Background..." option
	background_option_button.add_item("Select Background...")
	background_option_button.set_item_disabled(0, true)  # Disable placeholder option

	# Get presets sorted by difficulty (easy to hard)
	var sorted_presets = background_presets.get_sorted_by_difficulty()

	# Add each preset as an option
	for i in range(sorted_presets.size()):
		var preset = sorted_presets[i]
		var display_text = "%s (%s)" % [preset.display_name, preset.difficulty_label]

		# Add satirical indicator if applicable
		if preset.is_satirical:
			display_text = "🎭 " + display_text

		background_option_button.add_item(display_text)

	print("✓ Populated dropdown with ", sorted_presets.size(), " background presets")

func _connect_signals() -> void:
	# Character field signals
	name_line_edit.text_changed.connect(_on_character_field_changed)
	experience_line_edit.text_changed.connect(_on_character_field_changed)
	background_option_button.item_selected.connect(_on_background_preset_selected)

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
	# Legacy method - now handled by preset selection
	push_warning("set_backstory() is deprecated - use preset selection instead")

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

# T025: Validation logic for preset selection implementation
func validate_character_fields() -> bool:
	"""Validate character creation fields including preset selection"""
	if character_data.character_name.is_empty():
		return false
	if character_data.political_experience.is_empty():
		return false

	# Validate preset selection instead of free-text backstory
	if selected_background_preset_id.is_empty():
		return false

	# Ensure selected preset actually exists in the collection
	if background_presets and background_presets.get_preset_by_id(selected_background_preset_id) == null:
		return false

	return true

func validate_preset_selection() -> bool:
	"""Validate that a valid preset is selected"""
	if selected_background_preset_id.is_empty():
		return false

	if not background_presets:
		return false

	var preset = background_presets.get_preset_by_id(selected_background_preset_id)
	return preset != null and preset.is_valid()

func get_validation_errors() -> Array[String]:
	"""Get detailed validation error messages"""
	var errors: Array[String] = []

	if character_data.character_name.is_empty():
		errors.append("Character name is required")

	if character_data.political_experience.is_empty():
		errors.append("Political experience is required")

	if not validate_preset_selection():
		errors.append("Please select a character background")

	if party_data.party_name.is_empty():
		errors.append("Party name is required")

	if party_data.slogan.is_empty():
		errors.append("Campaign slogan is required")

	return errors

func show_validation_error(message: String) -> void:
	"""Display validation error message to user"""
	validation_message.text = message
	validation_message.modulate = Color(1, 0.5, 0.5, 1)  # Red color

func hide_validation_error() -> void:
	"""Hide validation error message"""
	validation_message.text = ""

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
	party_name_line_edit.text = ""
	slogan_line_edit.text = ""

	# Reset preset selection
	if background_option_button:
		background_option_button.selected = 0  # Reset to placeholder
	_clear_preset_selection()

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

	# Handle preset selection for existing characters
	if character.has("selected_background_preset_id") and not character.selected_background_preset_id.is_empty():
		_load_character_preset(character.selected_background_preset_id)
	elif not character.backstory.is_empty():
		# Legacy character with free-text backstory - could implement migration here
		push_warning("Loading legacy character with free-text backstory")

	if character.party:
		party_data = character.party
		set_party_name(character.party.party_name)
		set_party_slogan(character.party.slogan)
		set_party_color(character.party.primary_color)
		set_party_logo(character.party.logo_index)

	_validate_form()

func _load_character_preset(preset_id: String) -> void:
	"""Load and select a preset for an existing character"""
	if not background_presets:
		return

	var preset = background_presets.get_preset_by_id(preset_id)
	if preset:
		# Find the dropdown index for this preset
		var sorted_presets = background_presets.get_sorted_by_difficulty()
		for i in range(sorted_presets.size()):
			if sorted_presets[i].id == preset_id:
				background_option_button.selected = i + 1  # +1 for placeholder option
				_set_selected_preset(preset)
				_update_preview_display()
				break

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
	var total_fields: int = 5  # name, experience, background_preset, party_name, slogan
	var completed_fields: int = 0

	if not character_data.character_name.is_empty():
		completed_fields += 1
	if not character_data.political_experience.is_empty():
		completed_fields += 1
	if validate_preset_selection():  # Check preset selection instead of backstory
		completed_fields += 1
	if not party_data.party_name.is_empty():
		completed_fields += 1
	if not party_data.slogan.is_empty():
		completed_fields += 1

	return float(completed_fields) / float(total_fields)

func is_creation_complete() -> bool:
	return validate_character_fields() and validate_party_fields()

# Event Handlers

# T024: Selection handling and preview updates implementation
func _on_background_preset_selected(index: int) -> void:
	"""Handle preset selection from OptionButton"""
	if index <= 0 or not background_presets:
		# Placeholder option selected or no presets loaded
		_clear_preset_selection()
		return

	# Get sorted presets to match dropdown order
	var sorted_presets = background_presets.get_sorted_by_difficulty()
	var preset_index = index - 1  # Subtract 1 for placeholder option

	if preset_index >= 0 and preset_index < sorted_presets.size():
		var selected = sorted_presets[preset_index]
		_set_selected_preset(selected)
		_update_preview_display()

func _set_selected_preset(preset: PresetOption) -> void:
	"""Set the currently selected preset and update character data"""
	selected_preset = preset
	selected_background_preset_id = preset.id

	# Update character data with preset selection
	character_data.selected_background_preset_id = preset.id
	character_data.backstory = preset.background_text  # Update for compatibility

	print("✓ Selected preset: ", preset.display_name, " (ID: ", preset.id, ")")

func _clear_preset_selection() -> void:
	"""Clear the current preset selection"""
	selected_preset = null
	selected_background_preset_id = ""
	character_data.selected_background_preset_id = ""
	character_data.backstory = ""

	_hide_preview_display()

func _update_preview_display() -> void:
	"""Update the preview display with selected preset information"""
	if not selected_preset or not preview_container:
		return

	# Show preview container
	preview_container.visible = true

	# Update difficulty display
	if difficulty_label:
		difficulty_label.text = selected_preset.difficulty_label
		difficulty_label.modulate = selected_preset.get_difficulty_color()

	# Update archetype display
	if archetype_label:
		archetype_label.text = selected_preset.character_archetype

	# Update impact description
	if impact_label:
		impact_label.text = selected_preset.gameplay_impact

	# Show/hide satirical warning
	if satirical_warning:
		satirical_warning.visible = selected_preset.is_satirical

	print("✓ Updated preview for: ", selected_preset.display_name)

func _hide_preview_display() -> void:
	"""Hide the preview display"""
	if preview_container:
		preview_container.visible = false

func _on_character_field_changed(_new_text: String = "") -> void:
	# Update character data from form fields
	character_data.character_name = name_line_edit.text
	character_data.political_experience = experience_line_edit.text
	# Note: backstory now handled by preset selection, not direct input

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