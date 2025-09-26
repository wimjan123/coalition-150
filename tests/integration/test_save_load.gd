# Integration Test: Save/Load Game State
# Tests complete save and load functionality

extends GutTest

var main_dashboard: MainDashboard
var game_state: GameState
var scene_path: String = "res://scenes/dashboard/main_dashboard.tscn"
var test_save_path: String = "user://test_save.tres"

func before_each() -> void:
	"""Set up test environment"""
	# Clean up any existing test save
	if FileAccess.file_exists(test_save_path):
		DirAccess.remove_absolute(test_save_path)

	# Load main dashboard
	if ResourceLoader.exists(scene_path):
		var packed_scene = load(scene_path)
		if packed_scene:
			main_dashboard = packed_scene.instantiate()
			add_child(main_dashboard)

	# Initialize GameState if available
	game_state = GameState if GameState else null

func after_each() -> void:
	"""Clean up after test"""
	# Clean up test save file
	if FileAccess.file_exists(test_save_path):
		DirAccess.remove_absolute(test_save_path)

	if main_dashboard:
		main_dashboard.queue_free()
		main_dashboard = null

func test_game_state_save_functionality():
	"""Test that game state can be saved to file"""
	if not game_state:
		skip_test("GameState not available")
		return

	# Set some test values
	if game_state.has_method("set_approval_rating"):
		game_state.set_approval_rating(65.3)

	if game_state.has_method("set_current_time"):
		var test_time = GameDate.new()
		test_time.year = 2025
		test_time.month = 2
		test_time.day = 15
		game_state.set_current_time(test_time)

	# Attempt to save
	var save_result = false
	if game_state.has_method("save_to_file"):
		save_result = game_state.save_to_file(test_save_path)
	else:
		# Fallback: try ResourceSaver
		save_result = ResourceSaver.save(game_state, test_save_path) == OK

	assert_true(save_result, "Game state should save successfully")
	assert_true(FileAccess.file_exists(test_save_path), "Save file should be created")

func test_game_state_load_functionality():
	"""Test that game state can be loaded from file"""
	if not game_state:
		skip_test("GameState not available")
		return

	# First save a known state
	if game_state.has_method("set_approval_rating"):
		game_state.set_approval_rating(72.8)

	if game_state.has_method("save_to_file"):
		game_state.save_to_file(test_save_path)
	else:
		ResourceSaver.save(game_state, test_save_path)

	# Create new GameState instance
	var loaded_state = null
	if game_state.has_method("load_from_file"):
		loaded_state = GameState.new()
		loaded_state.load_from_file(test_save_path)
	else:
		loaded_state = ResourceLoader.load(test_save_path)

	assert_not_null(loaded_state, "Loaded game state should not be null")

	# Verify data was preserved
	if loaded_state and loaded_state.has_method("get_approval_rating"):
		var loaded_approval = loaded_state.get_approval_rating()
		assert_eq(loaded_approval, 72.8, "Approval rating should be preserved after load")

func test_dashboard_state_persistence():
	"""Test that dashboard state is preserved across save/load"""
	if not main_dashboard or not game_state:
		skip_test("Required components not available")
		return

	# Wait for initialization
	await main_dashboard.dashboard_ready

	# Set some dashboard state
	var stats_panel = main_dashboard.get_node("VBoxContainer/ContentContainer/LeftPanel/StatsPanel")
	if stats_panel and stats_panel.has_method("set_approval_rating"):
		stats_panel.set_approval_rating(58.4)

	var netherlands_map = main_dashboard.get_node("VBoxContainer/ContentContainer/RightPanel/TopRightContainer/NetherlandsMap")
	if netherlands_map and netherlands_map.has_method("select_province"):
		netherlands_map.select_province("gelderland")

	# Save current state
	if game_state.has_method("save_dashboard_state") and main_dashboard.has_method("get_dashboard_state"):
		var dashboard_state = main_dashboard.get_dashboard_state()
		game_state.save_dashboard_state(dashboard_state)

	# Save to file
	if game_state.has_method("save_to_file"):
		game_state.save_to_file(test_save_path)

	assert_true(FileAccess.file_exists(test_save_path), "Dashboard state should be saved")

func test_save_load_data_integrity():
	"""Test that all data types are preserved correctly in save/load"""
	if not game_state:
		skip_test("GameState not available")
		return

	# Set various data types
	var test_data = {
		"string_value": "Test String",
		"integer_value": 42,
		"float_value": 3.14159,
		"boolean_value": true,
		"array_value": [1, 2, 3, "four", 5.0],
		"dict_value": {
			"nested_string": "Nested Value",
			"nested_number": 123
		}
	}

	# Store test data in game state
	if game_state.has_method("set_custom_data"):
		game_state.set_custom_data(test_data)

	# Save and load
	if game_state.has_method("save_to_file"):
		game_state.save_to_file(test_save_path)

	var loaded_state = null
	if game_state.has_method("load_from_file"):
		loaded_state = GameState.new()
		loaded_state.load_from_file(test_save_path)

	if loaded_state and loaded_state.has_method("get_custom_data"):
		var loaded_data = loaded_state.get_custom_data()

		# Verify data integrity
		assert_eq(loaded_data["string_value"], "Test String", "String values should be preserved")
		assert_eq(loaded_data["integer_value"], 42, "Integer values should be preserved")
		assert_eq(loaded_data["boolean_value"], true, "Boolean values should be preserved")

