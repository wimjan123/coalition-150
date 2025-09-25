# T036-T037: Political balance and difficulty progression validation
# Validates preset content for appropriateness and game balance

class_name PresetContentValidator
extends RefCounted

# Political balance validation results
class PoliticalBalanceReport:
	var total_presets: int = 0
	var alignment_counts: Dictionary = {}
	var balance_score: float = 0.0
	var is_balanced: bool = false
	var recommendations: Array[String] = []

# Difficulty progression validation results
class DifficultyProgressionReport:
	var total_presets: int = 0
	var difficulty_distribution: Dictionary = {}
	var has_complete_progression: bool = false
	var missing_levels: Array[int] = []
	var duplicate_levels: Array[int] = []
	var progression_score: float = 0.0

# Content appropriateness validation results
class ContentAppropriatenessReport:
	var total_presets: int = 0
	var satirical_count: int = 0
	var inappropriate_content: Array[String] = []
	var content_warnings: Array[String] = []
	var satirical_balance_appropriate: bool = false
	var overall_appropriate: bool = true

# Main validation functions

static func validate_political_balance(presets: CharacterBackgroundPresets) -> PoliticalBalanceReport:
	"""Validate political balance across preset collection"""
	var report = PoliticalBalanceReport.new()

	if not presets or not presets.preset_options:
		report.recommendations.append("ERROR: No preset data available for validation")
		return report

	report.total_presets = presets.preset_options.size()

	# Count political alignments
	for preset in presets.preset_options:
		var alignment = preset.political_alignment
		report.alignment_counts[alignment] = report.alignment_counts.get(alignment, 0) + 1

	# Calculate balance score (higher = more balanced)
	report.balance_score = _calculate_balance_score(report.alignment_counts, report.total_presets)

	# Determine if balanced (target: no single alignment > 40% of total)
	var max_alignment_percentage = 0.0
	var dominant_alignment = ""

	for alignment in report.alignment_counts:
		var percentage = float(report.alignment_counts[alignment]) / float(report.total_presets)
		if percentage > max_alignment_percentage:
			max_alignment_percentage = percentage
			dominant_alignment = alignment

	report.is_balanced = max_alignment_percentage <= 0.4  # No single alignment > 40%

	# Generate recommendations
	_generate_balance_recommendations(report, dominant_alignment, max_alignment_percentage)

	return report

static func validate_difficulty_progression(presets: CharacterBackgroundPresets) -> DifficultyProgressionReport:
	"""Validate difficulty progression covers 1-10 appropriately"""
	var report = DifficultyProgressionReport.new()

	if not presets or not presets.preset_options:
		push_error("No preset data available for difficulty validation")
		return report

	report.total_presets = presets.preset_options.size()

	# Analyze difficulty distribution
	for preset in presets.preset_options:
		var difficulty = preset.difficulty_rating
		report.difficulty_distribution[difficulty] = report.difficulty_distribution.get(difficulty, 0) + 1

	# Check for complete 1-10 progression
	for level in range(1, 11):  # 1 to 10 inclusive
		if not report.difficulty_distribution.has(level):
			report.missing_levels.append(level)
		elif report.difficulty_distribution[level] > 1:
			report.duplicate_levels.append(level)

	report.has_complete_progression = report.missing_levels.is_empty()

	# Calculate progression score
	report.progression_score = _calculate_progression_score(report)

	return report

static func validate_content_appropriateness(presets: CharacterBackgroundPresets) -> ContentAppropriatenessReport:
	"""Validate content appropriateness and satirical balance"""
	var report = ContentAppropriatenessReport.new()

	if not presets or not presets.preset_options:
		push_error("No preset data available for content validation")
		return report

	report.total_presets = presets.preset_options.size()

	# Check each preset for content appropriateness
	for preset in presets.preset_options:
		_validate_preset_content(preset, report)
		if preset.is_satirical:
			report.satirical_count += 1

	# Validate satirical balance (should be 20-30% of total)
	var satirical_percentage = float(report.satirical_count) / float(report.total_presets)
	report.satirical_balance_appropriate = satirical_percentage >= 0.1 and satirical_percentage <= 0.4

	if not report.satirical_balance_appropriate:
		if satirical_percentage < 0.1:
			report.content_warnings.append("Too few satirical presets (%.1f%%, target: 10-40%%)" % (satirical_percentage * 100))
		else:
			report.content_warnings.append("Too many satirical presets (%.1f%%, target: 10-40%%)" % (satirical_percentage * 100))

	report.overall_appropriate = report.inappropriate_content.is_empty()

	return report

