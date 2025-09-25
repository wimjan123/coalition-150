# CharacterCreationInterface - Contract for character and party creation scene
# Defines the required interface for the CharacterPartyCreation scene

extends Control
class_name CharacterCreationInterface

# Creation completion signals
signal character_creation_completed(character_data: CharacterData)
signal party_creation_completed(party_data: PartyData)
signal creation_cancelled()
signal validation_failed(field_name: String, error_message: String)

# Navigation signals
signal proceed_to_interview_requested()
signal return_to_selection_requested()

# Character creation methods
func set_character_name(name: String) -> void:
	# Set character's display name
	push_error("CharacterCreationInterface.set_character_name() not implemented")

func set_political_experience(experience: String) -> void:
	# Set character's political background
	push_error("CharacterCreationInterface.set_political_experience() not implemented")

func set_policy_position(policy_area: String, stance: String) -> void:
	# Set character's position on specific policy
	push_error("CharacterCreationInterface.set_policy_position() not implemented")

func set_backstory(backstory: String) -> void:
	# Set character's personal history
	push_error("CharacterCreationInterface.set_backstory() not implemented")

func get_character_data() -> CharacterData:
	# Return completed character data
	push_error("CharacterCreationInterface.get_character_data() not implemented")
	return null

# Party creation methods
func set_party_name(name: String) -> void:
	# Set political party name
	push_error("CharacterCreationInterface.set_party_name() not implemented")

func set_party_slogan(slogan: String) -> void:
	# Set party campaign slogan
	push_error("CharacterCreationInterface.set_party_slogan() not implemented")

func set_party_color(color: Color) -> void:
	# Set party primary brand color
	push_error("CharacterCreationInterface.set_party_color() not implemented")

func set_party_logo(logo_index: int) -> void:
	# Set party logo from available options (0-4)
	push_error("CharacterCreationInterface.set_party_logo() not implemented")

func get_party_data() -> PartyData:
	# Return completed party data
	push_error("CharacterCreationInterface.get_party_data() not implemented")
	return null

# Validation methods
func validate_character_fields() -> bool:
	# Validate all required character fields
	push_error("CharacterCreationInterface.validate_character_fields() not implemented")
	return false

func validate_party_fields() -> bool:
	# Validate all required party fields
	push_error("CharacterCreationInterface.validate_party_fields() not implemented")
	return false

func validate_party_name_unique(name: String) -> bool:
	# Check if party name is unique for this player
	push_error("CharacterCreationInterface.validate_party_name_unique() not implemented")
	return false

# UI state management
func show_character_section() -> void:
	# Display character creation form
	push_error("CharacterCreationInterface.show_character_section() not implemented")

func show_party_section() -> void:
	# Display party creation form
	push_error("CharacterCreationInterface.show_party_section() not implemented")

func show_summary_section() -> void:
	# Display creation summary/confirmation
	push_error("CharacterCreationInterface.show_summary_section() not implemented")

func reset_form() -> void:
	# Clear all form fields to defaults
	push_error("CharacterCreationInterface.reset_form() not implemented")

func populate_form_from_character(character: CharacterData) -> void:
	# Fill form with existing character data (for editing)
	push_error("CharacterCreationInterface.populate_form_from_character() not implemented")

# Logo management
func get_available_logos() -> Array[Texture2D]:
	# Return array of available logo textures
	push_error("CharacterCreationInterface.get_available_logos() not implemented")
	return []

func preview_logo(logo_index: int) -> void:
	# Show preview of selected logo
	push_error("CharacterCreationInterface.preview_logo() not implemented")

# Progress tracking
func get_completion_percentage() -> float:
	# Return form completion progress (0.0 to 1.0)
	push_error("CharacterCreationInterface.get_completion_percentage() not implemented")
	return 0.0

func is_creation_complete() -> bool:
	# Check if both character and party creation are complete
	push_error("CharacterCreationInterface.is_creation_complete() not implemented")
	return false