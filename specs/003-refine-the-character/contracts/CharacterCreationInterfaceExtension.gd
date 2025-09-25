# Interface extension for CharacterPartyCreation to support preset selection
# This interface defines the additional methods needed for preset integration

class_name CharacterCreationInterfaceExtension
extends Control

## Preset system integration signals
signal preset_loaded(preset_count: int)
signal preset_selected(preset_id: String, preset_data: Dictionary)
signal preview_updated(difficulty: String, impact: String)
signal selection_validated(is_valid: bool, error_message: String)

## Core preset management methods
func load_preset_collection() -> CharacterBackgroundPresetsInterface:
	"""Loads the character background presets from resource file"""
	return null

func populate_preset_dropdown(presets: CharacterBackgroundPresetsInterface) -> void:
	"""Populates the OptionButton with preset options sorted by difficulty"""
	pass

func handle_preset_selection(selected_index: int) -> void:
	"""Handles user selection from preset dropdown"""
	pass

func update_preview_display(preset: PresetOptionInterface) -> void:
	"""Updates the UI preview with difficulty and gameplay impact"""
	pass

func validate_selection() -> bool:
	"""Validates that a preset has been selected before allowing progression"""
	return false

func get_selected_preset_id() -> String:
	"""Returns the ID of the currently selected preset"""
	return ""

func save_character_data() -> void:
	"""Saves character data including selected preset ID"""
	pass

## UI state management
func clear_selection() -> void:
	"""Clears current preset selection and preview"""
	pass

func enable_preset_selection(enabled: bool) -> void:
	"""Enables or disables preset selection interface"""
	pass

func show_selection_error(message: String) -> void:
	"""Displays validation error message to user"""
	pass

func hide_selection_error() -> void:
	"""Hides validation error message"""
	pass

## Migration and compatibility methods
func migrate_legacy_background(old_background_text: String) -> String:
	"""Attempts to map legacy free-text background to closest preset ID"""
	return ""

func handle_missing_preset(preset_id: String) -> String:
	"""Handles case where saved preset ID is no longer available"""
	return ""

func get_character_data_with_preset() -> Dictionary:
	"""Returns complete character data including preset information"""
	return {}

## Contract validation for UI elements
func _validate_ui_elements() -> bool:
	"""Validates that required UI elements exist and are properly configured"""
	# Check for OptionButton node
	var preset_dropdown = get_node_or_null("PresetDropdown")
	if not preset_dropdown or not preset_dropdown is OptionButton:
		push_error("PresetDropdown OptionButton not found")
		return false

	# Check for preview labels
	var difficulty_label = get_node_or_null("DifficultyLabel")
	var impact_label = get_node_or_null("ImpactLabel")
	if not difficulty_label or not impact_label:
		push_error("Preview labels not found")
		return false

	# Check for error display
	var error_label = get_node_or_null("ErrorLabel")
	if not error_label:
		push_warning("Error display label not found - validation feedback may be limited")

	return true

func _validate_signal_connections() -> bool:
	"""Validates that required signals are properly connected"""
	var preset_dropdown = get_node_or_null("PresetDropdown") as OptionButton
	if preset_dropdown:
		if not preset_dropdown.item_selected.is_connected(handle_preset_selection):
			push_error("OptionButton item_selected signal not connected")
			return false

	return true

## Testing support methods
func _get_test_preset_data() -> CharacterBackgroundPresetsInterface:
	"""Returns test preset data for unit testing"""
	return null

func _simulate_preset_selection(preset_index: int) -> void:
	"""Simulates user preset selection for testing"""
	pass

func _get_ui_state() -> Dictionary:
	"""Returns current UI state for testing validation"""
	return {}