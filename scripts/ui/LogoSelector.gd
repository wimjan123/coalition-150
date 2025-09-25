# LogoSelector - Manages logo selection for party creation
# Provides logo selection functionality with preview and validation

class_name LogoSelector
extends RefCounted

# Logo configuration
const LOGO_COUNT: int = 5
const LOGO_BASE_PATH: String = "res://assets/logos/"
const LOGO_PLACEHOLDER_COLOR: Color = Color(0.7, 0.7, 0.7, 1.0)

# Logo metadata
const LOGO_INFO: Array[Dictionary] = [
	{
		"name": "Star",
		"description": "Classic star symbol representing excellence and achievement",
		"style": "traditional",
		"filename": "party_logo_0.png"
	},
	{
		"name": "Eagle",
		"description": "Powerful eagle representing freedom and strength",
		"style": "strong",
		"filename": "party_logo_1.png"
	},
	{
		"name": "Tree",
		"description": "Growing tree representing progress and sustainability",
		"style": "environmental",
		"filename": "party_logo_2.png"
	},
	{
		"name": "Shield",
		"description": "Protective shield representing security and stability",
		"style": "protective",
		"filename": "party_logo_3.png"
	},
	{
		"name": "Circle",
		"description": "Unity circle representing inclusion and cooperation",
		"style": "inclusive",
		"filename": "party_logo_4.png"
	}
]

# State
var selected_logo_index: int = 0
var logo_buttons: Array[Button] = []
var preview_texture_rect: TextureRect = null
var logo_textures: Array[Texture2D] = []

signal logo_selected(logo_index: int, logo_info: Dictionary)
signal logo_previewed(logo_index: int)

func _init() -> void:
	_load_logo_textures()

# Set up logo buttons for selection
func setup_logo_buttons(buttons: Array[Button]) -> void:
	logo_buttons = buttons

	for i in range(min(buttons.size(), LOGO_COUNT)):
		var button: Button = buttons[i]
		var logo_info: Dictionary = LOGO_INFO[i]

		# Set button properties
		button.text = logo_info.name
		button.tooltip_text = logo_info.description
		button.toggle_mode = true

		# Try to set logo texture if available
		if i < logo_textures.size() and logo_textures[i]:
			button.icon = logo_textures[i]
			button.expand_icon = true
		else:
			# Create placeholder
			_create_placeholder_texture(button, i)

		# Connect signal
		button.pressed.connect(_on_logo_button_pressed.bind(i))

	# Select first logo by default
	if buttons.size() > 0:
		select_logo(0)

# Set preview TextureRect for logo display
func set_preview_rect(rect: TextureRect) -> void:
	preview_texture_rect = rect

# Select a logo by index
func select_logo(logo_index: int) -> void:
	if logo_index < 0 or logo_index >= LOGO_COUNT:
		push_error("Invalid logo index: " + str(logo_index))
		return

	# Update selection state
	selected_logo_index = logo_index

	# Update button states
	for i in range(logo_buttons.size()):
		logo_buttons[i].button_pressed = (i == logo_index)

	# Update preview
	_update_preview()

	# Emit signals
	logo_selected.emit(logo_index, get_logo_info(logo_index))

# Get currently selected logo index
func get_selected_logo_index() -> int:
	return selected_logo_index

# Get logo information
func get_logo_info(logo_index: int) -> Dictionary:
	if logo_index >= 0 and logo_index < LOGO_INFO.size():
		return LOGO_INFO[logo_index]
	return {}

# Get all logo information
func get_all_logo_info() -> Array[Dictionary]:
	return LOGO_INFO.duplicate()

# Get logo texture by index
func get_logo_texture(logo_index: int) -> Texture2D:
	if logo_index >= 0 and logo_index < logo_textures.size():
		return logo_textures[logo_index]
	return null

# Get logo file path
func get_logo_path(logo_index: int) -> String:
	var logo_info: Dictionary = get_logo_info(logo_index)
	if logo_info.has("filename"):
		return LOGO_BASE_PATH + logo_info.filename
	return ""

# Get logos by style category
func get_logos_by_style(style: String) -> Array[int]:
	var matching_logos: Array[int] = []

	for i in range(LOGO_INFO.size()):
		var logo_info: Dictionary = LOGO_INFO[i]
		if logo_info.get("style", "") == style:
			matching_logos.append(i)

	return matching_logos

# Validate logo selection
func validate_logo_selection() -> bool:
	return selected_logo_index >= 0 and selected_logo_index < LOGO_COUNT

# Create colored logo texture for party branding
func create_branded_logo(logo_index: int, party_color: Color) -> ImageTexture:
	var base_texture: Texture2D = get_logo_texture(logo_index)

	if not base_texture:
		push_warning("No texture available for logo index: " + str(logo_index))
		return null

	# Get base image
	var base_image: Image = base_texture.get_image()
	if not base_image:
		return null

	# Create new image with party color
	var branded_image: Image = base_image.duplicate()
	branded_image.convert(Image.FORMAT_RGBA8)

	# Apply color tint (simple implementation)
	for x in range(branded_image.get_width()):
		for y in range(branded_image.get_height()):
			var pixel: Color = branded_image.get_pixel(x, y)
			if pixel.a > 0:  # Only modify non-transparent pixels
				# Blend with party color while preserving shape
				var tinted: Color = pixel * party_color
				tinted.a = pixel.a
				branded_image.set_pixel(x, y, tinted)

	# Create texture from modified image
	var branded_texture: ImageTexture = ImageTexture.new()
	branded_texture.set_image(branded_image)

	return branded_texture

