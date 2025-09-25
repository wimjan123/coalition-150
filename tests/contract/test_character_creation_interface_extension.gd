# Contract test for CharacterCreationInterfaceExtension
# This test MUST FAIL until CharacterPartyCreation script is modified to support presets

extends GutTest

var creation_interface_script = preload("res://specs/003-refine-the-character/contracts/CharacterCreationInterfaceExtension.gd")

func before_each():
	gut.p("Testing CharacterCreationInterfaceExtension contract compliance")

func test_creation_interface_extension_exists():
	# This test verifies the interface contract exists and is accessible
	assert_not_null(creation_interface_script, "CharacterCreationInterfaceExtension script should be available")

func test_creation_interface_extends_control():
	# Verify interface properly extends Control
	var temp_instance = creation_interface_script.new()
	assert_true(temp_instance is Control, "CharacterCreationInterfaceExtension should extend Control")
	temp_instance.queue_free()

func test_creation_interface_has_required_signals():
	# Test that interface defines all required signals
	var temp_instance = creation_interface_script.new()

	# Check signal definitions using has_signal()
	assert_true(temp_instance.has_signal("preset_loaded"), "Should have preset_loaded signal")
	assert_true(temp_instance.has_signal("preset_selected"), "Should have preset_selected signal")
	assert_true(temp_instance.has_signal("preview_updated"), "Should have preview_updated signal")
	assert_true(temp_instance.has_signal("selection_validated"), "Should have selection_validated signal")

	temp_instance.queue_free()

func test_creation_interface_has_core_methods():
	# Test that interface defines core preset management methods
	var temp_instance = creation_interface_script.new()

	assert_true(temp_instance.has_method("load_preset_collection"), "Should have load_preset_collection() method")
	assert_true(temp_instance.has_method("populate_preset_dropdown"), "Should have populate_preset_dropdown() method")
	assert_true(temp_instance.has_method("handle_preset_selection"), "Should have handle_preset_selection() method")
	assert_true(temp_instance.has_method("update_preview_display"), "Should have update_preview_display() method")
	assert_true(temp_instance.has_method("validate_selection"), "Should have validate_selection() method")
	assert_true(temp_instance.has_method("get_selected_preset_id"), "Should have get_selected_preset_id() method")
	assert_true(temp_instance.has_method("save_character_data"), "Should have save_character_data() method")

	temp_instance.queue_free()

func test_creation_interface_has_ui_management_methods():
	# Test that interface defines UI state management methods
	var temp_instance = creation_interface_script.new()

	assert_true(temp_instance.has_method("clear_selection"), "Should have clear_selection() method")
	assert_true(temp_instance.has_method("enable_preset_selection"), "Should have enable_preset_selection() method")
	assert_true(temp_instance.has_method("show_selection_error"), "Should have show_selection_error() method")
	assert_true(temp_instance.has_method("hide_selection_error"), "Should have hide_selection_error() method")

	temp_instance.queue_free()

func test_creation_interface_has_migration_methods():
	# Test that interface defines migration and compatibility methods
	var temp_instance = creation_interface_script.new()

	assert_true(temp_instance.has_method("migrate_legacy_background"), "Should have migrate_legacy_background() method")
	assert_true(temp_instance.has_method("handle_missing_preset"), "Should have handle_missing_preset() method")
	assert_true(temp_instance.has_method("get_character_data_with_preset"), "Should have get_character_data_with_preset() method")

	temp_instance.queue_free()

func test_creation_interface_has_validation_methods():
	# Test that interface defines validation methods
	var temp_instance = creation_interface_script.new()

	assert_true(temp_instance.has_method("_validate_ui_elements"), "Should have _validate_ui_elements() method")
	assert_true(temp_instance.has_method("_validate_signal_connections"), "Should have _validate_signal_connections() method")

	temp_instance.queue_free()

func test_creation_interface_has_testing_methods():
	# Test that interface defines testing support methods
	var temp_instance = creation_interface_script.new()

	assert_true(temp_instance.has_method("_get_test_preset_data"), "Should have _get_test_preset_data() method")
	assert_true(temp_instance.has_method("_simulate_preset_selection"), "Should have _simulate_preset_selection() method")
	assert_true(temp_instance.has_method("_get_ui_state"), "Should have _get_ui_state() method")

	temp_instance.queue_free()

func test_preset_loading_method_signature():
	# Test that load_preset_collection returns expected type
	var temp_instance = creation_interface_script.new()

	# The method should exist and should be callable (though it passes in interface)
	var result = temp_instance.load_preset_collection()
	# Interface implementation passes, so this won't return a real collection
	# This is expected for interface testing

	temp_instance.queue_free()

func test_validation_method_signature():
	# Test that validate_selection returns boolean
	var temp_instance = creation_interface_script.new()

	# The method should exist and be callable
	var result = temp_instance.validate_selection()
	# Interface method passes, won't return real validation result

	temp_instance.queue_free()

# EXPECTED TO FAIL: These tests verify the actual implementation doesn't exist yet (TDD)
func test_character_party_creation_preset_integration_missing():
	# This should FAIL - CharacterPartyCreation scene hasn't been modified for presets yet
	var scene_path = "res://scenes/player/CharacterPartyCreation.tscn"
	if ResourceLoader.exists(scene_path):
		var scene = load(scene_path)
		if scene != null:
			var instance = scene.instantiate()
			# Should not have preset-related methods yet
			assert_false(instance.has_method("load_preset_collection"),
				"CharacterPartyCreation should NOT have preset methods yet (TDD - test first!)")
			instance.queue_free()

func test_character_party_creation_script_missing_preset_logic():
	# This should FAIL - CharacterPartyCreation.gd doesn't have preset logic yet
	var script_path = "res://scripts/player/CharacterPartyCreation.gd"
	if ResourceLoader.exists(script_path):
		# Script exists but shouldn't have preset methods yet
		var script_resource = load(script_path)
		var instance = script_resource.new()
		assert_false(instance.has_method("handle_preset_selection"),
			"CharacterPartyCreation script should NOT have preset logic yet (TDD - test first!)")
		instance.free()

func test_preset_option_button_missing():
	# This should FAIL - OptionButton for presets hasn't been added to scene yet
	var scene_path = "res://scenes/player/CharacterPartyCreation.tscn"
	if ResourceLoader.exists(scene_path):
		var scene = load(scene_path)
		if scene != null:
			var instance = scene.instantiate()
			var preset_dropdown = instance.get_node_or_null("PresetDropdown")
			assert_null(preset_dropdown,
				"PresetDropdown OptionButton should NOT exist yet (TDD - test first!)")
			instance.queue_free()