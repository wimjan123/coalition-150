# Coalition 150 - Dynamic Interview System Documentation

## Table of Contents

1. [System Overview](#system-overview)
2. [Architecture Documentation](#architecture-documentation)
3. [Complete API Documentation](#complete-api-documentation)
4. [Developer Integration Guide](#developer-integration-guide)
5. [Testing Guide](#testing-guide)
6. [JSON Schema Documentation](#json-schema-documentation)
7. [Performance Considerations](#performance-considerations)
8. [Error Handling & Edge Cases](#error-handling--edge-cases)

---

## System Overview

The Coalition 150 Dynamic Interview System is a sophisticated, branching dialogue system built for Godot 4.5. It enables dynamic character interviews with preset-based filtering, game state effects, and comprehensive progression tracking.

### Key Features

- **Dynamic Question Selection**: Questions are filtered based on player preset tags
- **Branching Dialogue Paths**: Answer choices lead to different question branches
- **Game State Effects**: Interview answers modify player stats, flags, and unlock content
- **Session Management**: Progress tracking with maximum question limits
- **Robust Validation**: Comprehensive JSON schema and reference validation
- **Fallback System**: Ensures interview continuation even with limited question matches
- **Test Coverage**: Full GUT framework test suite with integration testing

### Core Components

1. **InterviewManager** (Autoload) - Central state management singleton
2. **InterviewScene** (Scene/UI) - User interface for interview interactions
3. **InterviewData** - JSON data validation and container
4. **InterviewQuestion** - Individual question data with metadata
5. **AnswerChoice** - Answer options with effects and branching logic
6. **GameEffects** - Game state modification system
7. **InterviewSession** - Session tracking and progress management

---

## Architecture Documentation

### Component Relationships

```
┌─────────────────┐    ┌─────────────────┐
│  InterviewScene │────│ InterviewManager │ (Autoload Singleton)
│   (UI Layer)    │    │  (State Manager) │
└─────────────────┘    └─────────────────┘
                                │
                        ┌───────┴───────┐
                        │ InterviewData │
                        │  (Validator)  │
                        └───────┬───────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        │                       │                       │
┌───────▼────────┐    ┌────────▼────────┐    ┌────────▼────────┐
│InterviewQuestion│    │  AnswerChoice   │    │InterviewSession │
│   (Question     │    │  (Choice +      │    │  (Progress      │
│    Metadata)    │    │   Effects)      │    │   Tracking)     │
└────────────────┘    └─────────────────┘    └─────────────────┘
                               │
                      ┌────────▼────────┐
                      │   GameEffects   │
                      │ (State Changes) │
                      └─────────────────┘
```

### Data Flow Sequence

1. **Initialization**: `InterviewManager` loads JSON data via `InterviewData`
2. **Session Start**: UI calls `start_interview()` with player preset tags
3. **Question Selection**: Manager filters questions by tags, selects first question
4. **UI Update**: Manager emits `question_changed` signal to update interface
5. **Answer Selection**: UI calls `submit_answer()` with selected answer index
6. **Effect Application**: Manager processes effects and updates game state
7. **Progression**: Manager determines next question or completes interview
8. **Completion**: Manager emits `interview_completed` with summary data

### Design Principles

- **Separation of Concerns**: UI, logic, and data are cleanly separated
- **Signal-Based Communication**: Loose coupling through Godot's signal system
- **Defensive Programming**: Comprehensive validation and error handling
- **Testability**: All components designed for unit and integration testing
- **Extensibility**: Modular design allows easy feature additions

---

## Complete API Documentation

### InterviewManager (Autoload Singleton)

Central state management system for interview functionality.

#### Signals

```gdscript
signal question_changed(question_data: Dictionary)
signal interview_completed(summary: Dictionary)
signal effects_applied(effects: Dictionary)
```

#### Properties

```gdscript
var interview_data: InterviewData          # Data container and validator
var current_session: InterviewSession     # Active session tracker
var is_interview_active: bool             # Interview state flag
```

#### Public Methods

##### load_interview_data(file_path: String) -> bool

Loads and validates interview data from JSON file.

**Parameters:**
- `file_path`: Path to JSON interview data file

**Returns:** `true` if successful, `false` if validation fails

**Usage:**
```gdscript
var success = InterviewManager.load_interview_data("res://interviews.json")
if not success:
    print("Failed to load interview data")
```

##### start_interview(player_preset_tags: Array[String]) -> String

Initializes interview session with player context.

**Parameters:**
- `player_preset_tags`: Array of player background/class tags for filtering

**Returns:** ID of first question, empty string if failed

**Usage:**
```gdscript
var first_question_id = InterviewManager.start_interview(["warrior", "noble"])
if first_question_id.is_empty():
    handle_interview_start_failure()
```

##### get_current_question() -> Dictionary

Returns formatted data for current question.

**Returns:** Dictionary with question data for UI consumption:
- `id`: Question identifier
- `text`: Question text to display
- `answers`: Array of answer option dictionaries

##### submit_answer(answer_index: int) -> Dictionary

Processes selected answer and applies effects.

**Parameters:**
- `answer_index`: Index of selected answer (0-based)

**Returns:** Result dictionary containing:
- `effects_applied`: Dictionary of applied game effects
- `is_complete`: Boolean indicating if interview finished
- `next_question_id`: String ID of next question (if continuing)

**Usage:**
```gdscript
var result = InterviewManager.submit_answer(1)
if result.get("is_complete", false):
    handle_interview_completion()
```

##### get_session_progress() -> Dictionary

Returns current session progress information.

**Returns:** Dictionary with session state:
- `questions_answered`: Number of questions completed
- `max_questions`: Maximum questions for session
- `is_complete`: Boolean completion status
- `progress_percentage`: Float percentage (0.0-100.0)

##### complete_interview() -> Dictionary

Finalizes interview and returns comprehensive summary.

**Returns:** Summary dictionary:
- `total_questions`: Total questions answered
- `effects_summary`: Combined effects from all answers
- `completion_reason`: Reason for completion

##### validate_interview_data(data: Dictionary) -> Array[String]

Public validation method for testing interview data structure.

**Parameters:**
- `data`: Dictionary containing interview data structure

**Returns:** Array of validation error messages (empty if valid)

##### validate_question_references(data: Dictionary) -> Array[String]

Validates all question reference integrity.

**Parameters:**
- `data`: Dictionary containing interview data structure

**Returns:** Array of reference validation errors (empty if valid)

---

### InterviewScene (UI Controller)

Main user interface controller for interview interactions.

#### Signals

```gdscript
signal answer_selected(answer_index: int)
```

#### Node References

```gdscript
@onready var question_label: Label              # Question text display
@onready var answers_container: VBoxContainer   # Answer button container
@onready var progress_bar: ProgressBar          # Progress visualization
@onready var progress_label: Label              # Progress text display
```

#### Properties

```gdscript
var current_question_data: Dictionary  # Currently displayed question data
```

#### Public Methods

##### initialize_interview(player_preset_tags: Array[String]) -> void

Starts interview with player context and initializes UI.

**Parameters:**
- `player_preset_tags`: Array of player background tags

**Usage:**
```gdscript
var player_tags = ["warrior", "noble", "honorable"]
interview_scene.initialize_interview(player_tags)
```

#### Signal Handlers

##### _on_question_changed(question_data: Dictionary) -> void

Handles new question data from InterviewManager.

##### _on_interview_completed(summary: Dictionary) -> void

Handles interview completion with summary display.

##### _on_effects_applied(effects: Dictionary) -> void

Handles visual feedback for applied effects.

#### Private Methods

##### _display_question(question_data: Dictionary) -> void

Updates UI with question text and answer options.

##### _create_answer_button(text: String, index: int) -> void

Creates and configures answer selection button.

##### _update_progress_display() -> void

Updates progress bar and label with current session state.

##### _show_completion_screen(summary: Dictionary) -> void

Displays interview completion screen with summary.

##### _show_error_message(message: String) -> void

Shows error message with retry option.

---

### InterviewData (Data Container & Validator)

Container and validation system for interview data loaded from JSON.

#### Properties

```gdscript
var questions: Dictionary           # String -> InterviewQuestion mapping
var fallback_questions: Array[String]  # Fallback question IDs
var version: String                     # Data version identifier
```

#### Public Methods

##### load_from_dictionary(data: Dictionary) -> bool

Loads and validates interview data from dictionary.

**Parameters:**
- `data`: Dictionary containing structured interview data

**Returns:** `true` if successful, `false` if validation fails

##### validate_interview_data(data: Dictionary) -> Array[String]

Comprehensive validation returning list of structural errors.

**Parameters:**
- `data`: Dictionary to validate

**Returns:** Array of error messages (empty if valid)

**Usage:**
```gdscript
var errors = interview_data.validate_interview_data(json_data)
if not errors.is_empty():
    print("Validation errors: ", errors)
```

##### validate_question_references(data: Dictionary) -> Array[String]

Validates all next_question_id references are valid.

**Parameters:**
- `data`: Dictionary containing interview structure

**Returns:** Array of reference validation errors

##### get_fallback_question_ids() -> Array[String]

Returns copy of fallback question IDs for safe iteration.

##### get_question_by_id(question_id: String) -> InterviewQuestion

Retrieves question by ID, returns null if not found.

**Parameters:**
- `question_id`: String identifier for question

**Returns:** InterviewQuestion object or null

---

### InterviewQuestion (Question Data Model)

Data class representing individual interview questions with metadata.

#### Properties

```gdscript
var id: String                      # Unique question identifier
var text: String                    # Question text to display
var tags: Array[String]             # Tags for filtering/matching
var answers: Array[AnswerChoice]    # Available answer choices
var is_fallback: bool               # Whether question is fallback option
```

#### Constructor

```gdscript
func _init(question_id: String = "", question_text: String = "",
          question_tags: Array[String] = [], question_answers: Array[AnswerChoice] = [],
          fallback: bool = false) -> void
```

#### Public Methods

##### is_valid() -> bool

Validates question meets all requirements.

**Returns:** `true` if question is valid (ID, text, 2-5 answers)

##### matches_tags(player_tags: Array[String]) -> bool

Checks if question tags match any player tags.

**Parameters:**
- `player_tags`: Array of player background tags

**Returns:** `true` if any tag matches or is fallback question

**Usage:**
```gdscript
var player_tags = ["warrior", "noble"]
if question.matches_tags(player_tags):
    # Question is suitable for player
```

##### to_dictionary() -> Dictionary

Converts question to dictionary for serialization.

**Returns:** Dictionary representation of question

##### from_dictionary(question_id: String, data: Dictionary) -> InterviewQuestion

Static method to create InterviewQuestion from dictionary data.

**Parameters:**
- `question_id`: Unique identifier for question
- `data`: Dictionary containing question data

**Returns:** New InterviewQuestion instance

---

### AnswerChoice (Answer Data Model)

Data class representing player response options with effects and branching.

#### Properties

```gdscript
var text: String                # Answer text to display
var effects: GameEffects        # Effects applied when selected
var next_question_id: String    # Next question ID (empty if terminal)
```

#### Constructor

```gdscript
func _init(answer_text: String = "", answer_effects: GameEffects = null,
          next_id: String = "") -> void
```

#### Public Methods

##### is_valid() -> bool

Validates answer meets requirements.

**Returns:** `true` if answer has text and valid effects

##### has_next_question() -> bool

Checks if answer leads to another question.

**Returns:** `true` if next_question_id is not empty

##### to_dictionary() -> Dictionary

Converts answer to dictionary for serialization.

**Returns:** Dictionary representation including conditional next_question_id

##### from_dictionary(data: Dictionary) -> AnswerChoice

Static method to create AnswerChoice from dictionary data.

**Parameters:**
- `data`: Dictionary containing answer data

**Returns:** New AnswerChoice instance

---

### GameEffects (Effects System)

Data class representing game state modifications from interview answers.

#### Properties

```gdscript
var stats: Dictionary           # String -> int (stat changes)
var flags: Dictionary          # String -> bool (boolean flags)
var unlocks: Array[String]     # Content unlock identifiers
```

#### Constructor

```gdscript
func _init(stat_changes: Dictionary = {}, flag_changes: Dictionary = {},
          content_unlocks: Array[String] = []) -> void
```

#### Public Methods

##### is_valid() -> bool

Validates effects data meets requirements.

**Returns:** `true` if all stats are integers (-10 to +10), flags are booleans, unlocks are non-empty strings

##### has_effects() -> bool

Checks if any effects are present.

**Returns:** `true` if stats, flags, or unlocks contain data

##### apply_stat_change(stat_name: String, change_value: int) -> void

Adds or updates stat change.

**Parameters:**
- `stat_name`: Name of stat to modify
- `change_value`: Integer change value (-10 to +10)

##### apply_flag_change(flag_name: String, flag_value: bool) -> void

Sets boolean flag.

**Parameters:**
- `flag_name`: Name of flag to set
- `flag_value`: Boolean value for flag

##### add_unlock(unlock_name: String) -> void

Adds content unlock (prevents duplicates).

**Parameters:**
- `unlock_name`: Identifier for unlocked content

##### merge_with(other_effects: GameEffects) -> GameEffects

Combines effects with another GameEffects instance.

**Parameters:**
- `other_effects`: GameEffects to merge with

**Returns:** New GameEffects with combined values

**Merge Rules:**
- Stats: Values are summed for same keys
- Flags: Other effects override current values
- Unlocks: Unique values are combined

##### to_dictionary() -> Dictionary

Converts effects to dictionary for serialization.

**Returns:** Dictionary with stats/flags/unlocks (empty sections omitted)

##### from_dictionary(data: Dictionary) -> GameEffects

Static method to create GameEffects from dictionary data.

**Parameters:**
- `data`: Dictionary containing effects data

**Returns:** New GameEffects instance

---

### InterviewSession (Session Management)

Data class tracking current interview state and player progress.

#### Enums

```gdscript
enum State {
    STARTING,   # Session initialized but not started
    ACTIVE,     # Session in progress
    COMPLETED   # Session finished
}
```

#### Properties

```gdscript
var current_question_id: String         # Current question being displayed
var answer_history: Array[String]       # History of selected answer indices
var questions_answered: int             # Number of questions completed
var max_questions: int                  # Maximum questions for session
var player_preset_tags: Array[String]   # Player tags for filtering
var state: State                        # Current session state
var applied_effects: Array[Dictionary]  # All effects applied this session
```

#### Constructor

```gdscript
func _init(preset_tags: Array[String] = [], maximum_questions: int = 10) -> void
```

#### Public Methods

##### is_valid() -> bool

Validates session configuration.

**Returns:** `true` if max_questions is 1-10

##### is_complete() -> bool

Checks if interview session is complete.

**Returns:** `true` if state is COMPLETED or max questions reached

##### can_continue() -> bool

Checks if interview can continue.

**Returns:** `true` if state is ACTIVE and not complete

##### start_session(first_question_id: String) -> void

Initializes active interview session.

**Parameters:**
- `first_question_id`: ID of first question to display

##### record_answer(answer_index: int, effects: Dictionary) -> void

Records player's answer and applied effects.

**Parameters:**
- `answer_index`: Index of selected answer
- `effects`: Dictionary of effects that were applied

##### advance_to_question(next_question_id: String) -> void

Moves session to next question.

**Parameters:**
- `next_question_id`: ID of next question to display

##### complete_session() -> void

Marks interview session as completed and clears current question.

##### get_progress_percentage() -> float

Calculates interview completion percentage.

**Returns:** Float percentage (0.0-100.0)

##### to_dictionary() -> Dictionary

Converts session to dictionary for serialization.

**Returns:** Complete session state dictionary

---

## Developer Integration Guide

### Basic Integration

#### 1. Scene Setup

Add InterviewScene to your game with required UI nodes:

```gdscript
# Scene structure:
# InterviewScene (Control)
# ├── QuestionContainer (VBoxContainer)
# │   └── QuestionLabel (Label)
# ├── AnswersContainer (VBoxContainer)
# └── ProgressContainer (HBoxContainer)
#     ├── ProgressBar (ProgressBar)
#     └── ProgressLabel (Label)
```

#### 2. Data Preparation

Create JSON interview data file following the schema:

```json
{
  "version": "1.0.0",
  "questions": {
    "q001": {
      "text": "Your question here?",
      "tags": ["warrior", "noble"],
      "is_fallback": false,
      "answers": [
        {
          "text": "Answer option 1",
          "effects": {
            "stats": {"honor": 2},
            "flags": {"noble_path": true},
            "unlocks": ["noble_dialogue"]
          },
          "next_question_id": "q002"
        }
      ]
    }
  },
  "fallback_questions": ["q_fallback_01"]
}
```

#### 3. Integration Example

```gdscript
# In your character creation scene:
extends Control

func _ready():
    # Load interview data
    var data_loaded = InterviewManager.load_interview_data("res://interviews.json")
    if not data_loaded:
        handle_data_load_error()
        return

    # Connect to interview completion
    InterviewManager.interview_completed.connect(_on_interview_completed)

func start_character_interview():
    # Get player preset tags from character creation
    var player_tags = get_player_preset_tags()  # Your implementation

    # Load interview scene
    var interview_scene = load("res://scenes/InterviewScene.tscn").instantiate()
    add_child(interview_scene)

    # Initialize interview
    interview_scene.initialize_interview(player_tags)

func _on_interview_completed(summary: Dictionary):
    # Process interview results
    apply_interview_effects_to_player(summary)
    transition_to_game_start()
```

### Advanced Integration Patterns

#### Custom Effect Processing

```gdscript
# Override effect application in InterviewManager
func _apply_game_effects(effects: GameEffects) -> void:
    # Apply stats to your player system
    for stat_name in effects.stats.keys():
        PlayerStats.modify_stat(stat_name, effects.stats[stat_name])

    # Set game flags
    for flag_name in effects.flags.keys():
        GameState.set_flag(flag_name, effects.flags[flag_name])

    # Unlock content
    for unlock in effects.unlocks:
        ContentManager.unlock_content(unlock)
```

#### Custom Question Filtering

```gdscript
# Add custom filtering logic in InterviewManager
func _filter_questions_by_custom_logic(player_data: Dictionary) -> Array[String]:
    var matching_questions: Array[String] = []

    for question_id in interview_data.questions.keys():
        var question: InterviewQuestion = interview_data.questions[question_id]

        # Your custom logic here
        if custom_question_matches_player(question, player_data):
            matching_questions.append(question_id)

    return matching_questions
```

### Error Handling Integration

#### Graceful Fallbacks

```gdscript
# In your integration code:
func start_interview_with_fallbacks(player_tags: Array[String]):
    var first_question_id = InterviewManager.start_interview(player_tags)

    if first_question_id.is_empty():
        # Fallback to default character creation
        show_default_character_creation()
        return

    # Continue with interview
    show_interview_ui()

# Handle errors during interview
func _on_interview_error(error_message: String):
    # Log error
    push_error("Interview error: " + error_message)

    # Provide fallback experience
    complete_character_creation_without_interview()
```

### Performance Optimization

#### Preload Strategy

```gdscript
# Preload interview data at game start
func _ready():
    # Load data early in game lifecycle
    InterviewManager.load_interview_data("res://interviews.json")

    # Validate data integrity
    if not InterviewManager.interview_data:
        push_error("Critical: Interview data failed to load")
        use_fallback_character_creation()
```

#### Memory Management

```gdscript
# Clean up interview resources when done
func cleanup_interview_system():
    # Clear session data
    if InterviewManager.current_session:
        InterviewManager.current_session = null

    # Disconnect signals if needed
    if InterviewManager.question_changed.is_connected(_on_question_changed):
        InterviewManager.question_changed.disconnect(_on_question_changed)
```

---

## Testing Guide

The interview system includes comprehensive test coverage using the GUT (Godot Unit Test) framework.

### Test Structure

```
tests/
├── unit/                    # Unit tests for individual components
├── integration/             # Integration tests for system interactions
├── contract/                # Contract/interface tests
├── data/                    # Test data files
├── test_interview_*.gd      # Core interview system tests
└── test_*.gd               # Component-specific tests
```

### Running Tests

#### Using GUT Test Runner

```bash
# Run all tests
godot --headless -s addons/gut/gut_cmdln.gd

# Run specific test suite
godot --headless -s addons/gut/gut_cmdln.gd -gdir=tests/ -gfile=test_interview_integration.gd

# Run with specific configuration
godot --headless -s addons/gut/gut_cmdln.gd -gconfig=.gutconfig.json
```

#### Configuration

`.gutconfig.json`:
```json
{
  "dirs": ["tests"],
  "include_subdirs": true,
  "log_level": 1,
  "should_exit": true,
  "should_exit_on_success": true
}
```

### Key Test Files

#### test_interview_integration.gd
Comprehensive integration tests covering full interview workflows.

**Test Cases:**
- Complete interview flow from start to finish
- Question filtering based on player tags
- Effect application and accumulation
- Session progress tracking
- Error handling and recovery

#### test_interview_manager_contract.gd
Contract tests ensuring InterviewManager API compliance.

**Test Cases:**
- Signal emission verification
- Method return value validation
- State transition testing
- Error condition handling

#### test_interview_scene.gd
UI component testing for InterviewScene.

**Test Cases:**
- UI state updates
- Button creation and interaction
- Progress display accuracy
- Error message handling

### Writing New Tests

#### Unit Test Example

```gdscript
extends GutTest

# Test InterviewQuestion validation
func test_interview_question_validation():
    # Valid question
    var valid_question = InterviewQuestion.new(
        "test_id",
        "Test question?",
        ["warrior"],
        [AnswerChoice.new("Answer 1", GameEffects.new())],
        false
    )
    assert_true(valid_question.is_valid(), "Valid question should pass validation")

    # Invalid question (no text)
    var invalid_question = InterviewQuestion.new("test_id", "", [], [], false)
    assert_false(invalid_question.is_valid(), "Question without text should fail validation")
```

#### Integration Test Example

```gdscript
extends GutTest

var interview_manager: InterviewManager
var test_data: Dictionary

func before_each():
    interview_manager = InterviewManager.new()
    test_data = load_test_interview_data()

func test_complete_interview_flow():
    # Load test data
    assert_true(interview_manager.load_interview_data("res://tests/data/mock_interview_valid.json"))

    # Start interview
    var first_question_id = interview_manager.start_interview(["warrior", "noble"])
    assert_ne(first_question_id, "", "Should return valid first question ID")

    # Verify initial state
    var current_question = interview_manager.get_current_question()
    assert_false(current_question.is_empty(), "Should have current question data")

    # Submit answer and continue
    var result = interview_manager.submit_answer(0)
    assert_true(result.has("effects_applied"), "Should return applied effects")

    # Complete interview
    if result.get("is_complete", false):
        var summary = interview_manager.complete_interview()
        assert_true(summary.has("total_questions"), "Summary should include question count")
```

### Test Data Management

#### Mock Data Files

- `tests/data/mock_interview_valid.json` - Valid interview data for positive tests
- `tests/data/mock_interview_invalid.json` - Invalid data for error handling tests
- `tests/data/mock_interview_malformed.json` - Malformed JSON for parsing tests

#### Creating Test Data

```gdscript
# Helper function for creating test data
func create_test_interview_data() -> Dictionary:
    return {
        "version": "1.0.0",
        "questions": {
            "test_q1": {
                "text": "Test question 1?",
                "tags": ["test"],
                "is_fallback": false,
                "answers": [
                    {
                        "text": "Test answer 1",
                        "effects": {"stats": {"test_stat": 1}},
                        "next_question_id": "test_q2"
                    }
                ]
            },
            "test_q2": {
                "text": "Test question 2?",
                "tags": ["test"],
                "is_fallback": false,
                "answers": [
                    {
                        "text": "Final answer",
                        "effects": {"stats": {"test_stat": 1}}
                    }
                ]
            }
        },
        "fallback_questions": ["test_q1"]
    }
```

### Automated Testing Integration

#### CI/CD Pipeline

```yaml
# .github/workflows/test.yml
name: Test Interview System

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup Godot
        uses: chickensoft-games/setup-godot@v1
        with:
          version: 4.5.0
      - name: Run Tests
        run: godot --headless -s addons/gut/gut_cmdln.gd
```

#### Test Coverage Analysis

```gdscript
# Add to test suite for coverage reporting
func test_coverage_analysis():
    var total_methods = count_total_methods_in_system()
    var tested_methods = count_tested_methods()
    var coverage_percentage = (tested_methods * 100.0) / total_methods

    gut.p("Test Coverage: " + str(coverage_percentage) + "%")
    assert_gt(coverage_percentage, 80.0, "Test coverage should be above 80%")
```

---

## JSON Schema Documentation

### Root Schema Structure

The interview data follows a structured JSON schema with validation rules:

```json
{
  "type": "object",
  "required": ["version", "questions", "fallback_questions"],
  "properties": {
    "version": {
      "type": "string",
      "pattern": "^\\d+\\.\\d+\\.\\d+$",
      "description": "Semantic version of interview data"
    },
    "questions": {
      "type": "object",
      "description": "Dictionary of question_id -> question_data",
      "minProperties": 1
    },
    "fallback_questions": {
      "type": "array",
      "description": "Array of question IDs to use when tag filtering fails",
      "minItems": 1,
      "items": {"type": "string"}
    }
  }
}
```

### Question Schema

Each question in the questions dictionary follows this structure:

```json
{
  "type": "object",
  "required": ["text", "tags", "is_fallback", "answers"],
  "properties": {
    "text": {
      "type": "string",
      "minLength": 1,
      "description": "Question text to display to player"
    },
    "tags": {
      "type": "array",
      "description": "Tags for filtering questions by player preset",
      "items": {"type": "string"}
    },
    "is_fallback": {
      "type": "boolean",
      "description": "Whether this question should be used as fallback"
    },
    "answers": {
      "type": "array",
      "minItems": 2,
      "maxItems": 5,
      "description": "Array of answer choices",
      "items": {"$ref": "#/definitions/answer"}
    }
  }
}
```

### Answer Choice Schema

Each answer choice has the following structure:

```json
{
  "type": "object",
  "required": ["text", "effects"],
  "properties": {
    "text": {
      "type": "string",
      "minLength": 1,
      "description": "Answer text to display"
    },
    "effects": {
      "$ref": "#/definitions/gameEffects",
      "description": "Game state effects when this answer is selected"
    },
    "next_question_id": {
      "type": "string",
      "description": "ID of next question (optional, omit for terminal answers)"
    }
  }
}
```

### Game Effects Schema

Effects modify game state when answers are selected:

```json
{
  "type": "object",
  "properties": {
    "stats": {
      "type": "object",
      "description": "Stat changes (stat_name -> integer_change)",
      "patternProperties": {
        "^[a-zA-Z_][a-zA-Z0-9_]*$": {
          "type": "integer",
          "minimum": -10,
          "maximum": 10
        }
      }
    },
    "flags": {
      "type": "object",
      "description": "Boolean flags to set (flag_name -> boolean_value)",
      "patternProperties": {
        "^[a-zA-Z_][a-zA-Z0-9_]*$": {
          "type": "boolean"
        }
      }
    },
    "unlocks": {
      "type": "array",
      "description": "Content to unlock",
      "items": {
        "type": "string",
        "minLength": 1
      }
    }
  }
}
```

### Validation Rules

#### Version Validation
- Must follow semantic versioning (e.g., "1.0.0")
- Pattern: `^\\d+\\.\\d+\\.\\d+$`

#### Question Validation
- Must have non-empty text
- Must have 2-5 answer choices
- Question ID must be unique within questions dictionary
- Tags array can be empty (for fallback questions)

#### Answer Validation
- Must have non-empty answer text
- Effects object can be empty but must be present
- next_question_id is optional (omit for terminal answers)
- next_question_id must reference existing question if present

#### Effects Validation
- Stat values must be integers between -10 and +10
- Flag values must be booleans
- Unlock values must be non-empty strings
- All sections (stats, flags, unlocks) are optional

#### Reference Validation
- All next_question_id values must reference existing questions
- All fallback_questions entries must reference existing questions
- Circular references are allowed but should be avoided

### Example Complete Interview Data

```json
{
  "version": "1.0.0",
  "questions": {
    "q001_start": {
      "text": "What drives your character's motivations?",
      "tags": ["warrior", "noble", "common"],
      "is_fallback": false,
      "answers": [
        {
          "text": "Honor and duty above all",
          "effects": {
            "stats": {"honor": 2, "duty": 1},
            "flags": {"noble_path": true},
            "unlocks": ["noble_questline"]
          },
          "next_question_id": "q002_honor"
        },
        {
          "text": "Personal survival and pragmatism",
          "effects": {
            "stats": {"cunning": 2, "pragmatism": 1},
            "flags": {"survivor_path": true},
            "unlocks": ["rogue_questline"]
          },
          "next_question_id": "q002_survival"
        },
        {
          "text": "Knowledge and understanding",
          "effects": {
            "stats": {"intelligence": 2, "wisdom": 1},
            "flags": {"scholar_path": true},
            "unlocks": ["mage_questline"]
          },
          "next_question_id": "q002_knowledge"
        }
      ]
    },
    "q002_honor": {
      "text": "Your party faces a moral dilemma. How do you respond?",
      "tags": ["noble", "lawful"],
      "is_fallback": false,
      "answers": [
        {
          "text": "Stand by principles regardless of cost",
          "effects": {
            "stats": {"honor": 1, "determination": 2},
            "flags": {"unwavering": true}
          }
        },
        {
          "text": "Seek compromise that satisfies all parties",
          "effects": {
            "stats": {"diplomacy": 2, "wisdom": 1},
            "flags": {"diplomatic": true}
          }
        }
      ]
    },
    "fallback_general": {
      "text": "How do you typically approach challenges?",
      "tags": [],
      "is_fallback": true,
      "answers": [
        {
          "text": "Direct confrontation",
          "effects": {
            "stats": {"courage": 1, "strength": 1}
          }
        },
        {
          "text": "Careful planning",
          "effects": {
            "stats": {"intelligence": 1, "patience": 1}
          }
        },
        {
          "text": "Creative solutions",
          "effects": {
            "stats": {"creativity": 1, "adaptability": 1}
          }
        }
      ]
    }
  },
  "fallback_questions": ["fallback_general"]
}
```

### Schema Validation Tools

#### In-Game Validation

```gdscript
# Validate loaded data
var validation_errors = InterviewManager.validate_interview_data(json_data)
if not validation_errors.is_empty():
    for error in validation_errors:
        push_error("Interview data error: " + error)
    return false

# Validate references
var reference_errors = InterviewManager.validate_question_references(json_data)
if not reference_errors.is_empty():
    for error in reference_errors:
        push_error("Reference error: " + error)
    return false
```

#### External Validation

```bash
# Using JSON Schema validator (if available)
jsonschema -i interviews.json schema.json

# Custom validation script
python validate_interview_data.py interviews.json
```

---

## Performance Considerations

### Memory Management

#### Data Loading Strategy

```gdscript
# Lazy loading approach
func load_interview_data_lazy(file_path: String) -> bool:
    # Only load when needed
    if interview_data.questions.is_empty():
        return _load_and_validate_data(file_path)
    return true

# Preloading approach
func preload_interview_data() -> void:
    # Load at game start for faster access
    load_interview_data("res://interviews.json")
```

#### Memory Usage Optimization

- **Question Filtering**: Filter questions by tags before creating objects
- **Effect Batching**: Combine similar effects to reduce object creation
- **Session Cleanup**: Clear session data after completion
- **Reference Counting**: Use RefCounted for automatic memory management

### Processing Efficiency

#### Question Selection Performance

```gdscript
# Optimized question filtering
func _filter_questions_optimized(player_tags: Array[String]) -> Array[String]:
    var matching_questions: Array[String] = []

    # Pre-calculate tag lookup for O(1) access
    var tag_lookup: Dictionary = {}
    for tag in player_tags:
        tag_lookup[tag] = true

    # Single pass through questions
    for question_id in interview_data.questions.keys():
        var question: InterviewQuestion = interview_data.questions[question_id]
        if _question_matches_optimized(question, tag_lookup):
            matching_questions.append(question_id)

    return matching_questions

func _question_matches_optimized(question: InterviewQuestion, tag_lookup: Dictionary) -> bool:
    if question.is_fallback:
        return true

    for tag in question.tags:
        if tag_lookup.has(tag):
            return true

    return false
```

#### Effect Application Performance

```gdscript
# Batch effect application
func apply_effects_batch(effects_list: Array[GameEffects]) -> void:
    var combined_effects: GameEffects = GameEffects.new()

    # Merge all effects first
    for effects in effects_list:
        combined_effects = combined_effects.merge_with(effects)

    # Apply once to game state
    _apply_to_game_state(combined_effects)
```

### Scalability Considerations

#### Large Question Sets

- **Pagination**: Load questions in chunks for very large datasets
- **Indexing**: Create tag-based indices for faster filtering
- **Caching**: Cache filtered question lists for repeated queries

```gdscript
# Question indexing system
var question_index_by_tags: Dictionary = {}

func build_question_index() -> void:
    for question_id in interview_data.questions.keys():
        var question: InterviewQuestion = interview_data.questions[question_id]
        for tag in question.tags:
            if not question_index_by_tags.has(tag):
                question_index_by_tags[tag] = []
            question_index_by_tags[tag].append(question_id)

func get_questions_by_tag_fast(tag: String) -> Array[String]:
    return question_index_by_tags.get(tag, [])
```

### Resource Usage Guidelines

#### Recommended Limits

- **Questions per file**: 50-200 questions maximum
- **Answers per question**: 2-5 answers (enforced by validation)
- **Session length**: 5-15 questions per interview
- **Effect values**: -10 to +10 for stats (enforced by validation)

#### Monitoring Performance

```gdscript
# Performance monitoring wrapper
func load_interview_data_with_monitoring(file_path: String) -> bool:
    var start_time = Time.get_time_dict_from_system()
    var success = load_interview_data(file_path)
    var end_time = Time.get_time_dict_from_system()

    var load_duration = calculate_time_difference(start_time, end_time)
    print("Interview data loaded in: ", load_duration, " ms")

    if load_duration > 100:  # 100ms threshold
        push_warning("Interview data loading took longer than expected")

    return success
```

---

## Error Handling & Edge Cases

### Error Categories

#### Data Loading Errors

```gdscript
# File access errors
func handle_file_access_errors(file_path: String) -> bool:
    if not FileAccess.file_exists(file_path):
        _log_error("Interview file not found: " + file_path)
        return false

    var file = FileAccess.open(file_path, FileAccess.READ)
    if file == null:
        _log_error("Cannot access interview file: " + file_path)
        return false

    return true

# JSON parsing errors
func handle_json_parsing_errors(json_string: String) -> Dictionary:
    var json = JSON.new()
    var parse_result = json.parse(json_string)

    if parse_result != OK:
        _log_error("JSON parsing failed: " + json.get_error_message() +
                  " at line " + str(json.get_error_line()))
        return {}

    return json.data
```

#### Validation Errors

```gdscript
# Schema validation with detailed errors
func validate_with_detailed_errors(data: Dictionary) -> Array[String]:
    var errors: Array[String] = []

    # Version validation
    if not data.has("version"):
        errors.append("Missing required field: version")
    elif not data.version.match("^\\d+\\.\\d+\\.\\d+$"):
        errors.append("Invalid version format: " + str(data.version))

    # Questions validation
    if not data.has("questions"):
        errors.append("Missing required field: questions")
    elif data.questions.is_empty():
        errors.append("Questions dictionary cannot be empty")
    else:
        for question_id in data.questions.keys():
            var question_errors = _validate_question_detailed(question_id, data.questions[question_id])
            errors.append_array(question_errors)

    return errors
```

#### Runtime Errors

```gdscript
# Session state validation
func validate_session_state() -> bool:
    if not is_interview_active:
        _log_error("Attempted operation on inactive interview session")
        return false

    if current_session == null:
        _log_error("Current session is null but interview marked as active")
        is_interview_active = false
        return false

    if current_session.current_question_id.is_empty():
        _log_error("Current question ID is empty in active session")
        return false

    return true

# Answer submission validation
func validate_answer_submission(answer_index: int) -> bool:
    var current_question = get_current_question()
    if current_question.is_empty():
        _log_error("No current question available for answer submission")
        return false

    var answers_count = current_question.get("answers", []).size()
    if answer_index < 0 or answer_index >= answers_count:
        _log_error("Invalid answer index: " + str(answer_index) +
                  " (valid range: 0-" + str(answers_count - 1) + ")")
        return false

    return true
```

### Edge Case Handling

#### Empty Tag Matching

```gdscript
# Handle players with no preset tags
func handle_empty_player_tags(player_tags: Array[String]) -> String:
    if player_tags.is_empty():
        _log_info("Player has no preset tags, using fallback questions")
        return _select_fallback_question()

    # Try normal filtering first
    var matching_questions = _filter_questions_by_tags(player_tags)
    if matching_questions.is_empty():
        _log_info("No questions match player tags: " + str(player_tags))
        return _select_fallback_question()

    return matching_questions[0]
```

#### Circular Reference Prevention

```gdscript
# Detect and handle circular references
func detect_circular_references(start_question_id: String) -> bool:
    var visited_questions: Array[String] = []
    var current_id = start_question_id

    while not current_id.is_empty():
        if visited_questions.has(current_id):
            _log_warning("Circular reference detected: " + str(visited_questions) + " -> " + current_id)
            return true

        visited_questions.append(current_id)
        current_id = _get_next_question_id(current_id)

        # Safety limit
        if visited_questions.size() > 20:
            _log_warning("Question chain exceeds safety limit")
            return true

    return false
```

#### Session Recovery

```gdscript
# Recover from corrupted session state
func recover_session_state() -> bool:
    if current_session == null:
        _log_info("Creating new session for recovery")
        current_session = InterviewSession.new([], 10)
        return true

    if current_session.current_question_id.is_empty():
        _log_info("Recovering session with empty question ID")
        var fallback_id = _select_fallback_question()
        if not fallback_id.is_empty():
            current_session.current_question_id = fallback_id
            return true
        return false

    # Verify current question exists
    var question = interview_data.get_question_by_id(current_session.current_question_id)
    if question == null:
        _log_warning("Current question no longer exists: " + current_session.current_question_id)
        return _reset_to_fallback_question()

    return true
```

### Graceful Degradation

#### Fallback Strategies

```gdscript
# Multi-level fallback system
func get_question_with_fallbacks(preferred_tags: Array[String]) -> String:
    # Level 1: Try exact tag match
    var exact_matches = _filter_questions_by_tags(preferred_tags)
    if not exact_matches.is_empty():
        return exact_matches[0]

    # Level 2: Try partial tag match
    var partial_matches = _filter_questions_by_partial_tags(preferred_tags)
    if not partial_matches.is_empty():
        return partial_matches[0]

    # Level 3: Try fallback questions
    var fallback_questions = interview_data.get_fallback_question_ids()
    if not fallback_questions.is_empty():
        return fallback_questions[0]

    # Level 4: Use any available question
    var all_question_ids = interview_data.questions.keys()
    if not all_question_ids.is_empty():
        _log_warning("Using arbitrary question as last resort")
        return all_question_ids[0]

    # Level 5: Complete failure
    _log_error("No questions available in interview data")
    return ""
```

#### Safe Mode Operation

```gdscript
# Enable safe mode for degraded operation
var safe_mode_enabled: bool = false

func enable_safe_mode(reason: String) -> void:
    safe_mode_enabled = true
    _log_warning("Safe mode enabled: " + reason)

    # Reduce functionality to essential operations only
    # Disable complex features that might fail

func handle_operation_in_safe_mode(operation_name: String) -> bool:
    if not safe_mode_enabled:
        return true

    # Allow only essential operations in safe mode
    var allowed_operations = ["get_current_question", "submit_answer", "complete_interview"]
    if not allowed_operations.has(operation_name):
        _log_warning("Operation disabled in safe mode: " + operation_name)
        return false

    return true
```

### Error Recovery Mechanisms

#### Automatic Recovery

```gdscript
# Automatic error recovery system
func attempt_automatic_recovery(error_type: String) -> bool:
    match error_type:
        "corrupted_session":
            return _recover_session_from_backup()
        "invalid_question_id":
            return _reset_to_valid_question()
        "missing_answer_data":
            return _reconstruct_answer_data()
        _:
            _log_error("Unknown error type for recovery: " + error_type)
            return false

func _recover_session_from_backup() -> bool:
    # Restore from previous valid state
    if has_session_backup():
        current_session = load_session_backup()
        return true

    # Create minimal valid session
    current_session = InterviewSession.new([], 10)
    var first_question = _select_fallback_question()
    if not first_question.is_empty():
        current_session.start_session(first_question)
        return true

    return false
```

---

## Conclusion

The Coalition 150 Dynamic Interview System provides a robust, extensible foundation for character interviews in Godot 4.5. The comprehensive architecture supports complex branching dialogues, game state effects, and graceful error handling while maintaining high performance and testability.

Key strengths of the system:

- **Modularity**: Clean separation of concerns allows independent testing and modification
- **Validation**: Multiple layers of validation ensure data integrity
- **Extensibility**: Plugin architecture supports custom effects and filtering logic
- **Robustness**: Comprehensive error handling and fallback mechanisms
- **Performance**: Optimized for large question sets and frequent operations
- **Testability**: Full GUT test coverage with integration and contract testing

For developers integrating this system, focus on:
1. Following the JSON schema exactly for interview data
2. Implementing proper error handling in integration code
3. Testing edge cases like missing tags or corrupted data
4. Monitoring performance with large question sets
5. Extending the effects system for your specific game mechanics

The system is ready for production use and can scale to support complex, multi-branch interviews while maintaining excellent performance and reliability.