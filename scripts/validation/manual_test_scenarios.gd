# Manual Test Scenarios - Coalition 150 Player Creation Flow
# Provides structured manual testing scenarios based on quickstart.md requirements

class_name ManualTestScenarios
extends RefCounted

# Test Scenario Results
var test_results: Dictionary = {}
var scenarios_completed: int = 0
var scenarios_passed: int = 0

signal manual_test_completed(scenario: Dictionary)
signal all_tests_completed(summary: Dictionary)

func _init():
	test_results = {
		"scenarios": [],
		"summary": {
			"total_scenarios": 0,
			"completed_scenarios": 0,
			"passed_scenarios": 0,
			"failed_scenarios": 0,
			"pass_rate": 0.0
		},
		"timestamp": Time.get_datetime_string_from_system()
	}

# Get All Manual Test Scenarios
func get_test_scenarios() -> Array[Dictionary]:
	var scenarios: Array[Dictionary] = []

	# Scenario 1: New Player First-Time Experience
	scenarios.append({
		"id": "NEW_PLAYER_001",
		"name": "New Player First-Time Experience",
		"description": "Test complete flow for first-time player creating new character",
		"category": "Complete Flow",
		"priority": "HIGH",
		"estimated_time": "5-8 minutes",
		"steps": _get_new_player_steps(),
		"expected_outcomes": _get_new_player_outcomes(),
		"validation_points": _get_new_player_validation()
	})

	# Scenario 2: Returning Player Load Experience
	scenarios.append({
		"id": "RETURNING_PLAYER_001",
		"name": "Returning Player Load Experience",
		"description": "Test flow for returning player loading existing character",
		"category": "Load Flow",
		"priority": "HIGH",
		"estimated_time": "3-5 minutes",
		"steps": _get_returning_player_steps(),
		"expected_outcomes": _get_returning_player_outcomes(),
		"validation_points": _get_returning_player_validation()
	})

	# Scenario 3: Form Validation and Error Handling
	scenarios.append({
		"id": "VALIDATION_001",
		"name": "Form Validation and Error Handling",
		"description": "Test form validation with invalid data and error recovery",
		"category": "Error Handling",
		"priority": "MEDIUM",
		"estimated_time": "4-6 minutes",
		"steps": _get_validation_test_steps(),
		"expected_outcomes": _get_validation_test_outcomes(),
		"validation_points": _get_validation_test_validation()
	})

	# Scenario 4: UI Responsiveness and Performance
	scenarios.append({
		"id": "PERFORMANCE_001",
		"name": "UI Responsiveness and Performance",
		"description": "Test UI responsiveness and performance requirements",
		"category": "Performance",
		"priority": "MEDIUM",
		"estimated_time": "3-4 minutes",
		"steps": _get_performance_test_steps(),
		"expected_outcomes": _get_performance_test_outcomes(),
		"validation_points": _get_performance_test_validation()
	})

	# Scenario 5: Accessibility and Keyboard Navigation
	scenarios.append({
		"id": "ACCESSIBILITY_001",
		"name": "Accessibility and Keyboard Navigation",
		"description": "Test keyboard navigation and accessibility features",
		"category": "Accessibility",
		"priority": "MEDIUM",
		"estimated_time": "4-5 minutes",
		"steps": _get_accessibility_test_steps(),
		"expected_outcomes": _get_accessibility_test_outcomes(),
		"validation_points": _get_accessibility_test_validation()
	})

	# Scenario 6: Edge Cases and Boundary Conditions
	scenarios.append({
		"id": "EDGE_CASES_001",
		"name": "Edge Cases and Boundary Conditions",
		"description": "Test edge cases, long text, special characters, and boundary conditions",
		"category": "Edge Cases",
		"priority": "LOW",
		"estimated_time": "5-7 minutes",
		"steps": _get_edge_case_test_steps(),
		"expected_outcomes": _get_edge_case_test_outcomes(),
		"validation_points": _get_edge_case_test_validation()
	})

	# Update total scenarios count
	test_results["summary"]["total_scenarios"] = scenarios.size()

	return scenarios

