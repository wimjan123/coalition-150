# PlayerData - Root save data container for the player's game state
# Stores all created characters and game metadata

class_name PlayerData
extends Resource

# All created characters/parties for this player
@export var characters: Array[CharacterData] = []

# Save version for future compatibility
@export var current_save_version: int = 1

# Creation timestamp
@export var created_at: String = ""

# Last modified timestamp
@export var last_modified: String = ""

func _init(p_characters: Array[CharacterData] = [], p_save_version: int = 1) -> void:
	characters = p_characters
	current_save_version = p_save_version
	created_at = Time.get_datetime_string_from_system()
	last_modified = created_at

# Add a new character to the player data
func add_character(character: CharacterData) -> void:
	if not character:
		push_error("Cannot add null character")
		return

	characters.append(character)
	update_modified_timestamp()
	emit_changed()

# Remove a character from the player data
func remove_character(character: CharacterData) -> bool:
	var index: int = characters.find(character)
	if index >= 0:
		characters.remove_at(index)
		update_modified_timestamp()
		emit_changed()
		return true
	return false

# Get character by party name (unique per player)
func get_character_by_party_name(party_name: String) -> CharacterData:
	for character in characters:
		if character.party and character.party.party_name == party_name:
			return character
	return null

# Check if party name is unique within this player's characters
func is_party_name_unique(party_name: String) -> bool:
	return get_character_by_party_name(party_name) == null

# Get all party names for this player
func get_all_party_names() -> PackedStringArray:
	var names: PackedStringArray = PackedStringArray()
	for character in characters:
		if character.party:
			names.append(character.party.party_name)
	return names

# Update the last modified timestamp
func update_modified_timestamp() -> void:
	last_modified = Time.get_datetime_string_from_system()

# Validate player data integrity
func validate() -> bool:
	# Check save version is valid
	if current_save_version <= 0:
		push_error("Invalid save version: " + str(current_save_version))
		return false

	# Check party name uniqueness
	var party_names: Array = []
	for character in characters:
		if character.party:
			var party_name: String = character.party.party_name
			if party_name in party_names:
				push_error("Duplicate party name found: " + party_name)
				return false
			party_names.append(party_name)

	# Validate each character
	for character in characters:
		if not character.validate():
			return false

	return true