# Comprehensive validation function
static func validate_all_content(presets: CharacterBackgroundPresets) -> Dictionary:
	"""Run all validation checks and return comprehensive report"""
	var validation_results = {
		"political_balance": validate_political_balance(presets),
		"difficulty_progression": validate_difficulty_progression(presets),
		"content_appropriateness": validate_content_appropriateness(presets),
		"overall_score": 0.0,
		"passed_validation": false,
		"summary": []
	}

	# Calculate overall score
	var balance_weight = 0.4
	var progression_weight = 0.3
	var content_weight = 0.3

	var balance_score = validation_results["political_balance"].balance_score
	var progression_score = validation_results["difficulty_progression"].progression_score
	var content_score = 1.0 if validation_results["content_appropriateness"].overall_appropriate else 0.5

	validation_results["overall_score"] = (balance_score * balance_weight +
										  progression_score * progression_weight +
										  content_score * content_weight)

	validation_results["passed_validation"] = validation_results["overall_score"] >= 0.8

	# Generate summary
	_generate_validation_summary(validation_results)

	return validation_results

# Helper functions

static func _calculate_balance_score(alignment_counts: Dictionary, total_presets: int) -> float:
	"""Calculate political balance score (0.0 = completely unbalanced, 1.0 = perfectly balanced)"""
	if total_presets == 0:
		return 0.0

	# Ideal distribution for political balance
	var alignment_types = alignment_counts.size()
	if alignment_types == 0:
		return 0.0

	var ideal_per_alignment = float(total_presets) / float(alignment_types)
	var total_deviation = 0.0

	for alignment in alignment_counts:
		var actual_count = alignment_counts[alignment]
		var deviation = abs(actual_count - ideal_per_alignment)
		total_deviation += deviation

	# Convert deviation to balance score
	var max_possible_deviation = total_presets
	var balance_score = 1.0 - (total_deviation / max_possible_deviation)
	return max(0.0, balance_score)

static func _calculate_progression_score(report: DifficultyProgressionReport) -> float:
	"""Calculate difficulty progression score"""
	if report.total_presets == 0:
		return 0.0

	var score = 1.0

	# Penalize missing levels
	var missing_penalty = float(report.missing_levels.size()) * 0.1
	score -= missing_penalty

	# Penalize duplicate levels (less severe)
	var duplicate_penalty = float(report.duplicate_levels.size()) * 0.05
	score -= duplicate_penalty

	# Bonus for complete 1-10 progression
	if report.has_complete_progression:
		score += 0.2

	return max(0.0, min(1.0, score))

static func _validate_preset_content(preset: PresetOption, report: ContentAppropriatenessReport) -> void:
	"""Validate individual preset content for appropriateness"""
	var inappropriate_keywords = [
		"offensive", "racist", "sexist", "homophobic", "transphobic",
		"ableist", "extremist", "violent", "hate", "discriminatory"
	]

	var satirical_keywords = [
		"reality tv", "tiktok", "viral", "influencer", "social media",
		"celebrity", "famous", "meme", "internet"
	]

	var background_lower = preset.background_text.to_lower()
	var display_lower = preset.display_name.to_lower()

	# Check for inappropriate content
	for keyword in inappropriate_keywords:
		if background_lower.contains(keyword) or display_lower.contains(keyword):
			report.inappropriate_content.append("Preset '%s' contains potentially inappropriate content: %s" % [preset.display_name, keyword])

	# Validate satirical content appropriateness
	if preset.is_satirical:
		var has_satirical_elements = false
		for keyword in satirical_keywords:
			if background_lower.contains(keyword) or display_lower.contains(keyword):
				has_satirical_elements = true
				break

		if not has_satirical_elements:
			report.content_warnings.append("Preset '%s' marked as satirical but lacks clear satirical elements" % preset.display_name)

	# Check background text length
	if preset.background_text.length() < 50:
		report.content_warnings.append("Preset '%s' has very short background text (%d chars)" % [preset.display_name, preset.background_text.length()])
	elif preset.background_text.length() > 300:
		report.content_warnings.append("Preset '%s' has very long background text (%d chars)" % [preset.display_name, preset.background_text.length()])

