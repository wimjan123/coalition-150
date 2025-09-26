extends GutTest

# Test GameState persistence through autoload
# Tests must FAIL before implementation exists

func before_each():
	pass

func test_game_state_autoload_exists():
	# This will succeed once autoload is configured
	assert_not_null(GameState, "GameState autoload should exist")

func test_game_state_persistence_interface():
	assert_has_method(GameState, "save_game")
	assert_has_method(GameState, "load_game")
	assert_has_method(GameState, "get_current_state")
	assert_has_method(GameState, "update_state")

func test_game_state_default_values():
	var current_state = GameState.get_current_state()
	assert_not_null(current_state, "Should have current state")
	assert_eq(current_state.approval_rating, 50.0, "Default approval should be 50.0")
	assert_eq(current_state.party_treasury, 100000, "Default treasury should be 100000")
	assert_eq(current_state.seats_in_parliament, 75, "Default seats should be 75")

func test_game_state_save_load():
	# Modify state
	var initial_state = GameState.get_current_state()
	initial_state.approval_rating = 65.5
	initial_state.party_treasury = 85000
	GameState.update_state(initial_state)

	# Save game
	var save_result = GameState.save_game("test_save.tres")
	assert_eq(save_result, OK, "Should save successfully")

	# Reset state
	var reset_state = GameState.create_default_state()
	GameState.update_state(reset_state)

	# Load game
	var load_result = GameState.load_game("test_save.tres")
	assert_eq(load_result, OK, "Should load successfully")

	# Verify loaded state
	var loaded_state = GameState.get_current_state()
	assert_eq(loaded_state.approval_rating, 65.5, "Should restore approval rating")
	assert_eq(loaded_state.party_treasury, 85000, "Should restore treasury")

func test_game_state_validation():
	var invalid_state = GameState.create_default_state()
	invalid_state.approval_rating = 150.0  # Invalid

	var result = GameState.update_state(invalid_state)
	assert_false(result, "Should reject invalid state")

func test_game_state_stats_tracking():
	var initial_state = GameState.get_current_state()

	# Test stat updates
	GameState.update_approval_rating(10.0)
	GameState.update_treasury(-5000)
	GameState.update_seats(2)

	var updated_state = GameState.get_current_state()
	assert_eq(updated_state.approval_rating, initial_state.approval_rating + 10.0, "Should update approval")
	assert_eq(updated_state.party_treasury, initial_state.party_treasury - 5000, "Should update treasury")
	assert_eq(updated_state.seats_in_parliament, initial_state.seats_in_parliament + 2, "Should update seats")

func test_game_state_crisis_detection():
	var state = GameState.get_current_state()
	state.approval_rating = 10.0  # Crisis level
	GameState.update_state(state)

	assert_true(GameState.is_in_crisis(), "Should detect crisis mode")

	state.approval_rating = 90.0  # High approval
	GameState.update_state(state)

	assert_true(GameState.has_special_opportunities(), "Should detect special opportunities")