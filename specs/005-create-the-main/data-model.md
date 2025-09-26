# Data Model: Main Game Dashboard

## Core Game State

### GameState (Resource)
```gdscript
class_name GameState
extends Resource

@export var approval_rating: float = 50.0  # 0.0-100.0
@export var party_treasury: int = 100000    # Currency amount
@export var seats_in_parliament: int = 75   # Number of seats
@export var current_date: GameDate          # In-game date/time
@export var time_speed: TimeSpeed = TimeSpeed.NORMAL
@export var is_paused: bool = false
```

### GameDate (Resource)
```gdscript
class_name GameDate
extends Resource

@export var year: int = 2025
@export var month: int = 1      # 1-12
@export var day: int = 1        # 1-31
@export var hour: int = 9       # 0-23
@export var minute: int = 0     # 0-59

func advance_time(minutes: int) -> void
func to_display_string() -> String
func compare(other: GameDate) -> int
```

### TimeSpeed (Enum)
```gdscript
enum TimeSpeed {
    NORMAL = 1,    # 1x speed
    FAST = 2,      # 2x speed
    VERY_FAST = 4  # 4x speed
}
```

## Regional Campaign System

### RegionalData (Resource)
```gdscript
class_name RegionalData
extends Resource

@export var province_name: String          # e.g. "Noord-Holland"
@export var province_id: String            # e.g. "noord_holland"
@export var campaign_funding: int = 0      # Allocated funds
@export var selected_candidate: Candidate  # Campaign candidate
@export var campaign_strategy: Strategy    # Current strategy
@export var scheduled_rallies: Array[Rally] = []
@export var local_policies: Array[LocalPolicy] = []
@export var support_level: float = 50.0    # 0.0-100.0 regional support
```

### Candidate (Resource)
```gdscript
class_name Candidate
extends Resource

@export var name: String
@export var portrait: Texture2D
@export var political_alignment: PoliticalAlignment
@export var experience_level: int = 1  # 1-5 skill level
@export var specialties: Array[String] = []  # Policy areas
@export var popularity: float = 50.0   # Regional popularity
```

### Rally (Resource)
```gdscript
class_name Rally
extends Resource

@export var event_date: GameDate
@export var location: String
@export var expected_attendance: int
@export var cost: int
@export var approval_impact: float  # Expected impact
@export var status: RallyStatus = RallyStatus.SCHEDULED
```

## Parliamentary System

### ParliamentaryBill (Resource)
```gdscript
class_name ParliamentaryBill
extends Resource

@export var bill_id: String
@export var title: String
@export var full_text: String
@export var summary: String
@export var party_position: BillPosition = BillPosition.NEUTRAL
@export var predicted_consequences: Array[Consequence] = []
@export var public_opinion: float = 50.0    # 0-100 support
@export var coalition_stance: BillPosition = BillPosition.NEUTRAL
@export var voting_deadline: GameDate
@export var vote_cast: BillVote = BillVote.NOT_VOTED
@export var vote_result: BillResult = BillResult.PENDING
```

### BillPosition (Enum)
```gdscript
enum BillPosition {
    STRONGLY_OPPOSE = -2,
    OPPOSE = -1,
    NEUTRAL = 0,
    SUPPORT = 1,
    STRONGLY_SUPPORT = 2
}
```

### BillVote (Enum)
```gdscript
enum BillVote {
    NOT_VOTED,
    YES,
    NO,
    ABSTAIN
}
```

### Consequence (Resource)
```gdscript
class_name Consequence
extends Resource

@export var description: String
@export var impact_type: ImpactType
@export var magnitude: float      # -100 to +100
@export var affected_stat: StatType
```

## Calendar and Events

### CalendarEvent (Resource)
```gdscript
class_name CalendarEvent
extends Resource

@export var event_id: String
@export var title: String
@export var description: String
@export var event_type: EventType
@export var scheduled_date: GameDate
@export var duration_hours: int = 1
@export var cost: int = 0
@export var requirements: Array[String] = []  # Prerequisites
@export var conflicts_with: Array[String] = [] # Conflicting events
@export var status: EventStatus = EventStatus.SCHEDULED
```

### EventType (Enum)
```gdscript
enum EventType {
    MEETING,      # Political meetings
    RALLY,        # Public rallies
    INTERVIEW,    # Media interviews
    TRAVEL        # Travel events
}
```

## News and Media System

### NewsItem (Resource)
```gdscript
class_name NewsItem
extends Resource

@export var news_id: String
@export var headline: String
@export var content: String
@export var publication_date: GameDate
@export var urgency_level: UrgencyLevel = UrgencyLevel.NORMAL
@export var response_options: Array[ResponseOption] = []
@export var player_response: ResponseType = ResponseType.NO_RESPONSE
@export var consequences_applied: bool = false
```

### ResponseOption (Resource)
```gdscript
class_name ResponseOption
extends Resource

@export var response_type: ResponseType
@export var description: String
@export var cost: int = 0
@export var expected_outcomes: Array[Consequence] = []
```

### ResponseType (Enum)
```gdscript
enum ResponseType {
    NO_RESPONSE,           # Ignore
    PUBLIC_STATEMENT,      # Public statement
    PRIVATE_ACTION,        # Private action
    COALITION_CONSULTATION, # Coalition consultation
    EMERGENCY_LEGISLATION,  # Emergency legislation
    MEDIA_CAMPAIGN         # Media campaign
}
```

## Character Relationships

### Character (Resource)
```gdscript
class_name Character
extends Resource

@export var character_id: String
@export var name: String
@export var portrait: Texture2D
@export var title: String             # Political position
@export var political_party: String   # Party affiliation
@export var trust_level: float = 50.0 # 0-100 trust with player
@export var political_alignment: PoliticalAlignment
@export var recent_interactions: Array[Interaction] = []
```

### PoliticalAlignment (Enum)
```gdscript
enum PoliticalAlignment {
    FAR_LEFT = -2,
    LEFT = -1,
    CENTER = 0,
    RIGHT = 1,
    FAR_RIGHT = 2
}
```

### Interaction (Resource)
```gdscript
class_name Interaction
extends Resource

@export var interaction_date: GameDate
@export var interaction_type: String
@export var trust_impact: float  # Change in trust level
@export var description: String
```

## Data Relationships

### Primary Relationships
- **GameState** → contains all core dashboard stats
- **GameState** → owns collection of **RegionalData** (12 provinces)
- **GameState** → manages active **ParliamentaryBill** list
- **GameState** → tracks scheduled **CalendarEvent** items
- **GameState** → maintains **Character** relationship network

### Event Dependencies
- **Rally** events must reference **RegionalData**
- **ParliamentaryBill** voting affects **GameState** stats
- **NewsItem** responses can trigger **CalendarEvent** creation
- **Character** trust levels influence **ParliamentaryBill** outcomes

### Validation Rules
- **approval_rating**: 0.0 ≤ value ≤ 100.0
- **party_treasury**: value ≥ 0 (can go negative with consequences)
- **seats_in_parliament**: 0 ≤ value ≤ 150 (total Dutch parliament)
- **GameDate**: Valid calendar dates only
- **Event scheduling**: No double-booking of same time slots
- **Bill voting**: Must occur before deadline

### State Transitions
- **Events**: Scheduled → In Progress → Completed
- **Bills**: Introduced → Voting → Result Applied
- **News**: Published → Player Response → Consequences Applied
- **Time**: Always advancing unless paused