# Get recommended logo for political style
func get_recommended_logo_for_party(party_data: PartyData) -> int:
	if not party_data:
		return 0

	var party_name: String = party_data.party_name.to_lower()
	var slogan: String = party_data.slogan.to_lower()

	# Simple keyword matching for recommendations
	if "green" in party_name or "environment" in slogan:
		return 2  # Tree logo
	elif "security" in party_name or "strong" in slogan:
		return 3  # Shield logo
	elif "unity" in party_name or "together" in slogan:
		return 4  # Circle logo
	elif "freedom" in party_name or "liberty" in slogan:
		return 1  # Eagle logo
	else:
		return 0  # Star logo (default)

# Create logo preview with party colors
func create_party_logo_preview(party_data: PartyData) -> Texture2D:
	if not party_data:
		return get_logo_texture(selected_logo_index)

	return create_branded_logo(selected_logo_index, party_data.primary_color)

# Export logo with party branding
func export_party_logo(party_data: PartyData, size: Vector2i = Vector2i(128, 128)) -> ImageTexture:
	var branded_logo: ImageTexture = create_branded_logo(selected_logo_index, party_data.primary_color)

	if not branded_logo:
		return null

	# Resize if needed
	if size != Vector2i(branded_logo.get_width(), branded_logo.get_height()):
		var image: Image = branded_logo.get_image()
		image.resize(size.x, size.y, Image.INTERPOLATE_LANCZOS)

		var resized_texture: ImageTexture = ImageTexture.new()
		resized_texture.set_image(image)
		return resized_texture

	return branded_logo

# Private Methods

func _load_logo_textures() -> void:
	logo_textures.clear()

	for i in range(LOGO_COUNT):
		var logo_path: String = get_logo_path(i)
		var texture: Texture2D = null

		if ResourceLoader.exists(logo_path):
			texture = load(logo_path)
			if texture:
				print("Loaded logo texture: ", logo_path)
			else:
				push_warning("Failed to load logo texture: " + logo_path)
		else:
			print("Logo texture not found: ", logo_path, " - will use placeholder")

		logo_textures.append(texture)

func _create_placeholder_texture(button: Button, logo_index: int) -> void:
	# Create a simple colored rectangle as placeholder
	var image: Image = Image.create(64, 64, false, Image.FORMAT_RGB8)
	image.fill(LOGO_PLACEHOLDER_COLOR)

	# Add simple pattern based on logo index
	var pattern_color: Color = Color.WHITE
	var center: Vector2i = Vector2i(32, 32)

	match logo_index:
		0:  # Star pattern
			for i in range(-8, 9):
				for j in range(-2, 3):
					if center.x + i >= 0 and center.x + i < 64:
						image.set_pixel(center.x + i, center.y + j, pattern_color)
					if center.y + i >= 0 and center.y + i < 64:
						image.set_pixel(center.x + j, center.y + i, pattern_color)
		1:  # Eagle pattern (triangle)
			for i in range(8):
				for j in range(-i, i + 1):
					if center.x + j >= 0 and center.x + j < 64 and center.y - i >= 0:
						image.set_pixel(center.x + j, center.y - i, pattern_color)
		2:  # Tree pattern (vertical line with branches)
			for i in range(-16, 17):
				if center.y + i >= 0 and center.y + i < 64:
					image.set_pixel(center.x, center.y + i, pattern_color)
					if abs(i) < 8:
						if center.x - 4 >= 0:
							image.set_pixel(center.x - 4, center.y + i, pattern_color)
						if center.x + 4 < 64:
							image.set_pixel(center.x + 4, center.y + i, pattern_color)
		3:  # Shield pattern
			for i in range(-12, 13):
				var width: int = max(0, 12 - abs(i))
				for j in range(-width, width + 1):
					if center.x + j >= 0 and center.x + j < 64 and center.y + i >= 0 and center.y + i < 64:
						image.set_pixel(center.x + j, center.y + i, pattern_color)
		4:  # Circle pattern
			for x in range(64):
				for y in range(64):
					var distance: float = Vector2(x - center.x, y - center.y).length()
					if distance >= 10 and distance <= 12:
						image.set_pixel(x, y, pattern_color)

	# Create texture from image
	var placeholder_texture: ImageTexture = ImageTexture.new()
	placeholder_texture.set_image(image)

	button.icon = placeholder_texture
	button.expand_icon = true

func _update_preview() -> void:
	if preview_texture_rect:
		var texture: Texture2D = get_logo_texture(selected_logo_index)
		if texture:
			preview_texture_rect.texture = texture
		else:
			# Use placeholder
			_create_placeholder_for_preview()

func _create_placeholder_for_preview() -> void:
	if not preview_texture_rect:
		return

	# Create larger placeholder for preview
	var image: Image = Image.create(128, 128, false, Image.FORMAT_RGB8)
	image.fill(LOGO_PLACEHOLDER_COLOR)

	var placeholder_texture: ImageTexture = ImageTexture.new()
	placeholder_texture.set_image(image)

	preview_texture_rect.texture = placeholder_texture

# Event Handlers

func _on_logo_button_pressed(logo_index: int) -> void:
	select_logo(logo_index)
	logo_previewed.emit(logo_index)