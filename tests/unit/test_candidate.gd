extends GutTest

# Test Candidate resource class
# Tests must FAIL before implementation exists

func before_each():
	pass

func test_candidate_resource_exists():
	# This test will fail until Candidate class is implemented
	var candidate = Candidate.new()
	assert_not_null(candidate, "Candidate resource should be creatable")

func test_candidate_has_required_fields():
	var candidate = Candidate.new()

	# Test field existence
	assert_has_method(candidate, "get_name")
	assert_has_method(candidate, "set_name")

	# Test default values
	assert_eq(candidate.experience_level, 1, "Default experience should be 1")
	assert_eq(candidate.popularity, 50.0, "Default popularity should be 50.0")
	assert_eq(candidate.specialties.size(), 0, "Should start with no specialties")

func test_candidate_setup():
	var candidate = Candidate.new()
	candidate.name = "Jan de Vries"
	candidate.experience_level = 3
	candidate.political_alignment = PoliticalAlignment.CENTER

	assert_eq(candidate.name, "Jan de Vries", "Should store candidate name")
	assert_eq(candidate.experience_level, 3, "Should store experience level")
	assert_eq(candidate.political_alignment, PoliticalAlignment.CENTER, "Should store alignment")

func test_candidate_specialties():
	var candidate = Candidate.new()
	candidate.specialties.append("Healthcare")
	candidate.specialties.append("Education")

	assert_eq(candidate.specialties.size(), 2, "Should store specialties")
	assert_true(candidate.specialties.has("Healthcare"), "Should contain healthcare specialty")

func test_candidate_validation():
	var candidate = Candidate.new()

	# Test experience level bounds
	candidate.experience_level = 0
	assert_false(candidate.is_valid(), "Zero experience should be invalid")

	candidate.experience_level = 6
	assert_false(candidate.is_valid(), "Experience over 5 should be invalid")

	candidate.experience_level = 3
	assert_true(candidate.is_valid(), "Valid experience should pass")