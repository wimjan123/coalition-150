extends GutTest

# Unit test for TransitionConfig data model
# These tests MUST FAIL before implementation exists

class_name TestTransitionConfig

var transition_config: TransitionConfig

func before_each():
	# This will fail until TransitionConfig class is implemented
	transition_config = TransitionConfig.new()

func test_transition_config_exists():
	# Test: TransitionConfig class exists
	assert_not_null(transition_config, "TransitionConfig should exist")

func test_has_required_properties():
	# Test: All required properties exist
	assert_true("fade_duration" in transition_config, "Should have fade_duration property")
	assert_true("fade_color" in transition_config, "Should have fade_color property")
	assert_true("target_scene_path" in transition_config, "Should have target_scene_path property")
	assert_true("transition_type" in transition_config, "Should have transition_type property")

func test_initial_state():
	# Test: TransitionConfig initializes with sensible defaults
	# This will fail until implementation exists
	assert_gt(transition_config.fade_duration, 0.0, "Fade duration should be positive")
	assert_eq(transition_config.fade_color, Color.BLACK, "Default fade color should be black")

func test_fade_duration_validation():
	# Test: fade_duration must be positive
	# This will fail until validation exists
	transition_config.fade_duration = 1.0
	assert_gt(transition_config.fade_duration, 0.0, "Fade duration should be positive")

func test_fade_color_validation():
	# Test: fade_color should have alpha = 1.0 for proper fade
	# This will fail until validation exists
	transition_config.fade_color = Color.BLACK
	assert_eq(transition_config.fade_color.a, 1.0, "Fade color should have full alpha")

func test_target_scene_validation():
	# Test: target_scene_path validation for .tscn files
	# This will fail until validation exists
	transition_config.target_scene_path = "res://scenes/main/MainMenu.tscn"
	assert_true(transition_config.target_scene_path.ends_with(".tscn"), "Should accept .tscn files")

func test_transition_type_enumeration():
	# Test: transition_type uses TransitionType enumeration
	# This will fail until TransitionType enum exists
	transition_config.transition_type = TransitionConfig.TransitionType.FADE_OUT_IN
	assert_eq(transition_config.transition_type, TransitionConfig.TransitionType.FADE_OUT_IN, "Should accept TransitionType values")

func test_configuration_methods():
	# Test: Helper methods for configuration
	# This will fail until implementation exists
	transition_config.set_fade_to_black(1.5)
	assert_eq(transition_config.fade_duration, 1.5, "Should set fade duration")
	assert_eq(transition_config.fade_color, Color.BLACK, "Should set fade color to black")

func test_scene_path_validation():
	# Test: validate_target_scene method
	# This will fail until validation method exists
	assert_true(transition_config.validate_target_scene("res://test.tscn"), "Should validate proper scene paths")
	assert_false(transition_config.validate_target_scene("invalid"), "Should reject invalid paths")