# Quickstart: Dynamic and Branching Interview System

## Setup Requirements

### Prerequisites
- Godot 4.5 engine installed
- GUT (Godot Unit Test) framework configured
- Existing character/party creation system functional
- Basic game state management system

### File Structure
```
res://
├── interviews.json           # Interview questions and answers data
├── scenes/
│   └── InterviewScene.tscn   # Main interview UI scene
├── scripts/
│   ├── InterviewManager.gd   # Autoload singleton for state management
│   └── InterviewScene.gd     # Scene-specific interview logic
└── tests/
    ├── test_interview_manager.gd
    └── test_interview_scene.gd
```

## Quick Start Guide

### 1. Create Sample Interview Data
Create `res://interviews.json` with sample content:
```json
{
  "version": "1.0.0",
  "questions": {
    "q001": {
      "text": "What motivates your character most?",
      "tags": ["warrior", "mage"],
      "is_fallback": false,
      "answers": [
        {
          "text": "Honor and glory in battle",
          "effects": {
            "stats": {"courage": 2},
            "flags": {"warrior_path": true}
          },
          "next_question_id": "q002"
        },
        {
          "text": "Knowledge and magical power",
          "effects": {
            "stats": {"intelligence": 2},
            "flags": {"scholar_path": true}
          },
          "next_question_id": "q003"
        }
      ]
    },
    "q_fallback": {
      "text": "How do you handle unexpected challenges?",
      "tags": [],
      "is_fallback": true,
      "answers": [
        {
          "text": "Face them head-on",
          "effects": {
            "stats": {"bravery": 1}
          }
        },
        {
          "text": "Think carefully before acting",
          "effects": {
            "stats": {"wisdom": 1}
          }
        }
      ]
    }
  },
  "fallback_questions": ["q_fallback"]
}
```

### 2. Configure InterviewManager Autoload
1. Create `res://scripts/InterviewManager.gd`
2. Add to Project Settings > AutoLoad:
   - Name: `InterviewManager`
   - Path: `res://scripts/InterviewManager.gd`
   - Enable Singleton

### 3. Create Interview Scene
1. Create new scene: `InterviewScene.tscn`
2. Add UI structure:
   - Root: Control node
   - QuestionLabel: Label for question text
   - AnswerContainer: VBoxContainer for answer buttons
   - ProgressBar: Progress indicator
   - EffectsPanel: Panel for effect feedback

### 4. Test Interview Flow
Run the test suite to validate implementation:
```bash
# In Godot editor, run GUT tests
# Or via command line:
godot --headless --run-tests
```

## Integration Steps

### Step 1: Connect to Character Creation
```gdscript
# In character creation completion:
func _on_character_creation_complete():
    var player_tags = get_player_preset_tags()
    get_tree().change_scene_to_file("res://scenes/InterviewScene.tscn")
    # InterviewManager will automatically start with player tags
```

### Step 2: Handle Interview Completion
```gdscript
# In InterviewScene.gd:
func _on_interview_completed(summary: Dictionary):
    # Apply final effects
    # Transition to next game phase
    get_tree().change_scene_to_file("res://scenes/MainGameScene.tscn")
```

### Step 3: Game State Integration
```gdscript
# In InterviewManager.gd:
func apply_effects(effects: Dictionary):
    if effects.has("stats"):
        for stat_name in effects.stats:
            GameState.modify_stat(stat_name, effects.stats[stat_name])

    if effects.has("flags"):
        for flag_name in effects.flags:
            GameState.set_flag(flag_name, effects.flags[flag_name])
```

## Validation Scenarios

### Scenario 1: Basic Interview Flow
1. **Given**: Player has warrior preset selected
2. **When**: Interview starts
3. **Then**: Questions tagged "warrior" are prioritized
4. **And**: Player can select answers and see effects applied
5. **And**: Interview progresses through branching dialogue

### Scenario 2: Fallback Question Handling
1. **Given**: Player has unique preset with no matching questions
2. **When**: Interview starts
3. **Then**: Generic fallback questions are displayed
4. **And**: Interview completes normally with applied effects

### Scenario 3: Interview Completion
1. **Given**: Player has answered the maximum number of questions
2. **When**: Interview should end
3. **Then**: Completion screen is displayed
4. **And**: Player can transition to next game phase

### Scenario 4: JSON Validation
1. **Given**: interviews.json has invalid structure
2. **When**: InterviewManager loads the data
3. **Then**: Validation errors are logged
4. **And**: Fallback interview content is used

## Performance Validation

### Load Time Test
- Interview data should load in <100ms
- Scene transition should be <200ms total
- UI updates should be <16ms for 60 FPS

### Memory Usage Test
- JSON data should use <1MB memory
- UI components should release properly on scene exit
- No memory leaks during multiple interview sessions

### Stress Test
- Handle 100+ questions without performance degradation
- Validate complex branching trees (10+ levels deep)
- Test with malformed JSON data gracefully

## Troubleshooting

### Common Issues
1. **Questions not loading**: Check interviews.json path and format
2. **No fallback questions**: Verify fallback_questions array in JSON
3. **Effects not applying**: Ensure GameState integration is properly connected
4. **UI not updating**: Check signal connections between InterviewManager and scene

### Debug Mode
Enable debug logging in InterviewManager:
```gdscript
const DEBUG_MODE = true

func _debug_log(message: String):
    if DEBUG_MODE:
        print("[InterviewManager] ", message)
```

### Testing Checklist
- [ ] JSON validation passes
- [ ] Interview starts with correct questions
- [ ] Answer selection applies effects
- [ ] Branching logic works correctly
- [ ] Fallback questions display when needed
- [ ] Interview completion triggers properly
- [ ] Scene transitions work smoothly
- [ ] Memory cleanup occurs on exit