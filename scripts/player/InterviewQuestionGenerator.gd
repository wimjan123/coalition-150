# InterviewQuestionGenerator - Advanced question generation for media interviews
# Generates dynamic, contextual questions based on character profiles and political positions

class_name InterviewQuestionGenerator
extends RefCounted

# Question Templates by Category
const EXPERIENCE_TEMPLATES: Array[Dictionary] = [
	{
		"template": "How has your {years} years of experience as a {role} prepared you for this campaign?",
		"difficulty": "easy",
		"political_lean": "neutral"
	},
	{
		"template": "Critics say your background as a {role} doesn't qualify you for political leadership. How do you respond?",
		"difficulty": "hard",
		"political_lean": "challenging"
	},
	{
		"template": "What was your biggest failure as a {role}, and what did you learn from it?",
		"difficulty": "medium",
		"political_lean": "probing"
	}
]

const POLICY_TEMPLATES: Array[Dictionary] = [
	{
		"template": "Your party supports {policy_position} on {policy_area}. Can you explain why this approach is best for voters?",
		"difficulty": "medium",
		"political_lean": "supportive"
	},
	{
		"template": "Polls show {percentage}% of voters oppose your stance on {policy_area}. Will you reconsider your position?",
		"difficulty": "hard",
		"political_lean": "challenging"
	},
	{
		"template": "How would you implement your {policy_area} policy if faced with budget constraints?",
		"difficulty": "medium",
		"political_lean": "practical"
	}
]

const LEADERSHIP_TEMPLATES: Array[Dictionary] = [
	{
		"template": "Describe a time when you had to make a difficult decision that wasn't popular. How did you handle it?",
		"difficulty": "medium",
		"political_lean": "neutral"
	},
	{
		"template": "Your opponents claim you lack the experience to lead effectively. What evidence can you provide to counter this?",
		"difficulty": "hard",
		"political_lean": "challenging"
	},
	{
		"template": "What leadership qualities do you think are most important in today's political climate?",
		"difficulty": "easy",
		"political_lean": "softball"
	}
]

const VISION_TEMPLATES: Array[Dictionary] = [
	{
		"template": "In 4 years, what would success look like for a {party_name} administration?",
		"difficulty": "medium",
		"political_lean": "neutral"
	},
	{
		"template": "How do you plan to work with opposition parties to achieve your vision for {focus_area}?",
		"difficulty": "medium",
		"political_lean": "collaborative"
	},
	{
		"template": "Some voters feel your vision is too {vision_critique}. How do you address these concerns?",
		"difficulty": "hard",
		"political_lean": "challenging"
	}
]

# Answer Templates by Political Alignment
const CONSERVATIVE_ANSWERS: Array[String] = [
	"We need to return to proven traditional values and fiscal responsibility.",
	"Strong leadership and clear principles are what voters are looking for.",
	"Market-based solutions with minimal government intervention work best.",
	"We must protect our community's core values while promoting opportunity."
]

const PROGRESSIVE_ANSWERS: Array[String] = [
	"Bold, transformative change is needed to address systemic challenges.",
	"We must invest in people and communities for long-term prosperity.",
	"Government has a responsibility to ensure equality and justice for all.",
	"Evidence-based policy and inclusive decision-making will guide our approach."
]

const MODERATE_ANSWERS: Array[String] = [
	"A balanced approach that considers all stakeholders is most effective.",
	"We need pragmatic solutions that bring people together, not divide them.",
	"Finding common ground while addressing real concerns is my priority.",
	"Thoughtful, measured progress serves our community's interests best."
]

const POPULIST_ANSWERS: Array[String] = [
	"The people deserve a voice in decisions that affect their daily lives.",
	"I'm fighting for working families who've been ignored by the establishment.",
	"It's time to put ordinary citizens ahead of special interests.",
	"Real change comes from listening to what the community actually needs."
]

# Question Generation Settings
var question_difficulty: String = "mixed"  # easy, medium, hard, mixed
var political_bias: String = "balanced"    # friendly, balanced, challenging
var question_count: int = 5
var include_followup: bool = true

func _init() -> void:
	# Initialize random seed for varied questions
	randomize()

# Main Generation Function
func generate_interview_questions(character: CharacterData, settings: Dictionary = {}) -> Array[Dictionary]:
	if not character:
		push_error("Cannot generate questions for null character")
		return []

	# Apply custom settings
	_apply_settings(settings)

	# Get character profile for contextual generation
	var profile: Dictionary = character.get_political_profile()

	var questions: Array[Dictionary] = []

	# Generate core question set
	questions.append(_generate_opening_question(character))
	questions.append(_generate_experience_question(character, profile))
	questions.append(_generate_policy_question(character, profile))
	questions.append(_generate_leadership_question(character, profile))
	questions.append(_generate_vision_question(character, profile))

	# Add additional questions if requested
	if question_count > 5:
		var additional_questions: int = question_count - 5
		for i in additional_questions:
			questions.append(_generate_contextual_question(character, profile, i))

	# Add follow-up questions if enabled
	if include_followup:
		_add_followup_questions(questions, character, profile)

	return questions

