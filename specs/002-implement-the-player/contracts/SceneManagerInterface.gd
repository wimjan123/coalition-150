# SceneManagerInterface - Contract for global scene transition management
# Defines the required interface for the SceneManager autoload

extends Node
class_name SceneManagerInterface

# Scene transition signals
signal scene_change_started(from_scene: String, to_scene: String)
signal scene_change_completed(scene_path: String)
signal transition_fade_started()
signal transition_fade_completed()

# Core scene management methods
func change_scene_to_player_selection() -> void:
	# Navigate to character/party selection scene
	push_error("SceneManagerInterface.change_scene_to_player_selection() not implemented")

func change_scene_to_player_creation() -> void:
	# Navigate to character/party creation form
	push_error("SceneManagerInterface.change_scene_to_player_creation() not implemented")

func change_scene_to_interview() -> void:
	# Navigate to media interview scene
	push_error("SceneManagerInterface.change_scene_to_interview() not implemented")

func change_scene_to_main_menu() -> void:
	# Return to main menu after completion
	push_error("SceneManagerInterface.change_scene_to_main_menu() not implemented")

func change_scene_to_main_game() -> void:
	# Enter main campaign game after interview
	push_error("SceneManagerInterface.change_scene_to_main_game() not implemented")

# Transition configuration
func set_transition_duration(duration: float) -> void:
	# Configure fade transition timing
	push_error("SceneManagerInterface.set_transition_duration() not implemented")

func get_current_scene_path() -> String:
	# Return path of currently loaded scene
	push_error("SceneManagerInterface.get_current_scene_path() not implemented")
	return ""

# Save/Load integration
func has_save_data() -> bool:
	# Check if player save data exists
	push_error("SceneManagerInterface.has_save_data() not implemented")
	return false

func get_available_characters() -> Array[CharacterData]:
	# Get list of saved characters for selection
	push_error("SceneManagerInterface.get_available_characters() not implemented")
	return []

# Session management
func set_current_character(character: CharacterData) -> void:
	# Set active character for current session
	push_error("SceneManagerInterface.set_current_character() not implemented")

func get_current_character() -> CharacterData:
	# Get active character for current session
	push_error("SceneManagerInterface.get_current_character() not implemented")
	return null

func clear_session() -> void:
	# Clear temporary session data
	push_error("SceneManagerInterface.clear_session() not implemented")

# Validation methods
func validate_scene_transition(from_scene: String, to_scene: String) -> bool:
	# Validate if scene transition is allowed
	push_error("SceneManagerInterface.validate_scene_transition() not implemented")
	return false