# Scenario 1: New Player First-Time Experience
func _get_new_player_steps() -> Array[String]:
	return [
		"1. Launch the game and observe MainMenu",
		"2. Verify Load Game button is disabled (no save data)",
		"3. Click 'Start Game' button",
		"4. Observe CharacterPartySelection scene loads",
		"5. Verify 'Load Selected' button is disabled (no characters)",
		"6. Click 'Create New' button",
		"7. Observe CharacterPartyCreation scene loads",
		"8. Fill in Character Name: 'Alex Thompson'",
		"9. Select Political Experience: 'Community Organizer'",
		"10. Enter Backstory: 'Long-time resident passionate about local issues'",
		"11. Fill in Party Name: 'Progressive Unity'",
		"12. Enter Party Slogan: 'Building Bridges, Creating Change'",
		"13. Select a party color using color picker",
		"14. Choose a party logo from the selection grid",
		"15. Verify Create Character button becomes enabled",
		"16. Click 'Create Character' button",
		"17. Observe MediaInterview scene loads",
		"18. Answer all 5 interview questions by selecting choices",
		"19. Navigate through all questions using Next button",
		"20. Review summary of answers",
		"21. Click 'Finish' button",
		"22. Verify character is saved successfully",
		"23. Observe transition to main game (placeholder)"
	]

func _get_new_player_outcomes() -> Array[String]:
	return [
		"MainMenu displays with correct theme and layout",
		"Load Game button is disabled, showing no save data state",
		"CharacterPartySelection loads smoothly (< 100ms)",
		"Create New button is available and functional",
		"CharacterPartyCreation form displays all required fields",
		"Form validation works correctly - button disabled until valid",
		"Real-time validation feedback for party name uniqueness",
		"Color picker and logo selection work smoothly",
		"MediaInterview generates 5 contextual questions",
		"Interview questions are relevant to character profile",
		"Navigation between questions works correctly",
		"Answer selections are preserved when navigating back",
		"Summary accurately displays all selected answers",
		"Character data saves successfully to user:// directory",
		"Complete flow takes reasonable time (5-8 minutes)"
	]

func _get_new_player_validation() -> Array[String]:
	return [
		"✓ All scenes load within 100ms performance requirement",
		"✓ UI elements are keyboard accessible with tab navigation",
		"✓ Form validation provides clear, immediate feedback",
		"✓ Party name uniqueness checking works correctly",
		"✓ Color accessibility meets WCAG guidelines",
		"✓ Interview questions are contextually relevant",
		"✓ Save data persists correctly across sessions",
		"✓ Theme consistency maintained across all scenes",
		"✓ No errors or warnings in console output",
		"✓ Memory usage remains stable throughout flow"
	]

# Scenario 2: Returning Player Load Experience
func _get_returning_player_steps() -> Array[String]:
	return [
		"1. Ensure save data exists from previous test",
		"2. Launch the game and observe MainMenu",
		"3. Verify Load Game button is enabled",
		"4. Observe status shows '1 saved character(s) available'",
		"5. Click 'Load Game' button",
		"6. Observe CharacterPartySelection scene loads",
		"7. Verify existing character appears in list",
		"8. Character shows name, party, and key details",
		"9. Select the character from the list",
		"10. Verify 'Load Selected' button becomes enabled",
		"11. Click 'Load Selected' button",
		"12. Observe transition directly to main game",
		"13. Verify character data loaded correctly"
	]

func _get_returning_player_outcomes() -> Array[String]:
	return [
		"MainMenu correctly detects existing save data",
		"Load Game button is enabled with accurate count",
		"CharacterPartySelection displays saved character",
		"Character information displayed accurately",
		"Selection highlighting works correctly",
		"Load Selected functionality works as expected",
		"Character data loaded preserves all attributes",
		"Faster flow for returning players (3-5 minutes)"
	]

func _get_returning_player_validation() -> Array[String]:
	return [
		"✓ Save data detection works correctly",
		"✓ Character display shows accurate information",
		"✓ Selection UI provides clear visual feedback",
		"✓ Loaded character maintains all original data",
		"✓ Performance remains optimal with save data",
		"✓ No data corruption or loss during load process"
	]