# Specialized Question Generators
func _generate_opening_question(character: CharacterData) -> Dictionary:
	var opening_templates: Array[String] = [
		"Thank you for joining us today. Can you tell our viewers why you decided to run for office?",
		"Welcome to the program. What message do you have for voters who are just getting to know you?",
		"Good evening. In your own words, what makes you the right choice for leadership?"
	]

	var template: String = opening_templates[randi() % opening_templates.size()]

	return {
		"question_id": "opening_001",
		"text": template,
		"category": "opening",
		"difficulty": "easy",
		"answers": _get_answers_for_alignment(character.get_political_alignment()),
		"context": {"type": "opening", "character_name": character.character_name}
	}

func _generate_experience_question(character: CharacterData, profile: Dictionary) -> Dictionary:
	var template: Dictionary = EXPERIENCE_TEMPLATES[randi() % EXPERIENCE_TEMPLATES.size()]
	var experience: String = profile.get("experience", "community member")
	var years: String = str(randi_range(2, 15))

	# Apply difficulty filter if not mixed
	if question_difficulty != "mixed":
		template = _get_template_by_difficulty(EXPERIENCE_TEMPLATES, question_difficulty)

	var question_text: String = template.template.format({
		"role": experience,
		"years": years
	})

	return {
		"question_id": "exp_" + str(randi_range(100, 999)),
		"text": question_text,
		"category": "experience",
		"difficulty": template.difficulty,
		"answers": _get_contextual_answers(character, "experience"),
		"context": {"experience": experience, "years": years}
	}

func _generate_policy_question(character: CharacterData, profile: Dictionary) -> Dictionary:
	var template: Dictionary = POLICY_TEMPLATES[randi() % POLICY_TEMPLATES.size()]
	var policies: Dictionary = profile.get("policies", {})

	# Choose a policy area the character has a position on
	var policy_areas: Array = ["healthcare", "education", "economy", "environment", "security"]
	var chosen_area: String = policy_areas[randi() % policy_areas.size()]

	var policy_position: String = "moderate reform"
	if policies.has(chosen_area):
		policy_position = policies[chosen_area]

	var question_text: String = template.template.format({
		"policy_area": chosen_area,
		"policy_position": policy_position,
		"percentage": str(randi_range(35, 65))
	})

	return {
		"question_id": "pol_" + str(randi_range(100, 999)),
		"text": question_text,
		"category": "policy",
		"difficulty": template.difficulty,
		"answers": _get_policy_answers(chosen_area, character.get_political_alignment()),
		"context": {"policy_area": chosen_area, "position": policy_position}
	}

func _generate_leadership_question(character: CharacterData, profile: Dictionary) -> Dictionary:
	var template: Dictionary = LEADERSHIP_TEMPLATES[randi() % LEADERSHIP_TEMPLATES.size()]

	var question_text: String = template.template

	return {
		"question_id": "lead_" + str(randi_range(100, 999)),
		"text": question_text,
		"category": "leadership",
		"difficulty": template.difficulty,
		"answers": _get_leadership_answers(character.get_political_alignment()),
		"context": {"leadership_style": profile.get("leadership_style", "collaborative")}
	}

func _generate_vision_question(character: CharacterData, profile: Dictionary) -> Dictionary:
	var template: Dictionary = VISION_TEMPLATES[randi() % VISION_TEMPLATES.size()]
	var party_name: String = profile.get("party_name", "our party")

	var vision_critiques: Array[String] = ["ambitious", "unrealistic", "expensive", "radical", "conservative"]
	var critique: String = vision_critiques[randi() % vision_critiques.size()]

	var question_text: String = template.template.format({
		"party_name": party_name,
		"focus_area": "the community",
		"vision_critique": critique
	})

	return {
		"question_id": "vis_" + str(randi_range(100, 999)),
		"text": question_text,
		"category": "vision",
		"difficulty": template.difficulty,
		"answers": _get_vision_answers(character.get_political_alignment()),
		"context": {"party_name": party_name, "critique": critique}
	}

