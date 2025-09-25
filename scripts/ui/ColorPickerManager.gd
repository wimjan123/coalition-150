# ColorPickerManager - Manages color selection for party creation
# Provides advanced color picker functionality with presets

class_name ColorPickerManager
extends RefCounted

# Color presets for political parties
const PARTY_COLOR_PRESETS: Array[Color] = [
	Color(0.8, 0.2, 0.2, 1.0),  # Red
	Color(0.2, 0.2, 0.8, 1.0),  # Blue
	Color(0.2, 0.7, 0.2, 1.0),  # Green
	Color(0.8, 0.8, 0.2, 1.0),  # Yellow
	Color(0.6, 0.2, 0.8, 1.0),  # Purple
	Color(0.8, 0.5, 0.2, 1.0),  # Orange
	Color(0.2, 0.6, 0.8, 1.0),  # Light Blue
	Color(0.5, 0.3, 0.1, 1.0),  # Brown
	Color(0.8, 0.2, 0.6, 1.0),  # Pink
	Color(0.3, 0.3, 0.3, 1.0)   # Dark Gray
]

# Popular political color schemes
const POLITICAL_SCHEMES: Dictionary = {
	"conservative": Color(0.2, 0.3, 0.7, 1.0),      # Conservative Blue
	"progressive": Color(0.1, 0.6, 0.3, 1.0),       # Progressive Green
	"liberal": Color(0.8, 0.3, 0.2, 1.0),           # Liberal Red
	"centrist": Color(0.6, 0.4, 0.8, 1.0),          # Centrist Purple
	"populist": Color(0.9, 0.6, 0.1, 1.0),          # Populist Orange
	"socialist": Color(0.8, 0.1, 0.1, 1.0),         # Socialist Red
	"environmental": Color(0.2, 0.7, 0.2, 1.0),     # Environmental Green
	"nationalist": Color(0.5, 0.2, 0.1, 1.0),       # Nationalist Brown
	"reform": Color(0.3, 0.5, 0.9, 1.0),            # Reform Blue
	"independent": Color(0.4, 0.4, 0.4, 1.0)        # Independent Gray
}

# Current color state
var current_color: Color = Color.WHITE
var color_picker: ColorPicker = null
var preview_rect: ColorRect = null

signal color_changed(color: Color)
signal preset_selected(color: Color, scheme_name: String)

func _init(picker: ColorPicker = null) -> void:
	if picker:
		set_color_picker(picker)

# Set the ColorPicker control to manage
func set_color_picker(picker: ColorPicker) -> void:
	color_picker = picker
	if color_picker:
		color_picker.color_changed.connect(_on_color_changed)
		color_picker.preset_added.connect(_on_preset_added)

# Set preview rect for color display
func set_preview_rect(rect: ColorRect) -> void:
	preview_rect = rect

# Get current selected color
func get_current_color() -> Color:
	if color_picker:
		return color_picker.color
	return current_color

# Set color programmatically
func set_color(color: Color) -> void:
	current_color = color
	if color_picker:
		color_picker.color = color
	if preview_rect:
		preview_rect.color = color
	color_changed.emit(color)

# Add party color presets to the color picker
func add_party_presets() -> void:
	if not color_picker:
		push_warning("No ColorPicker assigned to ColorPickerManager")
		return

	for preset_color in PARTY_COLOR_PRESETS:
		color_picker.add_preset(preset_color)

# Add political scheme presets
func add_political_presets() -> void:
	if not color_picker:
		push_warning("No ColorPicker assigned to ColorPickerManager")
		return

	for scheme_name in POLITICAL_SCHEMES:
		var scheme_color: Color = POLITICAL_SCHEMES[scheme_name]
		color_picker.add_preset(scheme_color)

# Get color scheme name for a color (if it matches a scheme)
func get_color_scheme_name(color: Color) -> String:
	for scheme_name in POLITICAL_SCHEMES:
		var scheme_color: Color = POLITICAL_SCHEMES[scheme_name]
		if color.is_equal_approx(scheme_color):
			return scheme_name
	return ""

