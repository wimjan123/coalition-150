# SaveSystem - Handles saving and loading player data
# Uses Godot's user:// directory for cross-platform save data

class_name SaveSystem
extends RefCounted

# Save file paths
const SAVE_DIR: String = "user://save_data/"
const PLAYER_DATA_FILE: String = "player_data.tres"
const SETTINGS_FILE: String = "settings.cfg"

# File paths
var player_data_path: String
var settings_path: String

func _init() -> void:
	player_data_path = SAVE_DIR + PLAYER_DATA_FILE
	settings_path = SAVE_DIR + SETTINGS_FILE
	_ensure_save_directory()

# Ensure save directory exists
func _ensure_save_directory() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		var dir: DirAccess = DirAccess.open("user://")
		if dir:
			var error: Error = dir.make_dir_recursive("save_data")
			if error != OK:
				push_error("Failed to create save directory: " + str(error))
		else:
			push_error("Failed to access user:// directory")

# Check if save data exists
func has_save_data() -> bool:
	return FileAccess.file_exists(player_data_path)

# Save player data
func save_player_data(player_data: PlayerData) -> bool:
	if not player_data:
		push_error("Cannot save null player data")
		return false

	if not player_data.validate():
		push_error("Player data validation failed, cannot save")
		return false

	# Update modification timestamp
	player_data.update_modified_timestamp()

	# Save using ResourceSaver
	var error: Error = ResourceSaver.save(player_data, player_data_path)

	if error == OK:
		print("Player data saved successfully to: ", player_data_path)
		return true
	else:
		push_error("Failed to save player data: " + str(error))
		return false

# Load player data
func load_player_data() -> PlayerData:
	if not has_save_data():
		print("No save data found, creating new PlayerData")
		return PlayerData.new()

	var player_data: Resource = ResourceLoader.load(player_data_path)

	if player_data is PlayerData:
		var typed_data: PlayerData = player_data as PlayerData

		# Validate loaded data
		if typed_data.validate():
			print("Player data loaded successfully from: ", player_data_path)
			return typed_data
		else:
			push_error("Loaded player data is invalid, creating new data")
			return PlayerData.new()
	else:
		push_error("Save file is corrupted or invalid, creating new data")
		return PlayerData.new()

# Delete save data
func delete_save_data() -> bool:
	if not has_save_data():
		print("No save data to delete")
		return true

	var dir: DirAccess = DirAccess.open("user://")
	if dir:
		var error: Error = dir.remove(player_data_path)
		if error == OK:
			print("Save data deleted successfully")
			return true
		else:
			push_error("Failed to delete save data: " + str(error))
			return false
	else:
		push_error("Failed to access user:// directory for deletion")
		return false

# Create backup of save data
func backup_save_data() -> bool:
	if not has_save_data():
		print("No save data to backup")
		return false

	var backup_path: String = SAVE_DIR + "player_data_backup_" + Time.get_datetime_string_from_system().replace(":", "-") + ".tres"

	var dir: DirAccess = DirAccess.open("user://")
	if dir:
		var error: Error = dir.copy(player_data_path, backup_path)
		if error == OK:
			print("Save data backed up to: ", backup_path)
			return true
		else:
			push_error("Failed to backup save data: " + str(error))
			return false
	else:
		push_error("Failed to access user:// directory for backup")
		return false

# Get save data info
func get_save_info() -> Dictionary:
	if not has_save_data():
		return {}

	var file: FileAccess = FileAccess.open(player_data_path, FileAccess.READ)
	if file:
		var info: Dictionary = {
			"exists": true,
			"size_bytes": file.get_length(),
			"modified_time": FileAccess.get_modified_time(player_data_path)
		}
		file.close()

		# Try to load and get additional info
		var player_data: PlayerData = load_player_data()
		if player_data:
			info["character_count"] = player_data.characters.size()
			info["save_version"] = player_data.current_save_version
			info["created_at"] = player_data.created_at
			info["last_modified"] = player_data.last_modified

		return info
	else:
		return {"exists": false}

# Quick save - saves current character to player data
func quick_save_character(character: CharacterData) -> bool:
	if not character:
		push_error("Cannot quick save null character")
		return false

	var player_data: PlayerData = load_player_data()

	# Check if character already exists (update) or add new
	var existing_character: CharacterData = null
	if character.party:
		existing_character = player_data.get_character_by_party_name(character.party.party_name)

	if existing_character:
		# Update existing character
		var index: int = player_data.characters.find(existing_character)
		if index >= 0:
			player_data.characters[index] = character
			print("Updated existing character: ", character.character_name)
	else:
		# Add new character
		player_data.add_character(character)
		print("Added new character: ", character.character_name)

	return save_player_data(player_data)

# Get all party names from save data
func get_all_party_names() -> PackedStringArray:
	var player_data: PlayerData = load_player_data()
	return player_data.get_all_party_names()

# Check if party name is unique
func is_party_name_unique(party_name: String) -> bool:
	var player_data: PlayerData = load_player_data()
	return player_data.is_party_name_unique(party_name)

# Get character by party name
func get_character_by_party_name(party_name: String) -> CharacterData:
	var player_data: PlayerData = load_player_data()
	return player_data.get_character_by_party_name(party_name)

# Save settings
func save_settings(settings: Dictionary) -> bool:
	var config: ConfigFile = ConfigFile.new()

	for section_name in settings:
		var section_data: Dictionary = settings[section_name]
		for key in section_data:
			config.set_value(section_name, key, section_data[key])

	var error: Error = config.save(settings_path)
	if error == OK:
		print("Settings saved successfully")
		return true
	else:
		push_error("Failed to save settings: " + str(error))
		return false

# Load settings
func load_settings() -> Dictionary:
	var settings: Dictionary = {}
	var config: ConfigFile = ConfigFile.new()

	var error: Error = config.load(settings_path)
	if error != OK:
		print("No settings file found or failed to load, using defaults")
		return settings

	for section in config.get_sections():
		settings[section] = {}
		for key in config.get_section_keys(section):
			settings[section][key] = config.get_value(section, key)

	return settings

# Get save directory path for debugging
func get_save_directory_path() -> String:
	return ProjectSettings.globalize_path(SAVE_DIR)

# Cleanup old backups (keep only the most recent 5)
func cleanup_old_backups() -> void:
	var dir: DirAccess = DirAccess.open(SAVE_DIR)
	if not dir:
		return

	var backup_files: Array = []
	dir.list_dir_begin()
	var file_name: String = dir.get_next()

	while file_name != "":
		if file_name.begins_with("player_data_backup_") and file_name.ends_with(".tres"):
			backup_files.append({
				"name": file_name,
				"modified_time": FileAccess.get_modified_time(SAVE_DIR + file_name)
			})
		file_name = dir.get_next()

	# Sort by modification time (newest first)
	backup_files.sort_custom(func(a, b): return a.modified_time > b.modified_time)

	# Remove old backups (keep only 5 most recent)
	for i in range(5, backup_files.size()):
		var error: Error = dir.remove(backup_files[i].name)
		if error == OK:
			print("Cleaned up old backup: ", backup_files[i].name)
		else:
			push_warning("Failed to remove old backup: " + backup_files[i].name)