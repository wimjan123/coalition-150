extends GutTest

# Test question filtering based on preset tag matching
# This test ensures questions are properly filtered and prioritized

func test_filter_questions_by_matching_tags() -> void:
	# Test that questions with matching tags are prioritized
	var questions_data: Dictionary = {
		"q1": {"tags": ["warrior", "noble"], "text": "Warrior question", "is_fallback": false},
		"q2": {"tags": ["mage", "scholar"], "text": "Mage question", "is_fallback": false},
		"q3": {"tags": ["rogue"], "text": "Rogue question", "is_fallback": false},
		"q_fallback": {"tags": [], "text": "Fallback question", "is_fallback": true}
	}

	var player_tags: Array[String] = ["warrior", "noble"]
	var filtered_questions: Array[String] = filter_questions_by_tags(questions_data, player_tags)

	# Should prioritize questions with matching tags
	assert_true(filtered_questions.has("q1"), "Questions with matching tags should be included")
	assert_false(filtered_questions.has("q2"), "Questions with non-matching tags should be excluded")

func test_fallback_questions_when_no_matches() -> void:
	# Test that fallback questions are used when no tags match
	var questions_data: Dictionary = {
		"q1": {"tags": ["warrior"], "text": "Warrior question", "is_fallback": false},
		"q2": {"tags": ["mage"], "text": "Mage question", "is_fallback": false},
		"q_fallback1": {"tags": [], "text": "Fallback 1", "is_fallback": true},
		"q_fallback2": {"tags": [], "text": "Fallback 2", "is_fallback": true}
	}

	var player_tags: Array[String] = ["scholar"]  # No matches
	var filtered_questions: Array[String] = filter_questions_by_tags(questions_data, player_tags)

	# Should return fallback questions when no matches
	assert_true(filtered_questions.has("q_fallback1"), "Fallback questions should be included when no matches")
	assert_true(filtered_questions.has("q_fallback2"), "All fallback questions should be included")
	assert_false(filtered_questions.has("q1"), "Non-matching questions should be excluded")

# Placeholder function - will be implemented in InterviewManager
func filter_questions_by_tags(questions_data: Dictionary, player_tags: Array[String]) -> Array[String]:
	# Return empty array to ensure tests fail as required by TDD
	return []