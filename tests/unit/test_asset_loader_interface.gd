extends GutTest

# Contract test for AssetLoaderInterface
# These tests MUST FAIL before implementation exists

class_name TestAssetLoaderInterface

var asset_loader_interface: AssetLoaderInterface

func before_each():
	# This will fail until AssetLoaderInterface is implemented
	asset_loader_interface = AssetLoaderInterface.new()

func test_interface_exists():
	# Test: AssetLoaderInterface class exists
	assert_not_null(asset_loader_interface, "AssetLoaderInterface should exist")

func test_has_required_signals():
	# Test: All required signals are defined
	assert_true(asset_loader_interface.has_signal("asset_loaded"), "Should have asset_loaded signal")
	assert_true(asset_loader_interface.has_signal("progress_updated"), "Should have progress_updated signal")
	assert_true(asset_loader_interface.has_signal("loading_completed"), "Should have loading_completed signal")
	assert_true(asset_loader_interface.has_signal("retry_started"), "Should have retry_started signal")
	assert_true(asset_loader_interface.has_signal("loading_failed"), "Should have loading_failed signal")

func test_has_required_methods():
	# Test: All required interface methods exist
	assert_true(asset_loader_interface.has_method("add_asset"), "Should have add_asset method")
	assert_true(asset_loader_interface.has_method("start_loading"), "Should have start_loading method")
	assert_true(asset_loader_interface.has_method("stop_loading"), "Should have stop_loading method")
	assert_true(asset_loader_interface.has_method("get_progress"), "Should have get_progress method")
	assert_true(asset_loader_interface.has_method("get_stats"), "Should have get_stats method")

func test_add_asset_method():
	# Test: add_asset method accepts asset path and priority
	# This will fail until implementation exists
	asset_loader_interface.add_asset("res://test.png", 1)

func test_progress_tracking():
	# Test: get_progress returns float between 0.0 and 1.0
	# This will fail until implementation exists
	var progress = asset_loader_interface.get_progress()
	assert_typeof(progress, TYPE_FLOAT, "Progress should be float")

func test_stats_method():
	# Test: get_stats returns dictionary with required keys
	# This will fail until implementation exists
	var stats = asset_loader_interface.get_stats()
	assert_typeof(stats, TYPE_DICTIONARY, "Stats should be dictionary")

func test_configuration_properties():
	# Test: Configuration properties exist with correct types
	assert_true("max_retries" in asset_loader_interface, "Should have max_retries property")
	assert_true("asset_timeout" in asset_loader_interface, "Should have asset_timeout property")
	assert_true("use_threading" in asset_loader_interface, "Should have use_threading property")