func _generate_contextual_question(character: CharacterData, profile: Dictionary, index: int) -> Dictionary:
	# Generate additional questions based on character specifics
	var categories: Array[String] = ["controversy", "background", "opponents", "endorsements"]
	var category: String = categories[index % categories.size()]

	match category:
		"controversy":
			return _generate_controversy_question(character, profile)
		"background":
			return _generate_background_question(character, profile)
		"opponents":
			return _generate_opponent_question(character, profile)
		"endorsements":
			return _generate_endorsement_question(character, profile)
		_:
			return _generate_generic_question(character, profile)

# Answer Generation Functions
func _get_answers_for_alignment(alignment: String) -> Array[String]:
	match alignment.to_lower():
		"conservative":
			return CONSERVATIVE_ANSWERS
		"progressive":
			return PROGRESSIVE_ANSWERS
		"moderate", "centrist":
			return MODERATE_ANSWERS
		"populist":
			return POPULIST_ANSWERS
		_:
			return MODERATE_ANSWERS

func _get_contextual_answers(character: CharacterData, context: String) -> Array[String]:
	var base_answers: Array[String] = _get_answers_for_alignment(character.get_political_alignment())

	# Add context-specific variations
	var contextual_answers: Array[String] = base_answers.duplicate()

	match context:
		"experience":
			contextual_answers.append("My diverse background gives me a unique perspective on the challenges we face.")
		"policy":
			contextual_answers.append("I believe in evidence-based policy that puts people first.")
		"leadership":
			contextual_answers.append("True leadership means making tough decisions and standing by your principles.")
		"vision":
			contextual_answers.append("My vision is about creating opportunities for everyone in our community.")

	return contextual_answers

func _get_policy_answers(policy_area: String, alignment: String) -> Array[String]:
	var base_answers: Array[String] = _get_answers_for_alignment(alignment)
	var policy_specific: Array[String] = []

	match policy_area:
		"healthcare":
			policy_specific = [
				"Healthcare is a fundamental right that everyone deserves access to.",
				"We need market-based healthcare solutions that reduce costs and improve quality.",
				"A hybrid approach combining public and private healthcare serves everyone best.",
				"Preventive care and community health initiatives should be our priority."
			]
		"education":
			policy_specific = [
				"Every child deserves a quality education regardless of their zip code.",
				"School choice and competition will drive educational excellence.",
				"We need to support both public schools and educational innovation.",
				"Teacher training and curriculum modernization are key to student success."
			]
		"economy":
			policy_specific = [
				"Economic growth must benefit working families, not just the wealthy.",
				"Lower taxes and reduced regulations will stimulate job creation.",
				"A balanced approach to economic policy supports both businesses and workers.",
				"Investing in infrastructure and innovation drives long-term prosperity."
			]
		"environment":
			policy_specific = [
				"Environmental protection and economic growth can go hand in hand.",
				"Market incentives are the most effective way to address environmental challenges.",
				"We need comprehensive environmental policies that consider all stakeholders.",
				"Sustainable development practices will secure our future for generations to come."
			]

	# Combine base political answers with policy-specific ones
	var combined: Array[String] = []
	combined.append_array(policy_specific)

	# Add a couple base alignment answers for variety
	combined.append(base_answers[0])
	combined.append(base_answers[1])

	return combined

func _get_leadership_answers(alignment: String) -> Array[String]:
	return [
		"I believe in collaborative leadership that brings diverse voices to the table.",
		"Strong, decisive leadership is what our community needs in these challenging times.",
		"Principled leadership means doing what's right, even when it's difficult.",
		"Adaptive leadership that responds to changing circumstances serves people best.",
		"Authentic leadership starts with listening to the community and their concerns."
	]

func _get_vision_answers(alignment: String) -> Array[String]:
	return [
		"My vision is for a community where everyone has the opportunity to thrive and succeed.",
		"I envision sustainable economic growth that benefits all members of our society.",
		"A future built on innovation, inclusion, and shared prosperity is what we're working toward.",
		"Transparent, accountable governance that truly serves the people's interests is my goal.",
		"I see a community united by common purpose and strengthened by our diversity."
	]

# Utility Functions
func _apply_settings(settings: Dictionary) -> void:
	if settings.has("difficulty"):
		question_difficulty = settings.difficulty

	if settings.has("bias"):
		political_bias = settings.bias

	if settings.has("count"):
		question_count = settings.count

	if settings.has("followup"):
		include_followup = settings.followup

func _get_template_by_difficulty(templates: Array[Dictionary], difficulty: String) -> Dictionary:
	var filtered: Array[Dictionary] = []

	for template in templates:
		if template.difficulty == difficulty:
			filtered.append(template)

	if filtered.size() > 0:
		return filtered[randi() % filtered.size()]
	else:
		return templates[randi() % templates.size()]

