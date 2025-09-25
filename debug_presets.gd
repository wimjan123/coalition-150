# Debug script to check preset loading
# Run this from Godot's script editor to debug the preset loading issue

extends RefCounted

static func debug_preset_loading():
	print("=== PRESET LOADING DEBUG ===")

	# Check if resource file exists
	var preset_path = "res://assets/data/CharacterBackgroundPresets.tres"
	print("Resource exists: ", ResourceLoader.exists(preset_path))

	# Try to load the resource
	var preset_resource = load(preset_path)
	print("Resource loaded: ", preset_resource != null)

	if preset_resource:
		print("Resource type: ", preset_resource.get_class())
		print("Is CharacterBackgroundPresets: ", preset_resource is CharacterBackgroundPresets)

		if preset_resource is CharacterBackgroundPresets:
			var presets = preset_resource as CharacterBackgroundPresets
			print("Preset count: ", presets.preset_options.size())
			print("Version: ", presets.version)
			print("Is valid: ", presets.is_valid())

			if presets.preset_options.size() > 0:
				print("First preset ID: ", presets.preset_options[0].id)
				print("First preset name: ", presets.preset_options[0].display_name)
		else:
			print("ERROR: Resource is not CharacterBackgroundPresets type!")
	else:
		print("ERROR: Failed to load resource!")

	# Check class registration
	print("PresetOption class exists: ", ClassDB.class_exists("PresetOption"))
	print("CharacterBackgroundPresets class exists: ", ClassDB.class_exists("CharacterBackgroundPresets"))

	print("=== END DEBUG ===")

# Call this function to run the debug
static func run():
	debug_preset_loading()