# Scenario 3: Form Validation and Error Handling
func _get_validation_test_steps() -> Array[String]:
	return [
		"1. Navigate to CharacterPartyCreation scene",
		"2. Test empty form - verify Create button disabled",
		"3. Enter character name only - button still disabled",
		"4. Test invalid characters in name field (symbols, numbers)",
		"5. Enter extremely long character name (>100 characters)",
		"6. Clear character name, enter party name only",
		"7. Test duplicate party name from existing save data",
		"8. Observe real-time validation feedback",
		"9. Enter valid character name, invalid party name",
		"10. Test party slogan with excessive length",
		"11. Select harsh/inaccessible colors",
		"12. Observe color accessibility warnings",
		"13. Fill form with all valid data",
		"14. Verify Create button enables",
		"15. Test form submission with edge case data",
		"16. Navigate back and forth to ensure data persistence"
	]

func _get_validation_test_outcomes() -> Array[String]:
	return [
		"Form validation prevents submission of invalid data",
		"Real-time feedback for party name uniqueness",
		"Character name validation rejects invalid input",
		"Party name validation shows appropriate errors",
		"Color accessibility warnings display correctly",
		"Form state persists during navigation",
		"Error messages are clear and actionable",
		"Valid data submission works smoothly"
	]

func _get_validation_test_validation() -> Array[String]:
	return [
		"✓ All form fields have appropriate validation",
		"✓ Error messages are user-friendly and specific",
		"✓ Real-time validation doesn't impact performance",
		"✓ Accessibility considerations in error display",
		"✓ Form data persists correctly during navigation",
		"✓ Party name uniqueness checking is reliable"
	]

# Scenario 4: UI Responsiveness and Performance
func _get_performance_test_steps() -> Array[String]:
	return [
		"1. Monitor FPS during scene transitions",
		"2. Measure scene loading times with stopwatch",
		"3. Test rapid clicking on buttons and UI elements",
		"4. Navigate quickly between scenes multiple times",
		"5. Test color picker responsiveness",
		"6. Test logo selection grid performance",
		"7. Type rapidly in text fields",
		"8. Test interview question navigation speed",
		"9. Monitor memory usage during extended testing",
		"10. Test UI responsiveness on lower-end hardware (if available)"
	]

func _get_performance_test_outcomes() -> Array[String]:
	return [
		"Consistent 60 FPS maintained throughout",
		"Scene transitions complete in under 100ms",
		"UI elements respond within 16ms",
		"No frame drops during rapid interactions",
		"Memory usage remains stable",
		"Performance maintained on various hardware"
	]

func _get_performance_test_validation() -> Array[String]:
	return [
		"✓ 60 FPS requirement met consistently",
		"✓ Scene transitions under 100ms requirement",
		"✓ UI responsiveness under 16ms requirement",
		"✓ No memory leaks during extended use",
		"✓ Performance scales appropriately on different hardware"
	]

# Scenario 5: Accessibility and Keyboard Navigation
func _get_accessibility_test_steps() -> Array[String]:
	return [
		"1. Test Tab navigation through all scenes",
		"2. Verify focus indicators are visible",
		"3. Test Enter key activation on buttons",
		"4. Test Escape key for back navigation",
		"5. Verify tooltips appear on hover",
		"6. Test keyboard shortcuts if any",
		"7. Check color contrast ratios",
		"8. Test with high contrast mode (if OS supports)",
		"9. Verify text scaling compatibility",
		"10. Test screen reader compatibility (if available)"
	]

func _get_accessibility_test_outcomes() -> Array[String]:
	return [
		"All interactive elements keyboard accessible",
		"Clear focus indicators throughout UI",
		"Logical tab order in all scenes",
		"Helpful tooltips on important elements",
		"Sufficient color contrast ratios",
		"Compatible with accessibility tools"
	]

func _get_accessibility_test_validation() -> Array[String]:
	return [
		"✓ Complete keyboard navigation support",
		"✓ WCAG color contrast compliance",
		"✓ Clear focus indicators on all interactive elements",
		"✓ Helpful tooltips and feedback",
		"✓ Logical navigation flow",
		"✓ Screen reader compatible (where possible)"
	]

