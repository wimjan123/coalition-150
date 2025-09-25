extends GutTest

# Contract test for SceneManagerInterface
# These tests MUST FAIL before implementation exists

class_name TestSceneManagerInterface

var scene_manager_interface: SceneManagerInterface

func before_each():
	# This will fail until SceneManagerInterface is implemented
	scene_manager_interface = SceneManagerInterface.new()

func test_interface_exists():
	# Test: SceneManagerInterface class exists
	assert_not_null(scene_manager_interface, "SceneManagerInterface should exist")

func test_has_required_signals():
	# Test: All required signals are defined
	assert_true(scene_manager_interface.has_signal("transition_started"), "Should have transition_started signal")
	assert_true(scene_manager_interface.has_signal("transition_progress_updated"), "Should have transition_progress_updated signal")
	assert_true(scene_manager_interface.has_signal("transition_completed"), "Should have transition_completed signal")
	assert_true(scene_manager_interface.has_signal("transition_failed"), "Should have transition_failed signal")

func test_has_required_methods():
	# Test: All required interface methods exist
	assert_true(scene_manager_interface.has_method("transition_to_scene"), "Should have transition_to_scene method")
	assert_true(scene_manager_interface.has_method("switch_scene_immediate"), "Should have switch_scene_immediate method")
	assert_true(scene_manager_interface.has_method("get_current_scene_path"), "Should have get_current_scene_path method")
	assert_true(scene_manager_interface.has_method("is_transitioning"), "Should have is_transitioning method")

func test_transition_to_scene_method():
	# Test: transition_to_scene accepts scene path and fade duration
	# This will fail until implementation exists
	scene_manager_interface.transition_to_scene("res://scenes/main/MainMenu.tscn", 1.0)

func test_current_scene_tracking():
	# Test: get_current_scene_path returns string
	# This will fail until implementation exists
	var current_scene = scene_manager_interface.get_current_scene_path()
	assert_typeof(current_scene, TYPE_STRING, "Current scene path should be string")

func test_transition_state_tracking():
	# Test: is_transitioning returns boolean
	# This will fail until implementation exists
	var is_transitioning = scene_manager_interface.is_transitioning()
	assert_typeof(is_transitioning, TYPE_BOOL, "is_transitioning should return boolean")

func test_configuration_properties():
	# Test: Configuration properties exist with correct defaults
	assert_true("default_fade_duration" in scene_manager_interface, "Should have default_fade_duration property")
	assert_true("fade_color" in scene_manager_interface, "Should have fade_color property")
	assert_eq(scene_manager_interface.default_fade_duration, 1.0, "Default fade duration should be 1.0")

func test_scene_validation():
	# Test: validate_scene_path method works correctly
	# This will fail until validation logic exists
	assert_true(scene_manager_interface.validate_scene_path("res://test.tscn"), "Should validate proper .tscn paths")
	assert_false(scene_manager_interface.validate_scene_path("invalid"), "Should reject invalid paths")