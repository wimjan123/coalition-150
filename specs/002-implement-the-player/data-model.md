# Data Model: Player and Party Creation Flow

## Entity Relationships

```
PlayerData (Resource)
├── characters: Array[CharacterData]
└── current_save_version: int

CharacterData (Resource)
├── character_name: String
├── political_experience: String
├── policy_positions: Dictionary
├── backstory: String
├── party: PartyData
└── interview_responses: Array[InterviewResponse]

PartyData (Resource)
├── party_name: String
├── slogan: String
├── primary_color: Color
├── logo_index: int (0-4 for 5 logo options)
└── creation_date: String

InterviewResponse (Resource)
├── question_id: String
├── question_text: String
├── selected_answer: String
└── answer_index: int
```

## Core Entities

### PlayerData
**Purpose**: Root save data container for the player's game state

**Properties**:
- `characters: Array[CharacterData]` - All created characters/parties
- `current_save_version: int` - For future save compatibility

**Validation Rules**:
- Characters array can be empty (new player)
- Save version must be positive integer
- Party names must be unique within characters array

**State Transitions**:
- NEW → HAS_CHARACTERS (when first character created)
- Persists across all game sessions

### CharacterData
**Purpose**: Complete political character profile with experience, positions, and backstory

**Properties**:
- `character_name: String` - Character's full name
- `political_experience: String` - Background description
- `policy_positions: Dictionary` - Key: policy area, Value: stance
- `backstory: String` - Character history narrative
- `party: PartyData` - Associated political party
- `interview_responses: Array[InterviewResponse]` - Media interview answers

**Validation Rules**:
- Character name must be non-empty, max 50 characters
- Political experience required, max 200 characters
- Policy positions must contain at least 3 key areas
- Backstory required, max 500 characters
- Party must be valid PartyData instance

**State Transitions**:
- CREATING → COMPLETE (all required fields filled)
- COMPLETE → IN_INTERVIEW (proceeding to media interview)
- IN_INTERVIEW → READY (interview completed)

### PartyData
**Purpose**: Political party identity with name, branding, and visual elements

**Properties**:
- `party_name: String` - Official party name
- `slogan: String` - Campaign slogan
- `primary_color: Color` - Party brand color (RGB)
- `logo_index: int` - Selected logo (0-4 range)
- `creation_date: String` - ISO date string

**Validation Rules**:
- Party name required, 3-100 characters, unique per player
- Slogan required, 10-100 characters max
- Primary color must be valid Color (alpha = 1.0)
- Logo index must be 0-4 (5 available options)
- Creation date auto-generated in ISO format

**State Transitions**:
- CREATING → COMPLETE (all fields validated)
- Immutable after creation (except for future editing features)

### InterviewResponse
**Purpose**: Individual media interview question and player's answer

**Properties**:
- `question_id: String` - Unique identifier for question template
- `question_text: String` - Complete question as asked
- `selected_answer: String` - Player's chosen response
- `answer_index: int` - Index of selected multiple choice answer

**Validation Rules**:
- Question ID must match available question templates
- Question text must be non-empty
- Selected answer must be non-empty
- Answer index must be valid for question's available options (0-3 typical)

**State Transitions**:
- PENDING → ANSWERED (player selects response)
- Immutable after selection

## Data Storage Strategy

### File Structure
```
user://save_data/
├── player_data.tres          # Main PlayerData resource
└── autosave/
    └── player_data_auto.tres  # Automatic backup
```

### Persistence Patterns
- **Save on completion**: Character creation and interview completion
- **Auto-save**: After each major step (character details, party creation)
- **Load validation**: Check resource integrity on load, fallback to defaults
- **Version management**: Handle save compatibility with version field

### Performance Considerations
- Resources lazy-load sub-resources automatically
- Use compressed saves for large backstory/interview data
- Cache PlayerData in memory during active session
- Async load for initial game startup

## Integration Points

### Scene Communication
- **Selection Scene**: Reads PlayerData.characters array
- **Creation Scene**: Creates/modifies CharacterData and PartyData
- **Interview Scene**: Appends InterviewResponse instances
- **SceneManager**: Handles save/load between transitions

### UI Data Binding
- Export variables in scene scripts reference data model
- Direct property binding where possible
- Signal emission on data changes for UI updates
- Form validation matches data model validation rules

This data model provides the foundation for type-safe, persistent player progression while maintaining flexibility for future feature expansion.