func _add_followup_questions(questions: Array[Dictionary], character: CharacterData, profile: Dictionary) -> void:
	# Add follow-up questions based on answers (simplified for now)
	var followup: Dictionary = {
		"question_id": "followup_001",
		"text": "Can you elaborate on that point and provide a specific example?",
		"category": "followup",
		"difficulty": "medium",
		"answers": [
			"Absolutely. Let me give you a concrete example from my experience.",
			"That's a great question. Here's how I see this working in practice.",
			"I'm glad you asked. This is something I'm particularly passionate about.",
			"Let me be more specific about what this means for our community."
		],
		"context": {"type": "followup"}
	}

	questions.append(followup)

# Additional question generators for contextual questions
func _generate_controversy_question(character: CharacterData, profile: Dictionary) -> Dictionary:
	var controversy_questions: Array[String] = [
		"There's been some controversy about your position on recent events. How do you respond?",
		"Critics have raised questions about your past decisions. What's your response?",
		"Some voters are concerned about statements you made previously. Can you clarify your position?"
	]

	return {
		"question_id": "contr_" + str(randi_range(100, 999)),
		"text": controversy_questions[randi() % controversy_questions.size()],
		"category": "controversy",
		"difficulty": "hard",
		"answers": [
			"I stand by my principles, but I'm always willing to listen and learn.",
			"My record speaks for itself - I've consistently fought for what's right.",
			"Context matters, and I believe voters understand my true motivations.",
			"I admit when I'm wrong and work to do better. That's what leadership means."
		],
		"context": {"type": "controversy"}
	}

func _generate_background_question(character: CharacterData, profile: Dictionary) -> Dictionary:
	return {
		"question_id": "bg_" + str(randi_range(100, 999)),
		"text": "How has your personal background shaped your political worldview?",
		"category": "background",
		"difficulty": "medium",
		"answers": [
			"My experiences have taught me the importance of hard work and perseverance.",
			"Growing up in this community showed me both its strengths and challenges.",
			"My background gives me a unique perspective on the issues facing voters.",
			"I've learned that good policy comes from understanding real people's struggles."
		],
		"context": {"type": "background"}
	}

func _generate_opponent_question(character: CharacterData, profile: Dictionary) -> Dictionary:
	return {
		"question_id": "opp_" + str(randi_range(100, 999)),
		"text": "Your opponents claim you're not qualified for this position. How do you respond?",
		"category": "opponents",
		"difficulty": "hard",
		"answers": [
			"I let my record and vision speak for themselves, not political attacks.",
			"Voters can judge for themselves who's best prepared to serve their interests.",
			"I focus on solutions, not the political games my opponents are playing.",
			"My qualifications are proven by my commitment to this community."
		],
		"context": {"type": "opponents"}
	}

func _generate_endorsement_question(character: CharacterData, profile: Dictionary) -> Dictionary:
	return {
		"question_id": "end_" + str(randi_range(100, 999)),
		"text": "Which endorsements are you most proud of, and why do they matter to voters?",
		"category": "endorsements",
		"difficulty": "easy",
		"answers": [
			"I'm honored by support from community leaders who share my vision.",
			"The endorsements that matter most come from ordinary citizens and families.",
			"Support from diverse groups shows my ability to unite people around common goals.",
			"Every endorsement represents someone who believes in positive change."
		],
		"context": {"type": "endorsements"}
	}

func _generate_generic_question(character: CharacterData, profile: Dictionary) -> Dictionary:
	return {
		"question_id": "gen_" + str(randi_range(100, 999)),
		"text": "What would you say to voters who are still undecided about their choice?",
		"category": "generic",
		"difficulty": "medium",
		"answers": [
			"I encourage everyone to look at my record and vision for our future.",
			"Voting is about choosing who will fight hardest for your interests.",
			"I ask for your trust to work together on the challenges we face.",
			"The choice is between more of the same or real progress for our community."
		],
		"context": {"type": "generic"}
	}

# Public API for interview system
func get_question_difficulties() -> Array[String]:
	return ["easy", "medium", "hard", "mixed"]

func get_political_biases() -> Array[String]:
	return ["friendly", "balanced", "challenging"]

func get_question_categories() -> Array[String]:
	return ["opening", "experience", "policy", "leadership", "vision", "controversy", "background", "opponents", "endorsements", "followup", "generic"]

func set_difficulty(difficulty: String) -> void:
	if difficulty in get_question_difficulties():
		question_difficulty = difficulty

func set_bias(bias: String) -> void:
	if bias in get_political_biases():
		political_bias = bias

func set_question_count(count: int) -> void:
	question_count = max(1, min(count, 10))  # Between 1 and 10 questions

func enable_followup_questions(enabled: bool) -> void:
	include_followup = enabled