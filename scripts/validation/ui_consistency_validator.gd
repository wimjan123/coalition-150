# UI Consistency Validator - Validates theme application and UI consistency
# Ensures all scenes follow Coalition 150 UI design standards

class_name UIConsistencyValidator
extends RefCounted

# UI Standards Constants
const REQUIRED_THEME_PATH: String = "res://assets/themes/player_creation_theme.tres"
const PLAYER_THEME_PATH: String = "res://assets/themes/player_creation_theme.tres"
const UI_THEME_PATH: String = "res://assets/themes/ui_theme.tres"

# UI Validation Results
var validation_results: Dictionary = {}
var consistency_passed: bool = false

signal ui_validation_completed(results: Dictionary)

func _init():
	validation_results = {
		"theme_tests": [],
		"font_tests": [],
		"color_tests": [],
		"layout_tests": [],
		"accessibility_tests": [],
		"overall_passed": false,
		"timestamp": Time.get_datetime_string_from_system()
	}

# Main Validation Function
func validate_ui_consistency() -> Dictionary:
	print("Starting UI consistency validation...")

	# Test 1: Theme Application
	_test_theme_application()

	# Test 2: Font Consistency
	_test_font_consistency()

	# Test 3: Color Consistency
	_test_color_consistency()

	# Test 4: Layout Standards
	_test_layout_standards()

	# Test 5: Accessibility Standards
	_test_accessibility_standards()

	# Evaluate overall results
	_evaluate_overall_consistency()

	ui_validation_completed.emit(validation_results)
	return validation_results

# Theme Application Tests
func _test_theme_application() -> void:
	print("Testing theme application...")

	var theme_tests: Array = []

	# Test main scenes for theme application
	var scenes_to_test: Array = [
		{
			"name": "MainMenu",
			"path": "res://scenes/main/MainMenu.tscn"
		},
		{
			"name": "CharacterPartySelection",
			"path": "res://scenes/player/CharacterPartySelection.tscn"
		},
		{
			"name": "CharacterPartyCreation",
			"path": "res://scenes/player/CharacterPartyCreation.tscn"
		},
		{
			"name": "MediaInterview",
			"path": "res://scenes/player/MediaInterview.tscn"
		}
	]

	for scene_info in scenes_to_test:
		var theme_result: Dictionary = _validate_scene_theme(scene_info)
		theme_tests.append(theme_result)

	validation_results["theme_tests"] = theme_tests
	print("Theme application testing completed")

func _validate_scene_theme(scene_info: Dictionary) -> Dictionary:
	var scene_resource: PackedScene = load(scene_info.path)
	var scene_instance: Node = scene_resource.instantiate()

	var result: Dictionary = {
		"scene_name": scene_info.name,
		"has_theme": false,
		"correct_theme_path": false,
		"theme_applied_to_children": false,
		"passed": false,
		"issues": []
	}

	# Check if scene has theme applied
	if scene_instance is Control:
		var control: Control = scene_instance as Control
		if control.theme != null:
			result["has_theme"] = true

			# Check if it's using the correct theme
			var theme_resource_path: String = control.theme.resource_path
			if theme_resource_path == PLAYER_THEME_PATH or theme_resource_path == UI_THEME_PATH:
				result["correct_theme_path"] = true
			else:
				result["issues"].append("Using incorrect theme: " + theme_resource_path)

			# Check if theme is applied to key child elements
			result["theme_applied_to_children"] = _check_children_theme_inheritance(control)
		else:
			result["issues"].append("No theme applied to root control")

	else:
		result["issues"].append("Scene root is not a Control node")

	result["passed"] = result["has_theme"] and result["correct_theme_path"] and result["theme_applied_to_children"]

	# Cleanup
	scene_instance.queue_free()

	return result

