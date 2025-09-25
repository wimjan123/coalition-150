# Resource Validator utility for validating .tres resource files
# Used during testing to ensure resource integrity

class_name ResourceValidator
extends RefCounted

## Validates that a resource file can be loaded successfully
static func validate_resource_loading(resource_path: String) -> bool:
	if not ResourceLoader.exists(resource_path):
		push_error("Resource file does not exist: " + resource_path)
		return false

	var resource = load(resource_path)
	if resource == null:
		push_error("Failed to load resource: " + resource_path)
		return false

	return true

## Validates resource file format and structure
static func validate_resource_format(resource: Resource) -> bool:
	if resource == null:
		push_error("Resource is null")
		return false

	# Check that resource can be saved (validates internal structure)
	var temp_path = "user://temp_validation.tres"
	var error = ResourceSaver.save(resource, temp_path)

	if error != OK:
		push_error("Resource validation failed - cannot save resource")
		return false

	# Clean up temp file
	if FileAccess.file_exists(temp_path):
		DirAccess.remove_absolute_path(temp_path)

	return true

## Validates preset resource directory structure
static func validate_preset_directory_structure() -> bool:
	var dirs_to_check = ["assets/data/"]

	for dir_path in dirs_to_check:
		if not DirAccess.dir_exists_absolute(dir_path):
			push_error("Required directory missing: " + dir_path)
			return false

	return true

## Comprehensive resource validation for preset system
static func validate_preset_system_resources() -> bool:
	print("Validating preset system resource structure...")

	# Validate directory structure
	if not validate_preset_directory_structure():
		return false

	print("✓ Preset directory structure valid")
	return true