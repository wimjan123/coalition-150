extends GutTest

# Test NetherlandsMap UI component
# Tests must FAIL before implementation exists

var netherlands_map: Control

func before_each():
	var map_scene = preload("res://scenes/dashboard/components/netherlands_map.tscn")
	if map_scene:
		netherlands_map = map_scene.instantiate()
		add_child_autofree(netherlands_map)

func test_netherlands_map_scene_exists():
	var scene_path = "res://scenes/dashboard/components/netherlands_map.tscn"
	assert_true(ResourceLoader.exists(scene_path), "NetherlandsMap scene should exist")

func test_netherlands_map_has_provinces():
	if not netherlands_map:
		skip_test("NetherlandsMap scene not available")
		return

	# Should have 12 Dutch provinces as Area2D or Polygon2D nodes
	var provinces = netherlands_map.get_node("Provinces")
	assert_not_null(provinces, "Should have Provinces container")

	var province_nodes = provinces.get_children()
	assert_eq(province_nodes.size(), 12, "Should have 12 province nodes")

func test_netherlands_map_script_interface():
	if not netherlands_map:
		skip_test("NetherlandsMap scene not available")
		return

	assert_has_method(netherlands_map, "select_province")
	assert_has_method(netherlands_map, "highlight_province")
	assert_has_method(netherlands_map, "get_selected_province")
	assert_has_method(netherlands_map, "update_province_colors")

func test_netherlands_map_province_interaction():
	if not netherlands_map:
		skip_test("NetherlandsMap scene not available")
		return

	# Test province selection
	netherlands_map.select_province("noord_holland")
	var selected = netherlands_map.get_selected_province()
	assert_eq(selected, "noord_holland", "Should select province")

func test_netherlands_map_province_data_display():
	if not netherlands_map:
		skip_test("NetherlandsMap scene not available")
		return

	# Should update province colors based on support levels
	var province_data = {
		"noord_holland": {"support": 75.0, "funding": 25000},
		"zuid_holland": {"support": 45.0, "funding": 15000}
	}

	netherlands_map.update_province_display(province_data)

	# Should reflect data in visual representation
	assert_has_method(netherlands_map, "update_province_display")

func test_netherlands_map_hover_effects():
	if not netherlands_map:
		skip_test("NetherlandsMap scene not available")
		return

	# Should show province info on hover
	assert_has_method(netherlands_map, "_on_province_mouse_entered")
	assert_has_method(netherlands_map, "_on_province_mouse_exited")

func test_netherlands_map_signals():
	if not netherlands_map:
		skip_test("NetherlandsMap scene not available")
		return

	watch_signals(netherlands_map)

	assert_has_signal(netherlands_map, "province_selected")
	assert_has_signal(netherlands_map, "province_hovered")
	assert_has_signal(netherlands_map, "campaign_action_requested")

func test_netherlands_map_campaign_integration():
	if not netherlands_map:
		skip_test("NetherlandsMap scene not available")
		return

	# Should connect to RegionalManager for campaign data
	assert_has_method(netherlands_map, "update_campaign_status")
	assert_has_method(netherlands_map, "show_rally_indicators")

func test_netherlands_map_province_validation():
	if not netherlands_map:
		skip_test("NetherlandsMap scene not available")
		return

	# Should validate province IDs against known provinces
	var valid_provinces = [
		"groningen", "friesland", "drenthe", "overijssel",
		"flevoland", "gelderland", "utrecht", "noord_holland",
		"zuid_holland", "zeeland", "noord_brabant", "limburg"
	]

	for province_id in valid_provinces:
		var is_valid = netherlands_map.is_valid_province(province_id)
		assert_true(is_valid, "Should recognize valid province: %s" % province_id)