extends GutTest

# Test GameState resource class
# Tests must FAIL before implementation exists

func before_each():
	pass

func test_game_state_resource_exists():
	# This test will fail until GameState class is implemented
	var game_state = GameState.new()
	assert_not_null(game_state, "GameState resource should be creatable")

func test_game_state_has_required_fields():
	var game_state = GameState.new()

	# Test default values
	assert_eq(game_state.approval_rating, 50.0, "Default approval rating should be 50.0")
	assert_eq(game_state.party_treasury, 100000, "Default treasury should be 100000")
	assert_eq(game_state.seats_in_parliament, 75, "Default seats should be 75")
	assert_not_null(game_state.current_date, "Should have GameDate")
	assert_eq(game_state.time_speed, TimeSpeed.NORMAL, "Default time speed should be normal")
	assert_false(game_state.is_paused, "Should not be paused by default")

func test_game_state_validation():
	var game_state = GameState.new()

	# Test approval rating bounds
	game_state.approval_rating = -10.0
	assert_false(game_state.is_valid(), "Negative approval rating should be invalid")

	game_state.approval_rating = 110.0
	assert_false(game_state.is_valid(), "Approval rating over 100 should be invalid")

	game_state.approval_rating = 75.0
	assert_true(game_state.is_valid(), "Valid approval rating should pass")

func test_game_state_serialization():
	var game_state = GameState.new()
	game_state.approval_rating = 65.5
	game_state.party_treasury = 85000

	# Test resource saving/loading
	var path = "user://test_game_state.tres"
	var result = ResourceSaver.save(game_state, path)
	assert_eq(result, OK, "Should save successfully")

	var loaded_state = ResourceLoader.load(path) as GameState
	assert_not_null(loaded_state, "Should load successfully")
	assert_eq(loaded_state.approval_rating, 65.5, "Should preserve approval rating")
	assert_eq(loaded_state.party_treasury, 85000, "Should preserve treasury")