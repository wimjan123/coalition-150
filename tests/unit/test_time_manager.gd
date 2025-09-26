extends GutTest

# Test TimeManager autoload interface
# Tests must FAIL before implementation exists

var time_manager: ITimeManager

func before_each():
	# In a real scenario, this would access the autoload
	# For testing, we'll need to mock or use actual implementation
	pass

func test_time_manager_exists():
	# This will succeed once autoload is configured
	assert_not_null(TimeManager, "TimeManager autoload should exist")

func test_time_manager_implements_interface():
	assert_has_method(TimeManager, "get_current_time")
	assert_has_method(TimeManager, "advance_time")
	assert_has_method(TimeManager, "set_time_speed")
	assert_has_method(TimeManager, "pause_time")
	assert_has_method(TimeManager, "resume_time")

func test_time_manager_initial_state():
	var current_time = TimeManager.get_current_time()
	assert_not_null(current_time, "Should have current time")
	assert_false(TimeManager.is_paused(), "Should not be paused initially")
	assert_eq(TimeManager.get_time_speed(), GameEnums.TimeSpeed.NORMAL, "Should start at normal speed")

func test_time_manager_pause_resume():
	TimeManager.pause_time()
	assert_true(TimeManager.is_paused(), "Should be paused")

	TimeManager.resume_time()
	assert_false(TimeManager.is_paused(), "Should not be paused after resume")

func test_time_manager_speed_control():
	TimeManager.set_time_speed(GameEnums.TimeSpeed.FAST)
	assert_eq(TimeManager.get_time_speed(), GameEnums.TimeSpeed.FAST, "Should change speed")

	TimeManager.set_time_speed(GameEnums.TimeSpeed.VERY_FAST)
	assert_eq(TimeManager.get_time_speed(), GameEnums.TimeSpeed.VERY_FAST, "Should change to very fast")

func test_time_manager_time_advancement():
	var initial_time = TimeManager.get_current_time()
	TimeManager.advance_time(60)  # 1 hour

	var new_time = TimeManager.get_current_time()
	assert_ne(initial_time.compare(new_time), 0, "Time should have advanced")

func test_time_manager_signals():
	# Test signal emissions
	watch_signals(TimeManager)

	TimeManager.pause_time()
	assert_signal_emitted(TimeManager, "time_paused")

	TimeManager.resume_time()
	assert_signal_emitted(TimeManager, "time_resumed")

	TimeManager.set_time_speed(GameEnums.TimeSpeed.FAST)
	assert_signal_emitted(TimeManager, "time_speed_changed")

func test_time_manager_event_scheduling():
	var target_time = GameDate.new()
	target_time.hour = 15
	var callback_called = false

	var callback = func(): callback_called = true
	TimeManager.schedule_time_event(target_time, callback)

	# This would require time advancement or simulation
	# In real implementation, we'd advance time to trigger the event
	assert_has_method(TimeManager, "schedule_time_event")