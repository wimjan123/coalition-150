extends GutTest

# Test NewsFeed UI component
# Tests must FAIL before implementation exists

var news_feed: Control

func before_each():
	var news_scene = preload("res://scenes/dashboard/components/news_feed.tscn")
	if news_scene:
		news_feed = news_scene.instantiate()
		add_child_autofree(news_feed)

func test_news_feed_scene_exists():
	var scene_path = "res://scenes/dashboard/components/news_feed.tscn"
	assert_true(ResourceLoader.exists(scene_path), "NewsFeed scene should exist")

func test_news_feed_has_scroll_container():
	if not news_feed:
		skip_test("NewsFeed scene not available")
		return

	var scroll_container = news_feed.get_node("ScrollContainer")
	assert_not_null(scroll_container, "Should have ScrollContainer")

	var vbox = scroll_container.get_node("VBoxContainer")
	assert_not_null(vbox, "Should have VBoxContainer for news items")

func test_news_feed_script_interface():
	if not news_feed:
		skip_test("NewsFeed scene not available")
		return

	assert_has_method(news_feed, "populate_news")
	assert_has_method(news_feed, "add_news_item")
	assert_has_method(news_feed, "clear_news")
	assert_has_method(news_feed, "mark_as_read")

func test_news_feed_news_management():
	if not news_feed:
		skip_test("NewsFeed scene not available")
		return

	var test_news = NewsItem.new()
	test_news.news_id = "NEWS-001"
	test_news.headline = "Test News Headline"
	test_news.content = "Test news content"

	news_feed.add_news_item(test_news)

	var news_items = news_feed.get_node("ScrollContainer/VBoxContainer").get_children()
	assert_gt(news_items.size(), 0, "Should add news item")

func test_news_feed_response_interface():
	if not news_feed:
		skip_test("NewsFeed scene not available")
		return

	watch_signals(news_feed)

	# Should emit signal when news response is selected
	assert_has_signal(news_feed, "news_response_selected")
	assert_has_signal(news_feed, "news_item_expanded")

func test_news_feed_urgency_display():
	if not news_feed:
		skip_test("NewsFeed scene not available")
		return

	var urgent_news = NewsItem.new()
	urgent_news.urgency_level = GameEnums.UrgencyLevel.CRITICAL
	urgent_news.headline = "Urgent News"

	news_feed.add_news_item(urgent_news)

	# Should highlight critical news items
	assert_has_method(news_feed, "highlight_critical_news")

func test_news_feed_response_options():
	if not news_feed:
		skip_test("NewsFeed scene not available")
		return

	# Should show response buttons for each news item
	assert_has_method(news_feed, "show_response_options")
	assert_has_method(news_feed, "handle_response_selection")