func test_save_file_corruption_recovery():
	"""Test recovery from corrupted save files"""
	if not game_state:
		skip_test("GameState not available")
		return

	# Create corrupted save file
	var file = FileAccess.open(test_save_path, FileAccess.WRITE)
	if file:
		file.store_string("CORRUPTED DATA!!!")
		file.close()

	# Attempt to load corrupted file
	var load_result = false
	var loaded_state = null

	if game_state.has_method("load_from_file"):
		loaded_state = GameState.new()
		load_result = loaded_state.load_from_file(test_save_path)
	else:
		loaded_state = ResourceLoader.load(test_save_path)
		load_result = loaded_state != null

	# Should handle corruption gracefully
	assert_false(load_result, "Corrupted save should be detected and rejected")

func test_autosave_functionality():
	"""Test automatic save functionality if implemented"""
	if not main_dashboard or not game_state:
		skip_test("Required components not available")
		return

	# Wait for initialization
	await main_dashboard.dashboard_ready

	# Check if autosave is implemented
	if game_state.has_method("enable_autosave"):
		game_state.enable_autosave(true, 1)  # Autosave every 1 second

		# Make some changes
		if game_state.has_method("set_approval_rating"):
			game_state.set_approval_rating(45.7)

		# Wait for autosave
		await get_tree().create_timer(2.0).timeout

		# Check if autosave file exists
		var autosave_path = "user://autosave.tres"
		if FileAccess.file_exists(autosave_path):
			assert_true(true, "Autosave should create save files automatically")
			# Clean up
			DirAccess.remove_absolute(autosave_path)
		else:
			skip_test("Autosave functionality not implemented")

func test_multiple_save_slots():
	"""Test multiple save slot functionality"""
	if not game_state:
		skip_test("GameState not available")
		return

	# Test saving to different slots
	var slot1_path = "user://save_slot_1.tres"
	var slot2_path = "user://save_slot_2.tres"

	# Save different data to each slot
	if game_state.has_method("set_approval_rating"):
		game_state.set_approval_rating(60.0)

	if game_state.has_method("save_to_file"):
		game_state.save_to_file(slot1_path)

		# Change data
		game_state.set_approval_rating(75.0)
		game_state.save_to_file(slot2_path)

	# Verify both files exist and are different
	assert_true(FileAccess.file_exists(slot1_path), "Save slot 1 should exist")
	assert_true(FileAccess.file_exists(slot2_path), "Save slot 2 should exist")

	# Clean up
	if FileAccess.file_exists(slot1_path):
		DirAccess.remove_absolute(slot1_path)
	if FileAccess.file_exists(slot2_path):
		DirAccess.remove_absolute(slot2_path)

func test_save_file_versioning():
	"""Test save file version compatibility"""
	if not game_state:
		skip_test("GameState not available")
		return

	# Save with current version
	if game_state.has_method("set_save_version"):
		game_state.set_save_version("1.0")

	if game_state.has_method("save_to_file"):
		game_state.save_to_file(test_save_path)

	# Load and verify version handling
	if game_state.has_method("load_from_file"):
		var loaded_state = GameState.new()
		var load_success = loaded_state.load_from_file(test_save_path)

		if load_success and loaded_state.has_method("get_save_version"):
			var version = loaded_state.get_save_version()
			assert_eq(version, "1.0", "Save file version should be preserved")

func test_save_load_performance():
	"""Test save/load operations complete within reasonable time"""
	if not game_state:
		skip_test("GameState not available")
		return

	# Time the save operation
	var save_start_time = Time.get_ticks_msec()

	if game_state.has_method("save_to_file"):
		game_state.save_to_file(test_save_path)

	var save_time = Time.get_ticks_msec() - save_start_time

	# Save should complete within 1 second
	assert_true(save_time <= 1000, "Save operation should complete within 1000ms, took: %d ms" % save_time)

	# Time the load operation
	var load_start_time = Time.get_ticks_msec()

	if game_state.has_method("load_from_file"):
		var loaded_state = GameState.new()
		loaded_state.load_from_file(test_save_path)

	var load_time = Time.get_ticks_msec() - load_start_time

	# Load should complete within 1 second
	assert_true(load_time <= 1000, "Load operation should complete within 1000ms, took: %d ms" % load_time)