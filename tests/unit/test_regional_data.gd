extends GutTest

# Test RegionalData resource class
# Tests must FAIL before implementation exists

func before_each():
	pass

func test_regional_data_resource_exists():
	# This test will fail until RegionalData class is implemented
	var regional_data = RegionalData.new()
	assert_not_null(regional_data, "RegionalData resource should be creatable")

func test_regional_data_has_required_fields():
	var regional_data = RegionalData.new()

	# Test field existence
	assert_has_method(regional_data, "get_province_name")
	assert_has_method(regional_data, "set_province_name")

	# Test default values
	assert_eq(regional_data.campaign_funding, 0, "Default campaign funding should be 0")
	assert_eq(regional_data.support_level, 50.0, "Default support level should be 50.0")
	assert_eq(regional_data.scheduled_rallies.size(), 0, "Should start with no rallies")
	assert_eq(regional_data.local_policies.size(), 0, "Should start with no policies")

func test_regional_data_province_setup():
	var regional_data = RegionalData.new()
	regional_data.province_name = "Noord-Holland"
	regional_data.province_id = "noord_holland"

	assert_eq(regional_data.province_name, "Noord-Holland", "Should store province name")
	assert_eq(regional_data.province_id, "noord_holland", "Should store province ID")

func test_regional_data_campaign_funding():
	var regional_data = RegionalData.new()
	regional_data.campaign_funding = 25000

	assert_eq(regional_data.campaign_funding, 25000, "Should store campaign funding")

func test_regional_data_rallies():
	var regional_data = RegionalData.new()

	# This will fail until Rally class exists
	var rally = Rally.new()
	regional_data.scheduled_rallies.append(rally)

	assert_eq(regional_data.scheduled_rallies.size(), 1, "Should store rally")

func test_regional_data_validation():
	var regional_data = RegionalData.new()

	# Test support level bounds
	regional_data.support_level = -10.0
	assert_false(regional_data.is_valid(), "Negative support should be invalid")

	regional_data.support_level = 110.0
	assert_false(regional_data.is_valid(), "Support over 100 should be invalid")

	regional_data.support_level = 75.0
	assert_true(regional_data.is_valid(), "Valid support should pass")