# Scenario 6: Edge Cases and Boundary Conditions
func _get_edge_case_test_steps() -> Array[String]:
	return [
		"1. Test maximum character name length",
		"2. Test party names with special characters",
		"3. Test Unicode characters in text fields",
		"4. Create multiple characters with similar names",
		"5. Test saving with disk space limitations",
		"6. Test rapid save/load operations",
		"7. Test behavior with corrupted save files",
		"8. Test multiple party creation with same colors",
		"9. Test interview with controversial responses",
		"10. Test system behavior during low memory conditions",
		"11. Test file system permissions issues",
		"12. Test network interruption during save operations"
	]

func _get_edge_case_test_outcomes() -> Array[String]:
	return [
		"Graceful handling of edge case inputs",
		"Appropriate error messages for boundary conditions",
		"System stability maintained under stress",
		"Data integrity preserved in all conditions",
		"Recovery mechanisms work correctly",
		"User experience remains positive despite edge cases"
	]

func _get_edge_case_test_validation() -> Array[String]:
	return [
		"✓ System handles all edge cases gracefully",
		"✓ Data validation prevents corruption",
		"✓ Error recovery mechanisms function correctly",
		"✓ User feedback for edge cases is clear",
		"✓ System stability maintained under stress",
		"✓ No data loss in boundary conditions"
	]

# Test Execution Support
func execute_scenario(scenario_id: String) -> Dictionary:
	var scenarios: Array[Dictionary] = get_test_scenarios()
	var scenario: Dictionary = {}

	# Find the scenario
	for s in scenarios:
		if s["id"] == scenario_id:
			scenario = s
			break

	if scenario.is_empty():
		return {"error": "Scenario not found: " + scenario_id}

	# Create test execution result
	var result: Dictionary = {
		"scenario_id": scenario_id,
		"scenario_name": scenario["name"],
		"status": "IN_PROGRESS",
		"start_time": Time.get_datetime_string_from_system(),
		"steps_completed": 0,
		"total_steps": scenario["steps"].size(),
		"validation_passed": 0,
		"total_validations": scenario["validation_points"].size(),
		"notes": [],
		"issues_found": [],
		"recommendations": []
	}

	test_results["scenarios"].append(result)
	manual_test_completed.emit(scenario)

	return result

func mark_step_completed(scenario_id: String, step_index: int, passed: bool, notes: String = "") -> void:
	for result in test_results["scenarios"]:
		if result["scenario_id"] == scenario_id:
			result["steps_completed"] += 1
			if passed:
				result["validation_passed"] += 1
			if not notes.is_empty():
				result["notes"].append("Step " + str(step_index + 1) + ": " + notes)
			break

func mark_scenario_completed(scenario_id: String, overall_passed: bool) -> void:
	for result in test_results["scenarios"]:
		if result["scenario_id"] == scenario_id:
			result["status"] = "COMPLETED"
			result["end_time"] = Time.get_datetime_string_from_system()
			result["overall_passed"] = overall_passed

			scenarios_completed += 1
			if overall_passed:
				scenarios_passed += 1

			# Update summary
			test_results["summary"]["completed_scenarios"] = scenarios_completed
			test_results["summary"]["passed_scenarios"] = scenarios_passed
			test_results["summary"]["failed_scenarios"] = scenarios_completed - scenarios_passed

			if scenarios_completed > 0:
				test_results["summary"]["pass_rate"] = float(scenarios_passed) / float(scenarios_completed)

			break

	# Check if all scenarios completed
	var total_scenarios: int = test_results["summary"]["total_scenarios"]
	if scenarios_completed >= total_scenarios:
		all_tests_completed.emit(test_results["summary"])

func add_issue(scenario_id: String, issue: String, severity: String = "MEDIUM") -> void:
	for result in test_results["scenarios"]:
		if result["scenario_id"] == scenario_id:
			result["issues_found"].append({
				"issue": issue,
				"severity": severity,
				"timestamp": Time.get_datetime_string_from_system()
			})
			break

func add_recommendation(scenario_id: String, recommendation: String) -> void:
	for result in test_results["scenarios"]:
		if result["scenario_id"] == scenario_id:
			result["recommendations"].append(recommendation)
			break

