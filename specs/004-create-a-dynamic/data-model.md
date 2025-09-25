# Data Model: Dynamic and Branching Interview System

## Core Entities

### InterviewQuestion
**Purpose**: Represents a single interview question with its metadata and branching logic

**Fields**:
- `id: String` - Unique identifier for the question
- `text: String` - The question content displayed to player
- `tags: Array[String]` - Tags for matching against character/party presets
- `answers: Array[AnswerChoice]` - Available answer options
- `is_fallback: bool` - Whether this is a generic fallback question

**Validation Rules**:
- `id` must be unique across all questions
- `text` must not be empty
- `answers` array must contain 2-5 choices
- At least one fallback question must exist

**Relationships**:
- Contains multiple AnswerChoice entities
- Referenced by next_question_id in AnswerChoice

### AnswerChoice
**Purpose**: Represents a player's response option with associated effects and branching

**Fields**:
- `text: String` - The answer content displayed to player
- `effects: Dictionary` - Game state changes to apply (stats, flags, unlocks)
- `next_question_id: String` - ID of next question (optional)

**Validation Rules**:
- `text` must not be empty
- `next_question_id` must reference valid question if provided
- `effects` keys must be valid game state properties

**Relationships**:
- Belongs to one InterviewQuestion
- May reference another InterviewQuestion via next_question_id

### InterviewSession
**Purpose**: Tracks the current interview state and player progress

**Fields**:
- `current_question_id: String` - ID of currently displayed question
- `answer_history: Array[String]` - IDs of previously selected answers
- `questions_answered: int` - Count of questions completed
- `max_questions: int` - Maximum questions before auto-completion
- `player_preset_tags: Array[String]` - Tags from player's character/party presets

**State Transitions**:
- `STARTING` → `ACTIVE` (first question loaded)
- `ACTIVE` → `ACTIVE` (answering questions)
- `ACTIVE` → `COMPLETED` (max questions reached or no next question)

**Validation Rules**:
- `max_questions` must be positive integer
- `questions_answered` must not exceed `max_questions`
- `current_question_id` must reference valid question

### InterviewData
**Purpose**: Container for all interview content loaded from JSON

**Fields**:
- `questions: Dictionary` - Map of question_id to InterviewQuestion
- `fallback_questions: Array[String]` - IDs of generic fallback questions
- `version: String` - Data version for compatibility checking

**Validation Rules**:
- All question IDs in fallback_questions must exist in questions
- All next_question_id references must be valid
- No circular references in question chains
- At least one fallback question must exist

### GameEffects
**Purpose**: Represents modifications to game state from interview answers

**Fields**:
- `stats: Dictionary` - Stat changes (e.g., {"charisma": +1, "intelligence": -1})
- `flags: Dictionary` - Boolean flags (e.g., {"met_scholar": true})
- `unlocks: Array[String]` - Content unlocks (e.g., ["secret_path", "bonus_item"])

**Validation Rules**:
- Stat values must be integers
- Flag values must be booleans
- Unlock strings must reference valid game content

## JSON Schema

### interviews.json Structure
```json
{
  "version": "1.0.0",
  "questions": {
    "q001": {
      "text": "What drives your character's motivation?",
      "tags": ["warrior", "noble"],
      "is_fallback": false,
      "answers": [
        {
          "text": "Honor and duty above all",
          "effects": {
            "stats": {"honor": 2},
            "flags": {"honorable_path": true}
          },
          "next_question_id": "q002_honor"
        },
        {
          "text": "Personal gain and survival",
          "effects": {
            "stats": {"pragmatism": 2},
            "flags": {"pragmatic_path": true}
          },
          "next_question_id": "q002_pragmatic"
        }
      ]
    }
  },
  "fallback_questions": ["q099_generic", "q100_generic"]
}
```

## Data Flow

### Loading Process
1. InterviewManager loads `res://interviews.json`
2. JSON parsed into InterviewData structure
3. Validation performed on all questions and references
4. Fallback questions identified and cached
5. Data ready for interview session

### Runtime Process
1. InterviewSession created with player preset tags
2. Questions filtered by matching tags
3. If no matches, fallback questions used
4. Current question displayed to player
5. Player selects answer, effects applied immediately
6. Next question determined by answer's next_question_id
7. Process repeats until completion criteria met

### State Persistence
- InterviewSession state maintained in memory during interview
- Game effects applied immediately to global game state
- Interview history can be saved as part of game save data
- Session destroyed after interview completion

## Integration Points

### Character/Party Presets
- Player preset tags retrieved from existing CharacterBackgroundPresets.tres
- Tags used for question filtering and prioritization
- Preset system provides context for interview personalization

### Game State System
- Effects applied through existing game state management
- Stats, flags, and unlocks integrated with broader game progression
- Interview outcomes influence future game content and choices