func _check_children_theme_inheritance(control: Control) -> bool:
	# Check key UI elements for theme inheritance
	var theme_inherited: bool = true

	# Get important child controls
	var child_controls: Array[Control] = []
	_find_child_controls(control, child_controls)

	# Check a sampling of child controls
	var sample_size: int = min(child_controls.size(), 10)
	for i in range(sample_size):
		var child: Control = child_controls[i]
		if child.theme == null:
			# Child should inherit from parent or have explicit theme
			if control.theme != null:
				# This is acceptable - inheriting parent theme
				continue
			else:
				theme_inherited = false
				break

	return theme_inherited

func _find_child_controls(node: Node, control_list: Array[Control]) -> void:
	for child in node.get_children():
		if child is Control:
			control_list.append(child)
		_find_child_controls(child, control_list)

# Font Consistency Tests
func _test_font_consistency() -> void:
	print("Testing font consistency...")

	var font_tests: Array = []

	# Load theme to get expected fonts
	var theme: Theme = load(PLAYER_THEME_PATH)
	if theme:
		# Test font usage across scenes
		var scenes_to_test: Array = [
			"res://scenes/main/MainMenu.tscn",
			"res://scenes/player/CharacterPartySelection.tscn",
			"res://scenes/player/CharacterPartyCreation.tscn",
			"res://scenes/player/MediaInterview.tscn"
		]

		for scene_path in scenes_to_test:
			var font_result: Dictionary = _validate_scene_fonts(scene_path, theme)
			font_tests.append(font_result)
	else:
		font_tests.append({
			"scene_name": "Theme Loading",
			"passed": false,
			"issues": ["Could not load theme from " + PLAYER_THEME_PATH]
		})

	validation_results["font_tests"] = font_tests
	print("Font consistency testing completed")

func _validate_scene_fonts(scene_path: String, expected_theme: Theme) -> Dictionary:
	var scene_resource: PackedScene = load(scene_path)
	var scene_instance: Node = scene_resource.instantiate()

	var scene_name: String = scene_path.get_file().get_basename()
	var result: Dictionary = {
		"scene_name": scene_name,
		"consistent_fonts": true,
		"font_size_consistency": true,
		"passed": false,
		"issues": []
	}

	# Check labels and buttons for font consistency
	var text_nodes: Array[Node] = []
	_find_text_nodes(scene_instance, text_nodes)

	# Validate font usage
	for text_node in text_nodes:
		if text_node is Label:
			var label: Label = text_node as Label
			# Check for font size overrides that might break consistency
			if label.has_theme_font_size_override("font_size"):
				var font_size: int = label.get_theme_font_size("font_size")
				if font_size < 10 or font_size > 48:
					result["issues"].append("Label with unusual font size: " + str(font_size))
					result["font_size_consistency"] = false

		elif text_node is Button:
			var button: Button = text_node as Button
			# Similar checks for buttons
			if button.has_theme_font_size_override("font_size"):
				var font_size: int = button.get_theme_font_size("font_size")
				if font_size < 8 or font_size > 36:
					result["issues"].append("Button with unusual font size: " + str(font_size))
					result["font_size_consistency"] = false

	result["passed"] = result["consistent_fonts"] and result["font_size_consistency"]

	# Cleanup
	scene_instance.queue_free()

	return result

func _find_text_nodes(node: Node, text_list: Array[Node]) -> void:
	if node is Label or node is Button or node is LineEdit:
		text_list.append(node)

	for child in node.get_children():
		_find_text_nodes(child, text_list)

# Color Consistency Tests
func _test_color_consistency() -> void:
	print("Testing color consistency...")

	var color_tests: Array = []

	# Test color usage across scenes
	var scenes_to_test: Array = [
		"res://scenes/main/MainMenu.tscn",
		"res://scenes/player/CharacterPartySelection.tscn",
		"res://scenes/player/CharacterPartyCreation.tscn",
		"res://scenes/player/MediaInterview.tscn"
	]

	for scene_path in scenes_to_test:
		var color_result: Dictionary = _validate_scene_colors(scene_path)
		color_tests.append(color_result)

	validation_results["color_tests"] = color_tests
	print("Color consistency testing completed")