# Report Generation
func generate_test_report() -> String:
	var report: String = "# Coalition 150 Manual Test Report\n\n"
	report += "Generated: " + test_results["timestamp"] + "\n\n"

	# Summary
	var summary: Dictionary = test_results["summary"]
	report += "## Summary\n"
	report += "- **Total Scenarios**: %d\n" % summary["total_scenarios"]
	report += "- **Completed Scenarios**: %d\n" % summary["completed_scenarios"]
	report += "- **Passed Scenarios**: %d\n" % summary["passed_scenarios"]
	report += "- **Failed Scenarios**: %d\n" % summary["failed_scenarios"]
	report += "- **Pass Rate**: %.1f%%\n\n" % (summary["pass_rate"] * 100.0)

	# Detailed Results
	report += "## Detailed Results\n\n"

	for result in test_results["scenarios"]:
		var status_icon: String = "✅" if result.get("overall_passed", false) else "❌"
		report += "### %s %s\n" % [status_icon, result["scenario_name"]]
		report += "- **Status**: %s\n" % result["status"]
		report += "- **Steps Completed**: %d/%d\n" % [result["steps_completed"], result["total_steps"]]
		report += "- **Validations Passed**: %d/%d\n" % [result["validation_passed"], result["total_validations"]]

		if result.has("issues_found") and result["issues_found"].size() > 0:
			report += "- **Issues Found**:\n"
			for issue in result["issues_found"]:
				report += "  - [%s] %s\n" % [issue["severity"], issue["issue"]]

		if result.has("recommendations") and result["recommendations"].size() > 0:
			report += "- **Recommendations**:\n"
			for recommendation in result["recommendations"]:
				report += "  - %s\n" % recommendation

		report += "\n"

	return report

func save_test_report(file_path: String) -> bool:
	var report: String = generate_test_report()
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)

	if file:
		file.store_string(report)
		file.close()
		print("Manual test report saved to: " + file_path)
		return true
	else:
		push_error("Failed to save manual test report to: " + file_path)
		return false

# Get formatted test instructions for testers
func get_test_instructions() -> String:
	var instructions: String = "# Coalition 150 Manual Testing Instructions\n\n"
	instructions += "## Overview\n"
	instructions += "This document provides structured manual testing scenarios for the Coalition 150 player creation flow.\n\n"

	instructions += "## Pre-Testing Setup\n"
	instructions += "1. Launch Godot editor with Coalition 150 project\n"
	instructions += "2. Ensure all scenes are properly configured\n"
	instructions += "3. Clear any existing save data for clean testing\n"
	instructions += "4. Have stopwatch ready for performance measurements\n\n"

	instructions += "## Testing Scenarios\n\n"

	var scenarios: Array[Dictionary] = get_test_scenarios()
	for scenario in scenarios:
		instructions += "### %s\n" % scenario["name"]
		instructions += "**Category**: %s | **Priority**: %s | **Time**: %s\n\n" % [
			scenario["category"], scenario["priority"], scenario["estimated_time"]
		]

		instructions += "%s\n\n" % scenario["description"]

		instructions += "#### Steps to Follow:\n"
		for step in scenario["steps"]:
			instructions += "%s\n" % step
		instructions += "\n"

		instructions += "#### Expected Outcomes:\n"
		for outcome in scenario["expected_outcomes"]:
			instructions += "- %s\n" % outcome
		instructions += "\n"

		instructions += "#### Validation Points:\n"
		for validation in scenario["validation_points"]:
			instructions += "%s\n" % validation
		instructions += "\n---\n\n"

	instructions += "## Recording Results\n"
	instructions += "For each scenario:\n"
	instructions += "1. Note start and end times\n"
	instructions += "2. Record any issues encountered\n"
	instructions += "3. Verify all validation points\n"
	instructions += "4. Document performance observations\n"
	instructions += "5. Rate overall scenario success (Pass/Fail)\n\n"

	instructions += "## Reporting Issues\n"
	instructions += "When documenting issues:\n"
	instructions += "- Provide clear reproduction steps\n"
	instructions += "- Note severity (High/Medium/Low)\n"
	instructions += "- Include screenshots if relevant\n"
	instructions += "- Suggest potential solutions\n"

	return instructions

# Static function for quick access
static func get_quick_test_scenarios() -> Array[Dictionary]:
	var tester: ManualTestScenarios = ManualTestScenarios.new()
	return tester.get_test_scenarios()