# Get complementary color for text/UI elements
func get_complementary_color(base_color: Color = Color()) -> Color:
	var target_color: Color = base_color if base_color != Color() else get_current_color()

	# Calculate luminance to determine if text should be light or dark
	var luminance: float = 0.299 * target_color.r + 0.587 * target_color.g + 0.114 * target_color.b

	# Return white text for dark colors, black text for light colors
	return Color.WHITE if luminance < 0.5 else Color.BLACK

# Get color accessibility information
func get_accessibility_info(background_color: Color = Color()) -> Dictionary:
	var target_color: Color = background_color if background_color != Color() else get_current_color()
	var contrast_white: float = _calculate_contrast_ratio(target_color, Color.WHITE)
	var contrast_black: float = _calculate_contrast_ratio(target_color, Color.BLACK)

	return {
		"luminance": 0.299 * target_color.r + 0.587 * target_color.g + 0.114 * target_color.b,
		"contrast_white": contrast_white,
		"contrast_black": contrast_black,
		"wcag_aa_white": contrast_white >= 4.5,
		"wcag_aa_black": contrast_black >= 4.5,
		"recommended_text": Color.WHITE if contrast_white > contrast_black else Color.BLACK
	}

# Generate random political party color
func generate_random_party_color() -> Color:
	return PARTY_COLOR_PRESETS[randi() % PARTY_COLOR_PRESETS.size()]

# Create gradient from party color
func create_party_gradient(base_color: Color = Color()) -> Gradient:
	var target_color: Color = base_color if base_color != Color() else get_current_color()
	var gradient: Gradient = Gradient.new()

	# Create a subtle gradient from darker to lighter
	var darker: Color = target_color.darkened(0.3)
	var lighter: Color = target_color.lightened(0.3)

	gradient.add_point(0.0, darker)
	gradient.add_point(0.5, target_color)
	gradient.add_point(1.0, lighter)

	return gradient

# Validate color for political branding
func validate_party_color(color: Color) -> Dictionary:
	var validation: Dictionary = {
		"valid": true,
		"warnings": [],
		"suggestions": []
	}

	# Check if color is too dark
	var luminance: float = 0.299 * color.r + 0.587 * color.g + 0.114 * color.b
	if luminance < 0.15:
		validation.warnings.append("Color may be too dark for visibility")
		validation.suggestions.append("Consider a lighter shade")

	# Check if color is too light
	if luminance > 0.85:
		validation.warnings.append("Color may be too light for contrast")
		validation.suggestions.append("Consider a darker shade")

	# Check if color is too saturated
	var max_channel: float = max(max(color.r, color.g), color.b)
	var min_channel: float = min(min(color.r, color.g), color.b)
	var saturation: float = (max_channel - min_channel) / max_channel if max_channel > 0 else 0

	if saturation > 0.9:
		validation.warnings.append("Color is very saturated - may be harsh on eyes")
		validation.suggestions.append("Consider reducing saturation slightly")

	return validation

# Get color as HTML hex string
func get_color_hex(color: Color = Color()) -> String:
	var target_color: Color = color if color != Color() else get_current_color()
	return target_color.to_html()

# Event Handlers

func _on_color_changed(color: Color) -> void:
	current_color = color
	if preview_rect:
		preview_rect.color = color

	# Check if this matches a political scheme
	var scheme_name: String = get_color_scheme_name(color)
	if not scheme_name.is_empty():
		preset_selected.emit(color, scheme_name)

	color_changed.emit(color)

func _on_preset_added(color: Color) -> void:
	print("Color preset added: ", color.to_html())

# Helper function to calculate contrast ratio for accessibility
func _calculate_contrast_ratio(color1: Color, color2: Color) -> float:
	var lum1: float = _get_relative_luminance(color1)
	var lum2: float = _get_relative_luminance(color2)

	var lighter: float = max(lum1, lum2)
	var darker: float = min(lum1, lum2)

	return (lighter + 0.05) / (darker + 0.05)

func _get_relative_luminance(color: Color) -> float:
	var r: float = _linearize_channel(color.r)
	var g: float = _linearize_channel(color.g)
	var b: float = _linearize_channel(color.b)

	return 0.2126 * r + 0.7152 * g + 0.0722 * b

func _linearize_channel(value: float) -> float:
	if value <= 0.03928:
		return value / 12.92
	else:
		return pow((value + 0.055) / 1.055, 2.4)