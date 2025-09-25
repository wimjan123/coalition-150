# SaveMigration - Handles migration of legacy save files to preset system
# Provides backward compatibility for existing characters with free-text backstories

class_name SaveMigration
extends RefCounted

# Migration strategies for matching legacy backstories to presets
enum MigrationStrategy {
	KEYWORD_MATCHING,    # Match based on keywords in backstory text
	MANUAL_SELECTION,    # Allow user to select preset manually
	DEFAULT_FALLBACK     # Use default preset for all legacy characters
}

# Static migration utility methods

static func migrate_legacy_character(character: CharacterData, presets: CharacterBackgroundPresets, strategy: MigrationStrategy = MigrationStrategy.KEYWORD_MATCHING) -> bool:
	"""Migrate a legacy character to use preset system"""
	if not character.is_legacy_character():
		print("Character already uses preset system: ", character.character_name)
		return true

	if not presets:
		push_error("Cannot migrate without preset collection")
		return false

	var selected_preset_id: String = ""

	match strategy:
		MigrationStrategy.KEYWORD_MATCHING:
			selected_preset_id = _find_best_matching_preset(character.backstory, presets)
		MigrationStrategy.DEFAULT_FALLBACK:
			var fallback_preset = presets.get_fallback_preset()
			selected_preset_id = fallback_preset.id if fallback_preset else ""
		MigrationStrategy.MANUAL_SELECTION:
			# Manual selection would require UI interaction - not implemented here
			selected_preset_id = _find_best_matching_preset(character.backstory, presets)

	if not selected_preset_id.is_empty():
		character.migrate_from_legacy_backstory(selected_preset_id)
		print("✓ Migrated character '", character.character_name, "' to preset: ", selected_preset_id)
		return true
	else:
		push_warning("Failed to find suitable preset for character: " + character.character_name)
		return false

static func _find_best_matching_preset(backstory_text: String, presets: CharacterBackgroundPresets) -> String:
	"""Find the best matching preset based on keyword analysis"""
	if backstory_text.is_empty() or not presets:
		return ""

	var backstory_lower = backstory_text.to_lower()
	var best_match_id: String = ""
	var highest_score: int = 0

	# Define keyword mappings for each archetype
	var keyword_mappings = {
		"Grassroots Organizer": ["student", "activist", "protest", "organizing", "campaign", "grassroots", "youth"],
		"Career Politician": ["council", "councillor", "mayor", "politician", "office", "elected", "government"],
		"Labor Advocate": ["union", "teacher", "worker", "labor", "strike", "negotiate", "collective"],
		"Pragmatic Entrepreneur": ["business", "entrepreneur", "company", "startup", "owner", "economic"],
		"Legal Expert": ["lawyer", "attorney", "legal", "law", "court", "justice", "litigation"],
		"Digital Innovator": ["tech", "technology", "digital", "innovation", "software", "fintech", "startup"],
		"International Expert": ["diplomat", "ambassador", "international", "foreign", "trade", "global"],
		"Celebrity Outsider": ["famous", "celebrity", "tv", "media", "recognition", "popular"],
		"Military Leader": ["military", "general", "army", "defense", "security", "nato", "peacekeeping"],
		"Digital Native": ["social media", "influencer", "tiktok", "viral", "online", "philosophy"]
	}

	# Check each preset against the backstory
	for preset in presets.preset_options:
		var score = 0
		var archetype = preset.character_archetype

		# Get keywords for this archetype
		var keywords = keyword_mappings.get(archetype, [])

		# Count matching keywords
		for keyword in keywords:
			if backstory_lower.contains(keyword.to_lower()):
				score += 1

		# Bonus points for exact archetype mentions
		if backstory_lower.contains(archetype.to_lower()):
			score += 3

		# Bonus for political alignment matches
		if backstory_lower.contains(preset.political_alignment.to_lower()):
			score += 1

		# Track best match
		if score > highest_score:
			highest_score = score
			best_match_id = preset.id

	# If no good matches found, return fallback preset
	if highest_score < 2:  # Require at least 2 keyword matches
		var fallback = presets.get_fallback_preset()
		return fallback.id if fallback else ""

	return best_match_id