static func _generate_balance_recommendations(report: PoliticalBalanceReport, dominant_alignment: String, max_percentage: float) -> void:
	"""Generate recommendations for political balance improvement"""
	if not report.is_balanced:
		report.recommendations.append("Political balance issue: '%s' represents %.1f%% of presets (target: ≤40%%)" % [dominant_alignment, max_percentage * 100])
		report.recommendations.append("Consider diversifying political alignments or adding more presets with different alignments")
	else:
		report.recommendations.append("✓ Political balance is appropriate - no single alignment dominates")

	# Check for missing alignments
	var expected_alignments = ["Progressive", "Conservative", "Centrist", "Libertarian", "Populist"]
	for alignment in expected_alignments:
		if not report.alignment_counts.has(alignment):
			report.recommendations.append("Consider adding preset with '%s' political alignment" % alignment)

static func _generate_validation_summary(results: Dictionary) -> void:
	"""Generate overall validation summary"""
	var summary = results["summary"]

	summary.append("=== PRESET CONTENT VALIDATION SUMMARY ===")
	summary.append("Overall Score: %.1f/10 (%s)" % [results["overall_score"] * 10, "PASS" if results["passed_validation"] else "FAIL"])
	summary.append("")

	# Political balance summary
	var balance_report = results["political_balance"]
	summary.append("Political Balance: %.1f/10" % (balance_report.balance_score * 10))
	for rec in balance_report.recommendations:
		summary.append("  • " + rec)
	summary.append("")

	# Difficulty progression summary
	var progression_report = results["difficulty_progression"]
	summary.append("Difficulty Progression: %.1f/10" % (progression_report.progression_score * 10))
	if progression_report.has_complete_progression:
		summary.append("  ✓ Complete 1-10 difficulty progression")
	else:
		summary.append("  ✗ Incomplete difficulty progression")
		if not progression_report.missing_levels.is_empty():
			summary.append("    Missing levels: " + str(progression_report.missing_levels))
		if not progression_report.duplicate_levels.is_empty():
			summary.append("    Duplicate levels: " + str(progression_report.duplicate_levels))
	summary.append("")

	# Content appropriateness summary
	var content_report = results["content_appropriateness"]
	summary.append("Content Appropriateness: %s" % ("PASS" if content_report.overall_appropriate else "FAIL"))
	summary.append("  Satirical presets: %d/%d (%.1f%%)" % [content_report.satirical_count, content_report.total_presets, float(content_report.satirical_count) / float(content_report.total_presets) * 100])

	if not content_report.inappropriate_content.is_empty():
		summary.append("  ⚠ Inappropriate content found:")
		for issue in content_report.inappropriate_content:
			summary.append("    • " + issue)

	if not content_report.content_warnings.is_empty():
		summary.append("  ⚠ Content warnings:")
		for warning in content_report.content_warnings:
			summary.append("    • " + warning)

# Public API for running validation
static func run_full_validation() -> Dictionary:
	"""Run complete validation on preset data file"""
	var preset_path = "res://assets/data/CharacterBackgroundPresets.tres"

	if not ResourceLoader.exists(preset_path):
		return {
			"error": "Preset data file not found: " + preset_path,
			"passed_validation": false
		}

	var preset_resource = load(preset_path)
	if not preset_resource is CharacterBackgroundPresets:
		return {
			"error": "Invalid preset resource type",
			"passed_validation": false
		}

	return validate_all_content(preset_resource)

static func print_validation_report() -> void:
	"""Run validation and print detailed report"""
	var results = run_full_validation()

	if results.has("error"):
		print("VALIDATION ERROR: " + results["error"])
		return

	for line in results["summary"]:
		print(line)