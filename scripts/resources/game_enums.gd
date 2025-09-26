# Game Enums
# All enum definitions for the coalition dashboard system

class_name GameEnums
extends RefCounted

# Time management enums
enum TimeSpeed {
	NORMAL = 1,    # 1x speed
	FAST = 2,      # 2x speed
	VERY_FAST = 4  # 4x speed
}

# Parliamentary system enums
enum BillPosition {
	STRONGLY_OPPOSE = -2,
	OPPOSE = -1,
	NEUTRAL = 0,
	SUPPORT = 1,
	STRONGLY_SUPPORT = 2
}

enum BillVote {
	NOT_VOTED,
	YES,
	NO,
	ABSTAIN
}

enum BillResult {
	PENDING,
	PASSED,
	FAILED,
	WITHDRAWN
}

# Calendar and events
enum EventType {
	MEETING,      # Political meetings
	RALLY,        # Public rallies
	INTERVIEW,    # Media interviews
	TRAVEL        # Travel events
}

enum EventStatus {
	SCHEDULED,
	IN_PROGRESS,
	COMPLETED,
	CANCELLED
}

enum RallyStatus {
	SCHEDULED,
	IN_PROGRESS,
	COMPLETED,
	CANCELLED
}

# News and media system
enum ResponseType {
	NO_RESPONSE,           # Ignore
	PUBLIC_STATEMENT,      # Public statement
	PRIVATE_ACTION,        # Private action
	COALITION_CONSULTATION, # Coalition consultation
	EMERGENCY_LEGISLATION,  # Emergency legislation
	MEDIA_CAMPAIGN         # Media campaign
}

enum UrgencyLevel {
	LOW,
	NORMAL,
	HIGH,
	CRITICAL
}

# Character system
enum PoliticalAlignment {
	FAR_LEFT = -2,
	LEFT = -1,
	CENTER = 0,
	RIGHT = 1,
	FAR_RIGHT = 2
}

# Impact and consequence system
enum ImpactType {
	APPROVAL_RATING,
	TREASURY,
	SEATS,
	SUPPORT_LEVEL,
	TRUST_LEVEL
}

enum StatType {
	APPROVAL_RATING,
	PARTY_TREASURY,
	SEATS_IN_PARLIAMENT,
	SUPPORT_LEVEL
}