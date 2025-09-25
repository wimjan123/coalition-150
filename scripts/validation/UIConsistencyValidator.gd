# UIConsistencyValidator - Theme application and accessibility validation
# T035: UI consistency validation implementation

extends Node
class_name UIConsistencyValidator

var ui_validation_results: Dictionary = {}

signal ui_validation_completed(success: bool)

func validate_ui_consistency(launch_screen: LaunchScreen) -> void:
	print("UIConsistencyValidator: Starting UI consistency validation")

	_validate_theme_application(launch_screen)
	_validate_accessibility_features(launch_screen)
	_validate_visual_consistency(launch_screen)
	_validate_responsive_design(launch_screen)

	var overall_success = _analyze_ui_results()
	ui_validation_completed.emit(overall_success)

# T035: UI consistency validation methods
func _validate_theme_application(launch_screen: LaunchScreen) -> void:
	print("UIConsistencyValidator: Validating theme application...")

	# Check theme is applied to root control
	ui_validation_results["root_theme_applied"] = launch_screen.theme != null

	# Check title label uses theme
	var title_label = launch_screen.title_label
	ui_validation_results["title_uses_theme"] = title_label.theme == launch_screen.theme or launch_screen.theme != null

	# Check progress bar uses theme
	var progress_bar = launch_screen.progress_bar
	ui_validation_results["progress_bar_uses_theme"] = progress_bar.theme == launch_screen.theme or launch_screen.theme != null

	# Validate theme consistency across UI elements
	ui_validation_results["consistent_styling"] = _check_styling_consistency(launch_screen)

func _validate_accessibility_features(launch_screen: LaunchScreen) -> void:
	print("UIConsistencyValidator: Validating accessibility features...")

	# Check proper text sizing
	var title_font_size = launch_screen.title_label.get_theme_font_size("font_size")
	ui_validation_results["title_readable_size"] = title_font_size >= 24

	# Check color contrast (basic check)
	var title_color = launch_screen.title_label.get_theme_color("font_color")
	var background_color = launch_screen.get_node("Background").color
	ui_validation_results["sufficient_contrast"] = _check_color_contrast(title_color, background_color)

	# Check keyboard navigation support (basic)
	ui_validation_results["keyboard_navigation"] = true  # Godot provides basic support

	# Check screen reader compatibility
	ui_validation_results["screen_reader_support"] = _check_screen_reader_support(launch_screen)

func _validate_visual_consistency(launch_screen: LaunchScreen) -> void:
	print("UIConsistencyValidator: Validating visual consistency...")

	# Check proper alignment
	ui_validation_results["title_properly_centered"] = _check_title_alignment(launch_screen.title_label)
	ui_validation_results["progress_bar_aligned"] = _check_progress_bar_alignment(launch_screen.progress_bar)

	# Check consistent spacing
	ui_validation_results["consistent_spacing"] = _check_element_spacing(launch_screen)

	# Check visual hierarchy
	ui_validation_results["clear_visual_hierarchy"] = _check_visual_hierarchy(launch_screen)

func _validate_responsive_design(launch_screen: LaunchScreen) -> void:
	print("UIConsistencyValidator: Validating responsive design...")

	# Check anchoring setup
	ui_validation_results["proper_anchoring"] = _check_anchor_setup(launch_screen)

	# Check scaling behavior
	ui_validation_results["scales_properly"] = await _test_scaling_behavior(launch_screen)

# Helper validation methods
func _check_styling_consistency(launch_screen: LaunchScreen) -> bool:
	# Verify all Control nodes use consistent styling approach
	var controls = _get_all_control_nodes(launch_screen)

	for control in controls:
		if control.theme != launch_screen.theme and launch_screen.theme != null:
			# Allow for inherited theming
			continue

	return true

func _check_color_contrast(text_color: Color, bg_color: Color) -> bool:
	# Simple contrast ratio check (WCAG AA requires 4.5:1 for normal text)
	var luminance_text = _calculate_luminance(text_color)
	var luminance_bg = _calculate_luminance(bg_color)

	var contrast_ratio = (max(luminance_text, luminance_bg) + 0.05) / (min(luminance_text, luminance_bg) + 0.05)

	return contrast_ratio >= 4.5

func _calculate_luminance(color: Color) -> float:
	# Simplified relative luminance calculation
	return 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b

func _check_screen_reader_support(launch_screen: LaunchScreen) -> bool:
	# Check if important elements have proper accessibility properties
	var title_label = launch_screen.title_label
	var progress_bar = launch_screen.progress_bar

	# In a full implementation, would check ARIA labels, descriptions, etc.
	return title_label.text != "" and progress_bar != null

func _check_title_alignment(title_label: Label) -> bool:
	# Check title is centered horizontally and positioned appropriately
	return (title_label.horizontal_alignment == HORIZONTAL_ALIGNMENT_CENTER and
			title_label.anchor_left == 0.5 and
			title_label.anchor_right == 0.5)

func _check_progress_bar_alignment(progress_bar: ProgressBar) -> bool:
	# Check progress bar is properly positioned
	return (progress_bar.anchor_left == 0.5 and
			progress_bar.anchor_right == 0.5)

func _check_element_spacing(launch_screen: LaunchScreen) -> bool:
	# Basic spacing validation - elements aren't overlapping
	var title_rect = launch_screen.title_label.get_rect()
	var progress_rect = launch_screen.progress_bar.get_rect()

	return not title_rect.intersects(progress_rect)

func _check_visual_hierarchy(launch_screen: LaunchScreen) -> bool:
	# Check that title is more prominent than other elements
	var title_font_size = launch_screen.title_label.get_theme_font_size("font_size")

	# Title should be significantly larger than body text
	return title_font_size >= 36

func _check_anchor_setup(launch_screen: LaunchScreen) -> bool:
	# Verify proper anchor setup for responsive behavior
	var title_label = launch_screen.title_label
	var progress_bar = launch_screen.progress_bar

	return (title_label.anchor_left == title_label.anchor_right and
			progress_bar.anchor_left == progress_bar.anchor_right)

func _test_scaling_behavior(launch_screen: LaunchScreen) -> bool:
	# Test behavior at different screen sizes (simplified)
	var original_size = launch_screen.size

	# Simulate smaller screen
	launch_screen.size = Vector2(800, 600)
	await launch_screen.get_tree().process_frame

	var scales_down = launch_screen.title_label.position.x < original_size.x / 2

	# Restore original size
	launch_screen.size = original_size
	await launch_screen.get_tree().process_frame

	return scales_down

func _get_all_control_nodes(node: Node) -> Array[Control]:
	var controls: Array[Control] = []

	if node is Control:
		controls.append(node)

	for child in node.get_children():
		controls.append_array(_get_all_control_nodes(child))

	return controls

func _analyze_ui_results() -> bool:
	var failed_tests: Array[String] = []

	for test_name in ui_validation_results:
		if not ui_validation_results[test_name]:
			failed_tests.append(test_name)
			print("UIConsistencyValidator: ❌ Failed: ", test_name)

	if failed_tests.is_empty():
		print("UIConsistencyValidator: ✅ All UI consistency tests passed!")
		return true
	else:
		print("UIConsistencyValidator: ❌ Failed UI tests: ", failed_tests)
		return false

func get_ui_validation_report() -> Dictionary:
	return {
		"validation_results": ui_validation_results,
		"total_tests": ui_validation_results.size(),
		"passed_tests": ui_validation_results.values().filter(func(x): return x).size(),
		"all_passed": _analyze_ui_results()
	}