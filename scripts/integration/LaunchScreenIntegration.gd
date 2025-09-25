# LaunchScreenIntegration - Wiring between AssetLoader and LaunchScreen
# Handles signal connections and integration coordination

extends Node
class_name LaunchScreenIntegration

var launch_screen: LaunchScreen
var asset_loader: AssetLoader
var scene_manager: SceneManager

func _init(screen: LaunchScreen, loader: AssetLoader, manager: SceneManager):
	launch_screen = screen
	asset_loader = loader
	scene_manager = manager
	_connect_all_signals()

func _connect_all_signals() -> void:
	print("LaunchScreenIntegration: Connecting AssetLoader to LaunchScreen signals")

	# T027: Connect AssetLoader signals to LaunchScreen progress updates
	asset_loader.progress_updated.connect(launch_screen._on_progress_updated)
	asset_loader.loading_completed.connect(launch_screen._on_loading_completed)
	asset_loader.loading_failed.connect(launch_screen._on_loading_failed)
	asset_loader.retry_started.connect(launch_screen._on_retry_started)

	# T028: Connect LaunchScreen transition signals to SceneManager
	launch_screen.transition_requested.connect(_on_transition_requested)

	# Connect SceneManager signals back to LaunchScreen
	scene_manager.transition_completed.connect(launch_screen._on_transition_completed)
	scene_manager.transition_failed.connect(launch_screen._on_transition_failed)

	print("LaunchScreenIntegration: All signal connections established")

func _on_transition_requested(target_scene: String) -> void:
	print("LaunchScreenIntegration: Transition requested to: ", target_scene)
	scene_manager.transition_to_scene(target_scene, 1.0)