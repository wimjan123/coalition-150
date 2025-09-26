extends GutTest

# Test NewsItem resource class
# Tests must FAIL before implementation exists

func before_each():
	pass

func test_news_item_resource_exists():
	# This test will fail until NewsItem class is implemented
	var news = NewsItem.new()
	assert_not_null(news, "NewsItem resource should be creatable")

func test_news_item_has_required_fields():
	var news = NewsItem.new()

	# Test field existence
	assert_has_method(news, "get_headline")
	assert_has_method(news, "set_headline")

	# Test default values
	assert_eq(news.urgency_level, UrgencyLevel.NORMAL, "Default urgency should be normal")
	assert_eq(news.player_response, ResponseType.NO_RESPONSE, "Default response should be none")
	assert_false(news.consequences_applied, "Should start with no consequences applied")
	assert_eq(news.response_options.size(), 0, "Should start with no response options")

func test_news_item_setup():
	var news = NewsItem.new()
	news.news_id = "NEWS-001"
	news.headline = "Economic Growth Slows"
	news.content = "Recent data shows economic indicators declining..."

	assert_eq(news.news_id, "NEWS-001", "Should store news ID")
	assert_eq(news.headline, "Economic Growth Slows", "Should store headline")
	assert_true(news.content.length() > 0, "Should store content")

func test_news_item_response_options():
	var news = NewsItem.new()

	# This will fail until ResponseOption class exists
	var option = ResponseOption.new()
	news.response_options.append(option)

	assert_eq(news.response_options.size(), 1, "Should store response options")

func test_news_item_urgency():
	var news = NewsItem.new()
	news.urgency_level = UrgencyLevel.CRITICAL

	assert_eq(news.urgency_level, UrgencyLevel.CRITICAL, "Should store urgency level")

func test_news_item_response():
	var news = NewsItem.new()
	news.player_response = ResponseType.PUBLIC_STATEMENT

	assert_eq(news.player_response, ResponseType.PUBLIC_STATEMENT, "Should store player response")

func test_news_item_validation():
	var news = NewsItem.new()

	news.headline = ""
	assert_false(news.is_valid(), "Empty headline should be invalid")

	news.headline = "Valid Headline"
	assert_true(news.is_valid(), "Valid headline should pass")