static func migrate_all_legacy_characters(save_system: SaveSystem, presets: CharacterBackgroundPresets, strategy: MigrationStrategy = MigrationStrategy.KEYWORD_MATCHING) -> Dictionary:
	"""Migrate all legacy characters in the save system"""
	var migration_results = {
		"total_characters": 0,
		"legacy_characters": 0,
		"successful_migrations": 0,
		"failed_migrations": 0,
		"migrated_character_names": [],
		"failed_character_names": []
	}

	if not save_system or not presets:
		push_error("Cannot migrate without save system and presets")
		return migration_results

	# Get characters needing migration
	var legacy_characters = save_system.get_characters_needing_migration()
	migration_results["legacy_characters"] = legacy_characters.size()

	print("Found ", legacy_characters.size(), " legacy characters needing migration")

	# Migrate each legacy character
	for character in legacy_characters:
		if migrate_legacy_character(character, presets, strategy):
			migration_results["successful_migrations"] += 1
			migration_results["migrated_character_names"].append(character.character_name)

			# Save the migrated character
			save_system.save_character_with_preset(character)
		else:
			migration_results["failed_migrations"] += 1
			migration_results["failed_character_names"].append(character.character_name)

	# Get total character count
	var player_data = save_system.load_player_data()
	migration_results["total_characters"] = player_data.characters.size()

	print("Migration complete: ", migration_results["successful_migrations"], " successful, ", migration_results["failed_migrations"], " failed")

	return migration_results

static func validate_migration_results(save_system: SaveSystem, presets: CharacterBackgroundPresets) -> bool:
	"""Validate that migration was successful"""
	var legacy_characters = save_system.get_characters_needing_migration()

	if legacy_characters.size() == 0:
		print("✓ Migration validation passed: No legacy characters remaining")
		return true
	else:
		push_warning("Migration validation failed: ", legacy_characters.size(), " legacy characters still exist")
		for character in legacy_characters:
			push_warning("  - ", character.character_name, " still has legacy backstory")
		return false

static func generate_migration_report(migration_results: Dictionary) -> String:
	"""Generate a human-readable migration report"""
	var report = "=== SAVE FILE MIGRATION REPORT ===\n\n"

	report += "Total Characters: %d\n" % migration_results["total_characters"]
	report += "Legacy Characters Found: %d\n" % migration_results["legacy_characters"]
	report += "Successful Migrations: %d\n" % migration_results["successful_migrations"]
	report += "Failed Migrations: %d\n\n" % migration_results["failed_migrations"]

	if migration_results["migrated_character_names"].size() > 0:
		report += "Successfully Migrated:\n"
		for name in migration_results["migrated_character_names"]:
			report += "  ✓ %s\n" % name
		report += "\n"

	if migration_results["failed_character_names"].size() > 0:
		report += "Failed to Migrate:\n"
		for name in migration_results["failed_character_names"]:
			report += "  ✗ %s\n" % name
		report += "\n"

	var success_rate = 0.0
	if migration_results["legacy_characters"] > 0:
		success_rate = float(migration_results["successful_migrations"]) / float(migration_results["legacy_characters"]) * 100.0

	report += "Success Rate: %.1f%%\n" % success_rate
	report += "\n=== END REPORT ==="

	return report

## Testing and debugging utilities

static func test_keyword_matching(test_backstory: String, presets: CharacterBackgroundPresets) -> Dictionary:
	"""Test the keyword matching algorithm with a given backstory"""
	var result = {
		"backstory": test_backstory,
		"best_match_id": "",
		"best_match_name": "",
		"match_score": 0,
		"all_scores": {}
	}

	if not presets:
		return result

	# Get best match
	result["best_match_id"] = _find_best_matching_preset(test_backstory, presets)

	if not result["best_match_id"].is_empty():
		var best_preset = presets.get_preset_by_id(result["best_match_id"])
		if best_preset:
			result["best_match_name"] = best_preset.display_name

	return result

static func create_test_legacy_character(name: String, backstory: String) -> CharacterData:
	"""Create a test legacy character for migration testing"""
	var character = CharacterData.new()
	character.character_name = name
	character.political_experience = "Test Experience"
	character.backstory = backstory
	# Don't set selected_background_preset_id - this makes it legacy

	return character