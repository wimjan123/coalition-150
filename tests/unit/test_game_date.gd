extends GutTest

# Test GameDate resource class
# Tests must FAIL before implementation exists

func before_each():
	pass

func test_game_date_resource_exists():
	# This test will fail until GameDate class is implemented
	var game_date = GameDate.new()
	assert_not_null(game_date, "GameDate resource should be creatable")

func test_game_date_has_required_fields():
	var game_date = GameDate.new()

	# Test default values
	assert_eq(game_date.year, 2025, "Default year should be 2025")
	assert_eq(game_date.month, 1, "Default month should be 1")
	assert_eq(game_date.day, 1, "Default day should be 1")
	assert_eq(game_date.hour, 9, "Default hour should be 9")
	assert_eq(game_date.minute, 0, "Default minute should be 0")

func test_game_date_advance_time():
	var game_date = GameDate.new()
	game_date.hour = 10
	game_date.minute = 30

	# Advance by 90 minutes
	game_date.advance_time(90)

	assert_eq(game_date.hour, 12, "Hour should advance to 12")
	assert_eq(game_date.minute, 0, "Minute should be 0")

func test_game_date_display_string():
	var game_date = GameDate.new()
	game_date.year = 2025
	game_date.month = 3
	game_date.day = 15
	game_date.hour = 14
	game_date.minute = 30

	var display = game_date.to_display_string()
	assert_ne(display, "", "Should return non-empty display string")
	assert_true(display.contains("2025"), "Should contain year")
	assert_true(display.contains("March") or display.contains("03"), "Should contain month")

func test_game_date_comparison():
	var date1 = GameDate.new()
	date1.year = 2025
	date1.month = 1
	date1.day = 1

	var date2 = GameDate.new()
	date2.year = 2025
	date2.month = 1
	date2.day = 2

	assert_eq(date1.compare(date2), -1, "Earlier date should return -1")
	assert_eq(date2.compare(date1), 1, "Later date should return 1")
	assert_eq(date1.compare(date1), 0, "Same date should return 0")