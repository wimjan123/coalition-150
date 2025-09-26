# Quick script to recreate the preset resource file with proper class references
# Run this in Godot's script editor to fix the resource loading

@tool
extends EditorScript

func _run():
	print("🔄 Recreating preset resource file...")

	# Create the collection
	var presets = CharacterBackgroundPresets.new()
	presets.version = "1.0.0"

	# Create all 10 presets with proper data
	var preset_list: Array[PresetOption] = []

	# 1. Student Activist (Easy)
	var p1 = PresetOption.new()
	p1.id = "student_activist"
	p1.display_name = "Student Activist"
	p1.background_text = "A passionate university student who organized climate protests and student union campaigns. New to formal politics but brings fresh energy and grassroots organizing experience."
	p1.character_archetype = "Grassroots Organizer"
	p1.difficulty_rating = 1
	p1.difficulty_label = "Very Easy"
	p1.gameplay_impact = "High social media reach, strong youth support, limited political connections"
	p1.political_alignment = "Progressive"
	p1.is_satirical = false
	preset_list.append(p1)

	# 2. Reality TV Personality (Easy, Satirical)
	var p2 = PresetOption.new()
	p2.id = "reality_tv_personality"
	p2.display_name = "Reality TV Personality"
	p2.background_text = "Became famous on a popular reality show about Dutch entrepreneurs. Has name recognition and social media following but zero political experience. Critics question their seriousness."
	p2.character_archetype = "Celebrity Outsider"
	p2.difficulty_rating = 2
	p2.difficulty_label = "Easy"
	p2.gameplay_impact = "High name recognition, social media savvy, credibility challenges with serious voters"
	p2.political_alignment = "Populist"
	p2.is_satirical = true
	preset_list.append(p2)

	# 3. Local Councillor (Easy)
	var p3 = PresetOption.new()
	p3.id = "local_councillor"
	p3.display_name = "Local Councillor"
	p3.background_text = "Served three terms on the municipal council, focusing on housing policy and local business development. Knows the political process but lacks national recognition."
	p3.character_archetype = "Career Politician"
	p3.difficulty_rating = 3
	p3.difficulty_label = "Easy"
	p3.gameplay_impact = "Solid political foundations, established networks, moderate public recognition"
	p3.political_alignment = "Centrist"
	p3.is_satirical = false
	preset_list.append(p3)

	# 4. Union Leader (Medium)
	var p4 = PresetOption.new()
	p4.id = "union_leader"
	p4.display_name = "Union Leader"
	p4.background_text = "Led the national teachers' union through major contract negotiations and strikes. Strong connections to working-class voters but viewed with suspicion by business leaders."
	p4.character_archetype = "Labor Advocate"
	p4.difficulty_rating = 4
	p4.difficulty_label = "Medium"
	p4.gameplay_impact = "Strong labor support, experienced negotiator, challenges with business community"
	p4.political_alignment = "Progressive"
	p4.is_satirical = false
	preset_list.append(p4)

	# 5. Small Business Owner (Medium)
	var p5 = PresetOption.new()
	p5.id = "small_business_owner"
	p5.display_name = "Small Business Owner"
	p5.background_text = "Built a successful chain of local cafes from nothing. Understands economic challenges facing entrepreneurs and supports business-friendly policies while maintaining social responsibility."
	p5.character_archetype = "Pragmatic Entrepreneur"
	p5.difficulty_rating = 5
	p5.difficulty_label = "Medium"
	p5.gameplay_impact = "Business community support, economic credibility, must balance worker and owner interests"
	p5.political_alignment = "Conservative"
	p5.is_satirical = false
	preset_list.append(p5)

	# 6. Environmental Lawyer (Medium)
	var p6 = PresetOption.new()
	p6.id = "environmental_lawyer"
	p6.display_name = "Environmental Lawyer"
	p6.background_text = "Specialized in environmental law for 15 years, successfully sued major corporations for pollution violations. Brings legal expertise and green credentials to political arena."
	p6.character_archetype = "Legal Expert"
	p6.difficulty_rating = 6
	p6.difficulty_label = "Medium"
	p6.gameplay_impact = "Environmental movement support, legal knowledge, opposition from industrial interests"
	p6.political_alignment = "Progressive"
	p6.is_satirical = false
	preset_list.append(p6)

	# 7. Tech Entrepreneur (Hard)
	var p7 = PresetOption.new()
	p7.id = "tech_entrepreneur"
	p7.display_name = "Tech Entrepreneur"
	p7.background_text = "Founded a successful fintech startup and sold it for millions. Advocates for digital innovation in government and liberal social policies combined with free-market economics."
	p7.character_archetype = "Digital Innovator"
	p7.difficulty_rating = 7
	p7.difficulty_label = "Hard"
	p7.gameplay_impact = "Tech sector support, innovation platform, scrutiny over wealth and business practices"
	p7.political_alignment = "Libertarian"
	p7.is_satirical = false
	preset_list.append(p7)

	# 8. Former Diplomat (Hard)
	var p8 = PresetOption.new()
	p8.id = "former_diplomat"
	p8.display_name = "Former Diplomat"
	p8.background_text = "Served as ambassador to Germany and led international trade negotiations. Brings foreign policy expertise and international connections but limited domestic political experience."
	p8.character_archetype = "International Expert"
	p8.difficulty_rating = 8
	p8.difficulty_label = "Hard"
	p8.gameplay_impact = "Foreign policy expertise, international credibility, must establish domestic base"
	p8.political_alignment = "Centrist"
	p8.is_satirical = false
	preset_list.append(p8)

	# 9. Retired General (Very Hard)
	var p9 = PresetOption.new()
	p9.id = "retired_general"
	p9.display_name = "Retired General"
	p9.background_text = "Distinguished military career including NATO peacekeeping missions. Advocates for strong defense, law and order, and traditional values. Popular with older voters and security-minded citizens."
	p9.character_archetype = "Military Leader"
	p9.difficulty_rating = 9
	p9.difficulty_label = "Very Hard"
	p9.gameplay_impact = "Security credentials, discipline, must navigate civilian politics and diverse coalitions"
	p9.political_alignment = "Conservative"
	p9.is_satirical = false
	preset_list.append(p9)

	# 10. Social Media Philosopher (Expert, Satirical)
	var p10 = PresetOption.new()
	p10.id = "influencer_philosopher"
	p10.display_name = "Social Media Philosopher"
	p10.background_text = "Gained millions of followers by explaining complex political theories through viral TikTok videos. Young voters love their accessible approach to philosophy, but traditional politicians dismiss them as a joke."
	p10.character_archetype = "Digital Native"
	p10.difficulty_rating = 10
	p10.difficulty_label = "Expert"
	p10.gameplay_impact = "Massive youth following, unconventional methods, establishment resistance and media skepticism"
	p10.political_alignment = "Populist"
	p10.is_satirical = true
	preset_list.append(p10)

	# Assign the preset list to the collection
	presets.preset_options = preset_list

	# Save the resource
	var save_path = "res://assets/data/CharacterBackgroundPresets.tres"
	var error = ResourceSaver.save(presets, save_path)

	if error == OK:
		print("✅ Successfully recreated preset resource!")
		print("✅ Created ", preset_list.size(), " presets")
		print("✅ 2 satirical presets included (🎭)")
		print("✅ Political balance: Progressive(3), Conservative(2), Centrist(2), Libertarian(1), Populist(2)")

		# Reload the scene to test
		EditorInterface.reload_scene_from_path("res://scenes/player/CharacterPartyCreation.tscn")
	else:
		print("❌ Failed to save preset resource: ", error)

	print("🎯 Try running the character creation again - you should see all 10 presets!")