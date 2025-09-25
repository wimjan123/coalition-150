# AssetLoader Service Contract
# Defines the interface for asset loading functionality

class_name AssetLoaderInterface
extends RefCounted

# SIGNALS - Loading progress communication

## Emitted when an individual asset finishes loading
## @param asset_path: String - Path of the loaded asset
## @param success: bool - Whether loading succeeded
signal asset_loaded(asset_path: String, success: bool)

## Emitted when overall progress changes
## @param progress: float - Overall progress (0.0 to 1.0)
## @param assets_loaded: int - Number of assets completed
## @param total_assets: int - Total assets to load
signal progress_updated(progress: float, assets_loaded: int, total_assets: int)

## Emitted when all assets finish loading
## @param success: bool - Whether all assets loaded successfully
signal loading_completed(success: bool)

## Emitted when loading fails and retry is attempted
## @param attempt: int - Current retry attempt (1-3)
signal retry_started(attempt: int)

## Emitted when maximum retries exceeded
## @param final_error: String - Final error message
signal loading_failed(final_error: String)

# PUBLIC METHODS - Asset loading interface

## Add asset to loading queue
## @param asset_path: String - Godot resource path
## @param priority: int - Loading priority (1=highest)
func add_asset(asset_path: String, priority: int = 5) -> void:
	assert(false, "Must be implemented by concrete class")

## Start loading all queued assets
func start_loading() -> void:
	assert(false, "Must be implemented by concrete class")

## Stop loading process and clear queue
func stop_loading() -> void:
	assert(false, "Must be implemented by concrete class")

## Check if specific asset is loaded
## @param asset_path: String - Path to check
## @return bool - True if asset is loaded
func is_asset_loaded(asset_path: String) -> bool:
	assert(false, "Must be implemented by concrete class")
	return false

## Get loaded asset resource
## @param asset_path: String - Path of asset to retrieve
## @return Resource - Loaded resource or null
func get_loaded_asset(asset_path: String) -> Resource:
	assert(false, "Must be implemented by concrete class")
	return null

## Get current loading progress
## @return float - Progress from 0.0 to 1.0
func get_progress() -> float:
	assert(false, "Must be implemented by concrete class")
	return 0.0

## Get loading statistics
## @return Dictionary - Stats with keys: loaded, total, failed, retry_count
func get_stats() -> Dictionary:
	assert(false, "Must be implemented by concrete class")
	return {}

# CONFIGURATION PROPERTIES

## Maximum retry attempts for failed assets
@export var max_retries: int = 3

## Timeout per individual asset in seconds
@export var asset_timeout: float = 2.0

## Whether to use threaded loading
@export var use_threading: bool = true

## Whether to preload all assets into memory
@export var preload_resources: bool = false

# VALIDATION METHODS

## Validate asset path format
## @param asset_path: String - Path to validate
## @return bool - True if path is valid
func validate_asset_path(asset_path: String) -> bool:
	if not asset_path.begins_with("res://"):
		push_error("Asset path must start with 'res://': " + asset_path)
		return false

	if not ResourceLoader.exists(asset_path):
		push_error("Asset does not exist: " + asset_path)
		return false

	return true

## Validate loading configuration
## @return bool - True if configuration is valid
func validate_config() -> bool:
	if max_retries < 0 or max_retries > 10:
		push_error("max_retries must be between 0 and 10")
		return false

	if asset_timeout <= 0.0:
		push_error("asset_timeout must be positive")
		return false

	return true

# REQUIRED ASSET TYPES

## Standard assets that must be loadable
enum AssetType {
	SCENE = 0,     ## .tscn files
	TEXTURE = 1,   ## .png, .jpg, .svg files
	FONT = 2,      ## .ttf, .otf files
	AUDIO = 3,     ## .ogg, .wav files
	RESOURCE = 4   ## .tres, .res files
}

## Get file extension for asset type
## @param type: AssetType - Asset type to check
## @return Array[String] - Valid extensions for type
func get_valid_extensions(type: AssetType) -> Array[String]:
	match type:
		AssetType.SCENE:
			return ["tscn"]
		AssetType.TEXTURE:
			return ["png", "jpg", "jpeg", "svg", "webp"]
		AssetType.FONT:
			return ["ttf", "otf", "woff2"]
		AssetType.AUDIO:
			return ["ogg", "wav", "mp3"]
		AssetType.RESOURCE:
			return ["tres", "res"]
		_:
			return []

## Detect asset type from file extension
## @param asset_path: String - Path to analyze
## @return AssetType - Detected type or -1 if unknown
func detect_asset_type(asset_path: String) -> AssetType:
	var extension = asset_path.get_extension().to_lower()

	for asset_type in AssetType.values():
		if extension in get_valid_extensions(asset_type):
			return asset_type

	return -1  # Unknown type