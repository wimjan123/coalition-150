# Interview System Implementation

## Overview
Dynamic and branching interview system for Coalition 150 character creation. Implemented with TDD using GUT framework and following Godot 4.5 best practices.

## Features
- ✅ JSON-driven question system with validation
- ✅ Preset-based question filtering (warrior, mage, noble, scholar)
- ✅ Branching dialogue paths with next_question_id
- ✅ Game effects system (stats, flags, unlocks)
- ✅ Session management with progress tracking
- ✅ Full UI implementation with error handling
- ✅ Comprehensive test coverage

## Architecture

### Core Components
- **InterviewManager** - Autoload singleton managing interview state
- **InterviewScene** - UI scene for displaying questions and answers
- **InterviewData** - Container and validator for JSON data
- **InterviewSession** - Tracks current session state and progress

### Data Models
- **InterviewQuestion** - Individual question with tags and answers
- **AnswerChoice** - Answer option with effects and branching
- **GameEffects** - Game state modifications (stats/flags/unlocks)

## Usage

### 1. Load Interview Data
```gdscript
# Load from JSON file
var success = InterviewManager.load_interview_data("res://interviews.json")
```

### 2. Start Interview
```gdscript
# Initialize interview scene
var scene = preload("res://scenes/InterviewScene.tscn").instantiate()
get_tree().current_scene.add_child(scene)

# Start with player preset tags
scene.initialize_interview(["warrior", "noble"])
```

### 3. Handle Signals
```gdscript
# Connect to interview events
InterviewManager.question_changed.connect(_on_question_changed)
InterviewManager.effects_applied.connect(_on_effects_applied)
InterviewManager.interview_completed.connect(_on_interview_completed)
```

## JSON Data Format

```json
{
  "version": "1.0.0",
  "questions": {
    "warrior_q1": {
      "text": "How do you approach conflict?",
      "tags": ["warrior"],
      "is_fallback": false,
      "answers": [
        {
          "text": "Face it head-on with courage",
          "effects": {
            "stats": {"strength": 2, "courage": 1},
            "flags": {"brave": true},
            "unlocks": ["berserker_path"]
          },
          "next_question_id": "warrior_q2"
        }
      ]
    }
  },
  "fallback_questions": ["general_q1", "general_q2"]
}
```

## File Structure

```
scripts/
├── InterviewManager.gd          # Main autoload singleton
├── models/
│   ├── interview_data.gd        # JSON data container
│   ├── interview_session.gd     # Session state tracking
│   ├── interview_question.gd    # Question data model
│   ├── answer_choice.gd         # Answer option model
│   └── game_effects.gd         # Game state effects
└── validate_interview_system.gd # Validation script

scenes/
├── InterviewScene.tscn         # Main UI scene
└── InterviewScene.gd           # Scene script

tests/
├── test_interview_manager.gd   # InterviewManager tests
├── test_interview_scene.gd     # UI component tests
├── test_interview_integration.gd # Integration tests
├── test_json_validation.gd     # JSON validation tests
└── test_data_models.gd         # Data model tests

interviews.json                  # Sample interview data
```

## Testing

### Run All Tests
```bash
# Using GUT addon (in Godot editor)
# Go to Project > Project Settings > Plugins > Enable GUT
# Go to Window > Dock > GUT and run tests

# Or use command line (if available)
godot --headless --script addons/gut/gut_cmdln.gd -gdir=res://tests/
```

### Validation Script
```bash
# Run validation script
godot --headless --script scripts/validate_interview_system.gd
```

## Configuration

### Project Settings
- Added InterviewManager to autoload list
- Enabled GDScript strict typing warnings
- Set main scene to InterviewScene for testing

### Performance Targets
- 60 FPS during interview UI
- <100ms for scene transitions
- <16ms for UI updates and question loading

## Error Handling
- JSON validation with detailed error messages
- Graceful fallback to fallback questions
- UI error states with retry functionality
- Session recovery and reset capabilities

## Integration Points
- Connects to existing GameManager for state persistence
- Compatible with SceneManager for scene transitions
- Effects system ready for integration with player stats
- Signal-based architecture for loose coupling

## Future Enhancements
- Localization support for multiple languages
- Audio integration for question narration
- Visual themes based on question tags
- Analytics tracking for question preferences
- Save/resume interview sessions