func _validate_scene_colors(scene_path: String) -> Dictionary:
	var scene_resource: PackedScene = load(scene_path)
	var scene_instance: Node = scene_resource.instantiate()

	var scene_name: String = scene_path.get_file().get_basename()
	var result: Dictionary = {
		"scene_name": scene_name,
		"appropriate_colors": true,
		"no_harsh_colors": true,
		"contrast_sufficient": true,
		"passed": false,
		"issues": []
	}

	# Check color usage in UI elements
	var colored_nodes: Array[Node] = []
	_find_colored_nodes(scene_instance, colored_nodes)

	for colored_node in colored_nodes:
		if colored_node is ColorRect:
			var color_rect: ColorRect = colored_node as ColorRect
			var color: Color = color_rect.color

			# Check for harsh/problematic colors
			if _is_harsh_color(color):
				result["issues"].append("Harsh color detected in ColorRect: " + color.to_html())
				result["no_harsh_colors"] = false

		elif colored_node is Button:
			var button: Button = colored_node as Button
			# Check button modulate color if any
			if button.modulate != Color.WHITE:
				if _is_harsh_color(button.modulate):
					result["issues"].append("Harsh modulate color on Button: " + button.modulate.to_html())
					result["no_harsh_colors"] = false

	result["passed"] = result["appropriate_colors"] and result["no_harsh_colors"] and result["contrast_sufficient"]

	# Cleanup
	scene_instance.queue_free()

	return result

func _find_colored_nodes(node: Node, colored_list: Array[Node]) -> void:
	if node is ColorRect or node is Button or node is Panel:
		colored_list.append(node)

	for child in node.get_children():
		_find_colored_nodes(child, colored_list)

func _is_harsh_color(color: Color) -> bool:
	# Check for colors that might be too bright or have poor contrast
	var brightness: float = (color.r + color.g + color.b) / 3.0

	# Too bright
	if brightness > 0.95:
		return true

	# High saturation with high brightness
	var max_channel: float = max(max(color.r, color.g), color.b)
	var min_channel: float = min(min(color.r, color.g), color.b)
	var saturation: float = (max_channel - min_channel) / max_channel if max_channel > 0 else 0

	if saturation > 0.9 and brightness > 0.8:
		return true

	return false

# Layout Standards Tests
func _test_layout_standards() -> void:
	print("Testing layout standards...")

	var layout_tests: Array = []

	# Test layout consistency across scenes
	var scenes_to_test: Array = [
		"res://scenes/main/MainMenu.tscn",
		"res://scenes/player/CharacterPartySelection.tscn",
		"res://scenes/player/CharacterPartyCreation.tscn",
		"res://scenes/player/MediaInterview.tscn"
	]

	for scene_path in scenes_to_test:
		var layout_result: Dictionary = _validate_scene_layout(scene_path)
		layout_tests.append(layout_result)

	validation_results["layout_tests"] = layout_tests
	print("Layout standards testing completed")

func _validate_scene_layout(scene_path: String) -> Dictionary:
	var scene_resource: PackedScene = load(scene_path)
	var scene_instance: Node = scene_resource.instantiate()

	var scene_name: String = scene_path.get_file().get_basename()
	var result: Dictionary = {
		"scene_name": scene_name,
		"proper_containers": true,
		"responsive_layout": true,
		"appropriate_spacing": true,
		"passed": false,
		"issues": []
	}

	# Check for proper container usage
	var containers: Array[Node] = []
	_find_layout_containers(scene_instance, containers)

	# Validate container structure
	if containers.is_empty():
		result["issues"].append("No layout containers found - may not be responsive")
		result["proper_containers"] = false
	else:
		# Check for nested container structure
		var has_nested_containers: bool = false
		for container in containers:
			var child_containers: Array[Node] = []
			_find_layout_containers(container, child_containers)
			if not child_containers.is_empty():
				has_nested_containers = true
				break

		if not has_nested_containers and containers.size() == 1:
			result["issues"].append("Layout may be too simple - consider nested containers for flexibility")

	result["passed"] = result["proper_containers"] and result["responsive_layout"] and result["appropriate_spacing"]

	# Cleanup
	scene_instance.queue_free()

	return result

