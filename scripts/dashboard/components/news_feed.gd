# NewsFeed Component
# Displays news events with response options

class_name NewsFeed
extends Control

signal news_response_selected(news_id: String, response: GameEnums.ResponseType)
signal news_item_expanded(news_id: String)

@onready var scroll_container: ScrollContainer = $VBoxContainer/ScrollContainer
@onready var vbox_container: VBoxContainer = $VBoxContainer/ScrollContainer/VBoxContainer
@onready var urgent_filter: CheckBox = $VBoxContainer/HeaderContainer/UrgentFilter

var _news_items: Array[NewsItem] = []
var _news_ui_items: Array[Control] = []

func _ready() -> void:
	"""Initialize news feed"""
	urgent_filter.toggled.connect(_on_urgent_filter_changed)
	_populate_sample_news()

func populate_news(news_items: Array[NewsItem]) -> void:
	"""Populate news feed with items"""
	_news_items = news_items
	_refresh_display()

func add_news_item(news_item: NewsItem) -> void:
	"""Add single news item"""
	if not news_item:
		return

	_news_items.insert(0, news_item)  # Add at top
	_refresh_display()

func clear_news() -> void:
	"""Clear all news items"""
	_news_items.clear()
	for item in _news_ui_items:
		if item:
			item.queue_free()
	_news_ui_items.clear()

func mark_as_read(news_id: String) -> void:
	"""Mark news item as read"""
	for news_item in _news_items:
		if news_item.news_id == news_id:
			# Could add read status to NewsItem resource
			break

func highlight_critical_news() -> void:
	"""Highlight critical/urgent news items"""
	for i in range(_news_ui_items.size()):
		var ui_item = _news_ui_items[i]
		var news_item = _news_items[i] if i < _news_items.size() else null

		if news_item and news_item.is_urgent():
			ui_item.modulate = Color.RED

func show_response_options(news_id: String) -> void:
	"""Show response options for news item"""
	# Implementation handled in _create_news_item
	pass

func handle_response_selection(news_id: String, response: GameEnums.ResponseType) -> void:
	"""Handle response selection"""
	news_response_selected.emit(news_id, response)

## Private Methods

func _refresh_display() -> void:
	"""Refresh the news display"""
	# Clear existing items
	for item in _news_ui_items:
		if item:
			item.queue_free()
	_news_ui_items.clear()

	# Create filtered items
	var filtered_news = _get_filtered_news()
	for news_item in filtered_news:
		_create_news_item(news_item)

func _create_news_item(news_item: NewsItem) -> void:
	"""Create a news item UI"""
	var news_container = _create_news_container()

	# Headline
	var headline_label = Label.new()
	headline_label.text = news_item.headline
	headline_label.add_theme_font_size_override("font_size", 16)
	if news_item.is_urgent():
		headline_label.modulate = Color.RED
	news_container.add_child(headline_label)

	# Content preview
	var content_label = Label.new()
	var preview = news_item.content.substr(0, 150)
	if news_item.content.length() > 150:
		preview += "..."
	content_label.text = preview
	content_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	news_container.add_child(content_label)

	# Metadata
	var meta_container = HBoxContainer.new()
	news_container.add_child(meta_container)

	var urgency_label = Label.new()
	urgency_label.text = "Priority: %s" % news_item.get_urgency_description()
	meta_container.add_child(urgency_label)

	var date_label = Label.new()
	if news_item.publication_date:
		date_label.text = news_item.publication_date.to_display_string()
	else:
		date_label.text = "Unknown date"
	meta_container.add_child(date_label)

	# Response buttons (if not responded)
	if news_item.player_response == GameEnums.ResponseType.NO_RESPONSE:
		var response_container = _create_response_buttons(news_item)
		news_container.add_child(response_container)
	else:
		# Show response taken
		var response_label = Label.new()
		response_label.text = "Response: %s" % news_item.get_response_description()
		response_label.modulate = Color.GREEN
		news_container.add_child(response_label)

	vbox_container.add_child(news_container)
	_news_ui_items.append(news_container)

func _create_news_container() -> Control:
	"""Create container for news item"""
	var container = PanelContainer.new()
	container.custom_minimum_size = Vector2(0, 140)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	container.add_child(vbox)

	return vbox

func _create_response_buttons(news_item: NewsItem) -> Control:
	"""Create response buttons for news item"""
	var response_container = HBoxContainer.new()

	# Standard responses
	var responses = [
		[GameEnums.ResponseType.NO_RESPONSE, "Ignore"],
		[GameEnums.ResponseType.PUBLIC_STATEMENT, "Statement"],
		[GameEnums.ResponseType.PRIVATE_ACTION, "Private Action"],
		[GameEnums.ResponseType.MEDIA_CAMPAIGN, "Media Response"]
	]

	for response_data in responses:
		var button = Button.new()
		button.text = response_data[1]
		button.pressed.connect(_on_response_selected.bind(news_item.news_id, response_data[0]))
		response_container.add_child(button)

	return response_container

func _get_filtered_news() -> Array[NewsItem]:
	"""Get news filtered by current settings"""
	var filtered: Array[NewsItem] = []

	for news_item in _news_items:
		if urgent_filter.button_pressed:
			if news_item.is_urgent():
				filtered.append(news_item)
		else:
			filtered.append(news_item)

	return filtered

func _populate_sample_news() -> void:
	"""Populate with sample news for testing"""
	var sample_news: Array[NewsItem] = []

	# Sample news 1
	var news1 = NewsItem.new()
	news1.news_id = "NEWS-001"
	news1.headline = "Economic Indicators Show Mixed Results"
	news1.content = "Recent economic data shows both positive growth in manufacturing and concerning unemployment trends. Analysts are divided on the implications for the upcoming quarter."
	news1.urgency_level = GameEnums.UrgencyLevel.NORMAL
	news1.publication_date = GameDate.new()
	sample_news.append(news1)

	# Sample news 2
	var news2 = NewsItem.new()
	news2.news_id = "NEWS-002"
	news2.headline = "Healthcare Strike Threatens Public Services"
	news2.content = "Healthcare workers across three provinces have announced a coordinated strike starting next week. The action could affect thousands of patients and require immediate government response."
	news2.urgency_level = GameEnums.UrgencyLevel.CRITICAL
	news2.publication_date = GameDate.new()
	sample_news.append(news2)

	populate_news(sample_news)

## Signal Handlers

func _on_response_selected(news_id: String, response: GameEnums.ResponseType) -> void:
	"""Handle news response selection"""
	news_response_selected.emit(news_id, response)

	# Update local news state
	for news_item in _news_items:
		if news_item.news_id == news_id:
			news_item.respond(response)
			break

	_refresh_display()

func _on_urgent_filter_changed(toggled: bool) -> void:
	"""Handle urgent filter toggle"""
	_refresh_display()