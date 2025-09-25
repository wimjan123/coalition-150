# AssetItem - Represents individual assets for loading
# Implements data model with validation and type enumeration

class_name AssetItem
extends RefCounted

# Asset type enumeration
enum AssetType {
	SCENE = 1,
	TEXTURE = 2,
	FONT = 3,
	AUDIO = 4
}

# Core properties
@export var resource_path: String = "": set = set_resource_path
@export var asset_type: AssetType = AssetType.TEXTURE
@export var load_priority: int = 5: set = set_load_priority
@export var is_loaded: bool = false
@export var load_time_ms: int = 0
@export var file_size_kb: int = 0: set = set_file_size_kb

func _init(path: String = "", type: AssetType = AssetType.TEXTURE, priority: int = 5):
	resource_path = path
	asset_type = type
	load_priority = priority
	if path != "":
		asset_type = detect_asset_type_from_path(path)

# Validation setters
func set_resource_path(value: String) -> void:
	if value != "" and not value.begins_with("res://"):
		push_error("Resource path must start with 'res://': " + value)
		return
	resource_path = value

func set_load_priority(value: int) -> void:
	load_priority = clampi(value, 1, 10)

func set_file_size_kb(value: int) -> void:
	if value < 0:
		push_error("File size must be positive: " + str(value))
		return
	file_size_kb = value

# Asset type detection
func detect_asset_type_from_path(path: String) -> AssetType:
	var extension = path.get_extension().to_lower()

	match extension:
		"tscn":
			return AssetType.SCENE
		"png", "jpg", "jpeg", "svg", "webp":
			return AssetType.TEXTURE
		"ttf", "otf", "woff2":
			return AssetType.FONT
		"ogg", "wav", "mp3":
			return AssetType.AUDIO
		_:
			return AssetType.TEXTURE  # Default fallback

# Loading completion
func complete_loading(load_duration_ms: int = 0) -> void:
	is_loaded = true
	load_time_ms = load_duration_ms
	print("Asset loaded: ", resource_path, " (", load_time_ms, "ms)")

func reset_loading() -> void:
	is_loaded = false
	load_time_ms = 0

# Validation methods
func validate() -> bool:
	if resource_path == "":
		push_error("Resource path cannot be empty")
		return false

	if not resource_path.begins_with("res://"):
		push_error("Invalid resource path format: " + resource_path)
		return false

	if load_priority < 1 or load_priority > 10:
		push_error("Load priority must be between 1-10: " + str(load_priority))
		return false

	if file_size_kb < 0:
		push_error("File size cannot be negative: " + str(file_size_kb))
		return false

	return true

func exists() -> bool:
	return ResourceLoader.exists(resource_path)

# Utility methods
func get_type_string() -> String:
	match asset_type:
		AssetType.SCENE: return "Scene"
		AssetType.TEXTURE: return "Texture"
		AssetType.FONT: return "Font"
		AssetType.AUDIO: return "Audio"
		_: return "Unknown"

func get_priority_string() -> String:
	match load_priority:
		1: return "Highest"
		2, 3: return "High"
		4, 5, 6: return "Medium"
		7, 8: return "Low"
		9, 10: return "Lowest"
		_: return "Unknown"

func get_asset_description() -> String:
	return "[%s] %s (Priority: %d, Size: %dKB)" % [get_type_string(), resource_path, load_priority, file_size_kb]