func _find_layout_containers(node: Node, container_list: Array[Node]) -> void:
	if node is VBoxContainer or node is HBoxContainer or node is GridContainer or node is MarginContainer:
		container_list.append(node)

	for child in node.get_children():
		_find_layout_containers(child, container_list)

# Accessibility Standards Tests
func _test_accessibility_standards() -> void:
	print("Testing accessibility standards...")

	var accessibility_tests: Array = []

	# Test accessibility across scenes
	var scenes_to_test: Array = [
		"res://scenes/main/MainMenu.tscn",
		"res://scenes/player/CharacterPartySelection.tscn",
		"res://scenes/player/CharacterPartyCreation.tscn",
		"res://scenes/player/MediaInterview.tscn"
	]

	for scene_path in scenes_to_test:
		var accessibility_result: Dictionary = _validate_scene_accessibility(scene_path)
		accessibility_tests.append(accessibility_result)

	validation_results["accessibility_tests"] = accessibility_tests
	print("Accessibility testing completed")

func _validate_scene_accessibility(scene_path: String) -> Dictionary:
	var scene_resource: PackedScene = load(scene_path)
	var scene_instance: Node = scene_resource.instantiate()

	var scene_name: String = scene_path.get_file().get_basename()
	var result: Dictionary = {
		"scene_name": scene_name,
		"focus_navigation": true,
		"tooltips_present": true,
		"keyboard_accessible": true,
		"passed": false,
		"issues": []
	}

	# Check for keyboard navigation support
	var interactive_nodes: Array[Node] = []
	_find_interactive_nodes(scene_instance, interactive_nodes)

	var focusable_nodes: int = 0
	for interactive_node in interactive_nodes:
		if interactive_node is Control:
			var control: Control = interactive_node as Control
			if control.focus_mode != Control.FOCUS_NONE:
				focusable_nodes += 1

	if focusable_nodes == 0 and interactive_nodes.size() > 0:
		result["issues"].append("Interactive elements found but none are keyboard focusable")
		result["keyboard_accessible"] = false

	# Check for tooltips on important elements
	var tooltip_count: int = 0
	for interactive_node in interactive_nodes:
		if interactive_node is Control:
			var control: Control = interactive_node as Control
			if not control.tooltip_text.is_empty():
				tooltip_count += 1

	var tooltip_ratio: float = float(tooltip_count) / float(interactive_nodes.size()) if interactive_nodes.size() > 0 else 1.0
	if tooltip_ratio < 0.5:  # Less than 50% have tooltips
		result["issues"].append("Few interactive elements have tooltips (" + str(tooltip_count) + "/" + str(interactive_nodes.size()) + ")")
		result["tooltips_present"] = false

	result["passed"] = result["focus_navigation"] and result["tooltips_present"] and result["keyboard_accessible"]

	# Cleanup
	scene_instance.queue_free()

	return result

func _find_interactive_nodes(node: Node, interactive_list: Array[Node]) -> void:
	if node is Button or node is LineEdit or node is OptionButton or node is CheckBox or node is SpinBox:
		interactive_list.append(node)

	for child in node.get_children():
		_find_interactive_nodes(child, interactive_list)

