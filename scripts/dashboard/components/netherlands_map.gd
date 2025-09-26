# NetherlandsMap Component
# Interactive map of Netherlands provinces for campaign management

class_name NetherlandsMap
extends Control

signal province_selected(province_id: String)
signal province_hovered(province_id: String)
signal campaign_action_requested(province_id: String, action: String)

@onready var provinces_container: Control = $VBoxContainer/MapContainer/MapCanvas/Provinces
@onready var view_toggle: OptionButton = $VBoxContainer/HeaderContainer/ViewToggle
@onready var province_name_label: Label = $VBoxContainer/ProvinceInfo/InfoVBox/ProvinceNameLabel
@onready var province_stats_label: Label = $VBoxContainer/ProvinceInfo/InfoVBox/ProvinceStatsLabel

var _province_buttons: Dictionary = {}  # String -> Button
var _province_data: Dictionary = {}     # String -> Dictionary
var _selected_province: String = ""
var _valid_provinces: Array[String] = []

func _ready() -> void:
	"""Initialize Netherlands map"""
	_setup_valid_provinces()
	_create_province_buttons()
	_load_province_data()

	view_toggle.item_selected.connect(_on_view_changed)

func select_province(province_id: String) -> void:
	"""Select a specific province"""
	if not is_valid_province(province_id):
		return

	# Deselect previous province
	if not _selected_province.is_empty():
		var old_button = _province_buttons.get(_selected_province)
		if old_button:
			old_button.modulate = Color.WHITE

	_selected_province = province_id
	province_selected.emit(province_id)

	# Highlight selected province
	var button = _province_buttons.get(province_id)
	if button:
		button.modulate = Color.YELLOW

	_update_province_info(province_id)

func highlight_province(province_id: String, highlight: bool) -> void:
	"""Highlight or unhighlight a province"""
	var button = _province_buttons.get(province_id)
	if button:
		if highlight:
			button.modulate = Color.LIGHT_BLUE
		else:
			button.modulate = Color.WHITE

func get_selected_province() -> String:
	"""Get currently selected province"""
	return _selected_province

func update_province_colors() -> void:
	"""Update province colors based on current view mode"""
	var view_mode = view_toggle.selected

	for province_id in _valid_provinces:
		var button = _province_buttons.get(province_id)
		var data = _province_data.get(province_id, {})

		if not button:
			continue

		var color = Color.WHITE

		match view_mode:
			0: # Support Level
				var support = data.get("support", 50.0)
				color = _get_support_color(support)
			1: # Funding
				var funding = data.get("funding", 0)
				color = _get_funding_color(funding)
			2: # Activity
				var activity = data.get("activity", 0)
				color = _get_activity_color(activity)

		if province_id != _selected_province:
			button.modulate = color

func update_province_display(province_data: Dictionary) -> void:
	"""Update province display data"""
	for province_id in province_data.keys():
		if is_valid_province(province_id):
			_province_data[province_id] = province_data[province_id]

	update_province_colors()

func update_campaign_status() -> void:
	"""Update campaign status display"""
	# This would connect to RegionalManager for real data
	update_province_colors()

func show_rally_indicators() -> void:
	"""Show rally indicators on provinces"""
	# Implementation would show rally icons on provinces with scheduled rallies
	pass

func is_valid_province(province_id: String) -> bool:
	"""Check if province ID is valid"""
	return _valid_provinces.has(province_id)

## Private Methods

func _setup_valid_provinces() -> void:
	"""Set up the list of valid Dutch provinces"""
	_valid_provinces = [
		"groningen", "friesland", "drenthe", "overijssel",
		"flevoland", "gelderland", "utrecht", "noord_holland",
		"zuid_holland", "zeeland", "noord_brabant", "limburg"
	]

func _create_province_buttons() -> void:
	"""Create clickable buttons for each province"""
	# Load province positions from our data file
	var province_positions = _load_province_positions()

	for province_id in _valid_provinces:
		var button = Button.new()
		button.text = _get_province_display_name(province_id)
		button.custom_minimum_size = Vector2(80, 40)

		# Position button based on approximate province location
		var pos = province_positions.get(province_id, Vector2(100, 100))
		button.position = pos

		# Connect signals
		button.pressed.connect(_on_province_clicked.bind(province_id))
		button.mouse_entered.connect(_on_province_hovered.bind(province_id))
		button.mouse_exited.connect(_on_province_unhovered.bind(province_id))

		provinces_container.add_child(button)
		_province_buttons[province_id] = button

