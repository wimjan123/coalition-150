# PartyData - Political party data for campaign
# Stores party branding and identity information

class_name PartyData
extends Resource

# Party's official name
@export var party_name: String = ""

# Party campaign slogan
@export var slogan: String = ""

# Party's primary brand color
@export var primary_color: Color = Color.WHITE

# Logo index (0-4 for 5 logo options per spec)
@export var logo_index: int = 0

# Party creation date
@export var creation_date: String = ""

# Optional party description/platform
@export var description: String = ""

func _init(p_name: String = "", p_slogan: String = "", p_color: Color = Color.WHITE, p_logo: int = 0) -> void:
	party_name = p_name
	slogan = p_slogan
	primary_color = p_color
	logo_index = p_logo
	creation_date = Time.get_datetime_string_from_system()

# Set party name with validation
func set_party_name(name: String) -> bool:
	if name.is_empty():
		push_error("Party name cannot be empty")
		return false

	if name.length() > 50:  # Reasonable limit for party names
		push_error("Party name too long (max 50 characters)")
		return false

	party_name = name
	emit_changed()
	return true

# Set party slogan with validation
func set_slogan(new_slogan: String) -> bool:
	if new_slogan.length() > 100:  # Per spec suggestion: 50-100 characters
		push_error("Slogan too long (max 100 characters)")
		return false

	slogan = new_slogan
	emit_changed()
	return true

# Set primary color
func set_primary_color(color: Color) -> void:
	primary_color = color
	emit_changed()

# Set logo index with validation
func set_logo_index(index: int) -> bool:
	if index < 0 or index > 4:  # 0-4 for 5 options per spec
		push_error("Logo index must be between 0 and 4")
		return false

	logo_index = index
	emit_changed()
	return true

# Get logo path based on index
func get_logo_path() -> String:
	return "res://assets/logos/party_logo_" + str(logo_index) + ".png"

# Get color as hex string for display
func get_color_hex() -> String:
	return primary_color.to_html()

# Validate party data
func validate() -> bool:
	# Check required fields
	if party_name.is_empty():
		push_error("Party name is required")
		return false

	if slogan.is_empty():
		push_error("Party slogan is required")
		return false

	# Validate field lengths
	if party_name.length() > 50:
		push_error("Party name too long")
		return false

	if slogan.length() > 100:
		push_error("Slogan too long")
		return false

	# Validate logo index
	if logo_index < 0 or logo_index > 4:
		push_error("Invalid logo index: " + str(logo_index))
		return false

	# Validate color (ensure it's not completely transparent)
	if primary_color.a <= 0.0:
		push_error("Party color cannot be transparent")
		return false

	return true

# Get party display name for UI
func get_display_name() -> String:
	return party_name

# Get party summary for UI display
func get_display_summary() -> String:
	var summary: String = party_name
	if not slogan.is_empty():
		summary += " - \"" + slogan + "\""
	return summary

# Check if party data is complete
func is_complete() -> bool:
	return not party_name.is_empty() and not slogan.is_empty()

# Get party branding info for UI
func get_branding_info() -> Dictionary:
	return {
		"name": party_name,
		"slogan": slogan,
		"color": primary_color,
		"color_hex": get_color_hex(),
		"logo_index": logo_index,
		"logo_path": get_logo_path(),
		"creation_date": creation_date
	}

# Copy party data for editing without affecting original
func duplicate_party() -> PartyData:
	var copy: PartyData = PartyData.new(party_name, slogan, primary_color, logo_index)
	copy.creation_date = creation_date
	copy.description = description
	return copy