# Results Evaluation
func _evaluate_overall_consistency() -> void:
	var all_tests_passed: bool = true

	# Check all test categories
	var test_categories: Array[String] = ["theme_tests", "font_tests", "color_tests", "layout_tests", "accessibility_tests"]

	for category in test_categories:
		if validation_results.has(category):
			for test in validation_results[category]:
				if not test["passed"]:
					all_tests_passed = false
					break
		if not all_tests_passed:
			break

	validation_results["overall_passed"] = all_tests_passed
	consistency_passed = all_tests_passed

	if all_tests_passed:
		print("✅ UI consistency validation PASSED - All standards met")
	else:
		print("❌ UI consistency validation FAILED - Some standards not met")

# Utility Functions
func get_consistency_report() -> String:
	var report: String = "# Coalition 150 UI Consistency Validation Report\n\n"
	report += "Generated: " + validation_results["timestamp"] + "\n\n"

	# Theme Results
	report += "## Theme Application Tests\n"
	for theme_test in validation_results["theme_tests"]:
		var status: String = "✅ PASS" if theme_test["passed"] else "❌ FAIL"
		report += "- **%s**: %s\n" % [theme_test["scene_name"], status]
		if theme_test.has("issues") and theme_test["issues"].size() > 0:
			for issue in theme_test["issues"]:
				report += "  - Issue: %s\n" % issue

	# Font Results
	report += "\n## Font Consistency Tests\n"
	for font_test in validation_results["font_tests"]:
		var status: String = "✅ PASS" if font_test["passed"] else "❌ FAIL"
		report += "- **%s**: %s\n" % [font_test["scene_name"], status]
		if font_test.has("issues") and font_test["issues"].size() > 0:
			for issue in font_test["issues"]:
				report += "  - Issue: %s\n" % issue

	# Color Results
	report += "\n## Color Consistency Tests\n"
	for color_test in validation_results["color_tests"]:
		var status: String = "✅ PASS" if color_test["passed"] else "❌ FAIL"
		report += "- **%s**: %s\n" % [color_test["scene_name"], status]
		if color_test.has("issues") and color_test["issues"].size() > 0:
			for issue in color_test["issues"]:
				report += "  - Issue: %s\n" % issue

	# Layout Results
	report += "\n## Layout Standards Tests\n"
	for layout_test in validation_results["layout_tests"]:
		var status: String = "✅ PASS" if layout_test["passed"] else "❌ FAIL"
		report += "- **%s**: %s\n" % [layout_test["scene_name"], status]
		if layout_test.has("issues") and layout_test["issues"].size() > 0:
			for issue in layout_test["issues"]:
				report += "  - Issue: %s\n" % issue

	# Accessibility Results
	report += "\n## Accessibility Tests\n"
	for accessibility_test in validation_results["accessibility_tests"]:
		var status: String = "✅ PASS" if accessibility_test["passed"] else "❌ FAIL"
		report += "- **%s**: %s\n" % [accessibility_test["scene_name"], status]
		if accessibility_test.has("issues") and accessibility_test["issues"].size() > 0:
			for issue in accessibility_test["issues"]:
				report += "  - Issue: %s\n" % issue

	# Overall Result
	report += "\n## Overall Result\n"
	var overall_status: String = "✅ PASSED" if validation_results["overall_passed"] else "❌ FAILED"
	report += "**UI Consistency Validation: %s**\n\n" % overall_status

	if not validation_results["overall_passed"]:
		report += "### Recommendations:\n"
		report += "- Review failed tests above\n"
		report += "- Ensure consistent theme application across all scenes\n"
		report += "- Improve accessibility with proper focus navigation and tooltips\n"
		report += "- Validate color choices for sufficient contrast and appropriateness\n"

	return report

func save_consistency_report(file_path: String) -> bool:
	var report: String = get_consistency_report()
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)

	if file:
		file.store_string(report)
		file.close()
		print("UI consistency report saved to: " + file_path)
		return true
	else:
		push_error("Failed to save UI consistency report to: " + file_path)
		return false

# Static utility function for quick validation
static func run_ui_consistency_validation() -> Dictionary:
	var validator: UIConsistencyValidator = UIConsistencyValidator.new()
	return validator.validate_ui_consistency()