func _load_province_positions() -> Dictionary:
	"""Load province positions from map data"""
	var positions = {}

	# Load from our prepared map data file
	var file_path = "res://resources/maps/netherlands_provinces_data.json"
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file:
			var json_text = file.get_as_text()
			file.close()

			var json = JSON.new()
			var parse_result = json.parse(json_text)

			if parse_result == OK:
				var data = json.data as Dictionary
				var provinces = data.get("provinces", [])

				for province in provinces:
					var province_dict = province as Dictionary
					var id = province_dict.get("id", "")
					var x = province_dict.get("center_x", 100)
					var y = province_dict.get("center_y", 100)
					positions[id] = Vector2(x, y)

	return positions

func _load_province_data() -> void:
	"""Load initial province data"""
	# Initialize with sample data - in real implementation would load from RegionalManager
	for province_id in _valid_provinces:
		_province_data[province_id] = {
			"support": randf_range(30.0, 70.0),
			"funding": randi_range(0, 30000),
			"activity": randi_range(0, 5)
		}

func _get_province_display_name(province_id: String) -> String:
	"""Get display name for province"""
	var names = {
		"groningen": "Groningen",
		"friesland": "Friesland",
		"drenthe": "Drenthe",
		"overijssel": "Overijssel",
		"flevoland": "Flevoland",
		"gelderland": "Gelderland",
		"utrecht": "Utrecht",
		"noord_holland": "Noord-Holland",
		"zuid_holland": "Zuid-Holland",
		"zeeland": "Zeeland",
		"noord_brabant": "Noord-Brabant",
		"limburg": "Limburg"
	}

	return names.get(province_id, province_id.capitalize())

func _get_support_color(support_level: float) -> Color:
	"""Get color based on support level"""
	if support_level >= 70.0:
		return Color.GREEN
	elif support_level >= 50.0:
		return Color.YELLOW
	elif support_level >= 30.0:
		return Color.ORANGE
	else:
		return Color.RED

func _get_funding_color(funding_amount: int) -> Color:
	"""Get color based on funding amount"""
	if funding_amount >= 20000:
		return Color.BLUE
	elif funding_amount >= 10000:
		return Color.CYAN
	elif funding_amount >= 5000:
		return Color.LIGHT_BLUE
	else:
		return Color.WHITE

func _get_activity_color(activity_level: int) -> Color:
	"""Get color based on activity level"""
	match activity_level:
		0: return Color.GRAY
		1: return Color.LIGHT_GRAY
		2: return Color.WHITE
		3: return Color.LIGHT_GREEN
		4: return Color.GREEN
		_: return Color.DARK_GREEN

func _update_province_info(province_id: String) -> void:
	"""Update province info panel"""
	if province_id.is_empty():
		province_name_label.text = "Select a province"
		province_stats_label.text = "Support: -- | Funding: --"
		return

	var display_name = _get_province_display_name(province_id)
	var data = _province_data.get(province_id, {})
	var support = data.get("support", 0.0)
	var funding = data.get("funding", 0)

	province_name_label.text = display_name
	province_stats_label.text = "Support: %.1f%% | Funding: €%s" % [support, _format_currency(funding)]

func _format_currency(amount: int) -> String:
	"""Format currency amount"""
	if amount >= 1000:
		return "%.1fK" % (float(amount) / 1000.0)
	else:
		return str(amount)

## Signal Handlers

func _on_province_clicked(province_id: String) -> void:
	"""Handle province button click"""
	select_province(province_id)

func _on_province_hovered(province_id: String) -> void:
	"""Handle province hover"""
	province_hovered.emit(province_id)
	_update_province_info(province_id)

func _on_province_unhovered(province_id: String) -> void:
	"""Handle province unhover"""
	if province_id != _selected_province:
		_update_province_info(_selected_province)

func _on_view_changed(index: int) -> void:
	"""Handle view mode change"""
	update_province_colors()