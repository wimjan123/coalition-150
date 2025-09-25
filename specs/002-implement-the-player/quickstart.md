# Quickstart: Player and Party Creation Flow

## Developer Setup

### Prerequisites
- Godot 4.5 editor installed
- Coalition 150 project loaded
- GUT testing framework configured
- Context7 MCP access for documentation

### Quick Development Setup
1. Switch to feature branch: `002-implement-the-player`
2. Ensure project autoloads include SceneManager
3. Verify GUT testing plugin is enabled
4. Run existing tests to confirm baseline functionality

## User Story Validation

### Story 1: New Player Creates Character and Party
**As a** new player
**I want to** create a political character and party
**So that** I can begin my campaign with a personalized identity

**Acceptance Criteria**:
1. ✅ Player clicks "Start Game" from main menu
2. ✅ System displays character/party selection screen
3. ✅ Player chooses "Create New"
4. ✅ System presents character creation form
5. ✅ Player fills political experience, policy positions, backstory
6. ✅ System validates all required character fields
7. ✅ System presents party creation form
8. ✅ Player enters party name, slogan, selects color and logo
9. ✅ System validates party name uniqueness
10. ✅ System initiates media interview with 5 questions
11. ✅ Player answers all interview questions
12. ✅ System saves character/party data and transitions to main game

**Test Command**: `./run_tests.sh integration/test_new_player_creation.gd`

### Story 2: Returning Player Loads Existing Character
**As a** returning player
**I want to** load my existing character and party
**So that** I can continue my political campaign

**Acceptance Criteria**:
1. ✅ Player launches game with existing save data
2. ✅ Main menu "Load Game" button is enabled
3. ✅ Player clicks "Load Game"
4. ✅ System displays available characters/parties
5. ✅ Player selects existing character
6. ✅ System loads character data and transitions to main game

**Test Command**: `./run_tests.sh integration/test_load_existing_character.gd`

### Story 3: Save System Integration
**As a** player
**I want to** have my character and party data automatically saved
**So that** I don't lose my progress if I exit during creation

**Acceptance Criteria**:
1. ✅ System auto-saves after character creation completion
2. ✅ System auto-saves after party creation completion
3. ✅ System saves final state after interview completion
4. ✅ "Load Game" button state reflects save data availability
5. ✅ Save data persists across application restarts

**Test Command**: `./run_tests.sh integration/test_save_system.gd`

## Quick Testing

### Unit Tests (Run First)
```bash
# Test core data models
./run_tests.sh unit/test_player_data.gd
./run_tests.sh unit/test_character_data.gd
./run_tests.sh unit/test_party_data.gd

# Test validation logic
./run_tests.sh unit/test_data_validation.gd
```

### Integration Tests (Run After Unit)
```bash
# Test scene interactions
./run_tests.sh integration/test_scene_transitions.gd
./run_tests.sh integration/test_complete_player_flow.gd

# Test save/load system
./run_tests.sh integration/test_save_load_system.gd
```

### Contract Tests (Verify Interfaces)
```bash
# Verify scene contracts
./run_tests.sh contract/test_scene_manager_interface.gd
./run_tests.sh contract/test_character_creation_interface.gd
./run_tests.sh contract/test_media_interview_interface.gd
```

## Quick Debugging

### Common Issues and Solutions

**"Load Game" button not enabling**:
- Check: Save file exists at `user://save_data/player_data.tres`
- Debug: `print(FileAccess.file_exists("user://save_data/player_data.tres"))`

**Scene transitions not working**:
- Check: SceneManager autoload registered in project settings
- Debug: Verify scene paths in SceneManager are correct

**Interview questions not generating**:
- Check: CharacterData has required fields populated
- Debug: Print character data before question generation

**Party name validation failing**:
- Check: PlayerData.characters array for existing names
- Debug: Print existing party names during validation

### Performance Validation

**Constitutional Requirements Check**:
```bash
# Verify 60 FPS performance
godot --headless --profile-fps scenes/player/CharacterPartyCreation.tscn

# Check scene loading times (<100ms requirement)
godot --headless --profile-loading scenes/player/

# Memory usage validation (<100MB requirement)
godot --headless --profile-memory
```

## Quick Demo

### Manual Testing Flow
1. **Launch Game** → Main menu appears
2. **Check Load Button** → Should be disabled (no save data)
3. **Click Start Game** → Character/party selection screen
4. **Click Create New** → Character creation form
5. **Fill Character** → Name, experience, policies, backstory
6. **Proceed to Party** → Party creation form
7. **Fill Party** → Name, slogan, color, logo selection
8. **Start Interview** → 5 questions based on character
9. **Answer Questions** → Multiple choice responses
10. **Complete Flow** → Transition to main game
11. **Restart Game** → Load button should now be enabled
12. **Load Character** → Skip to main game

### Expected Performance
- **Scene Transitions**: <100ms each
- **Form Validation**: Instant feedback
- **Save Operations**: <50ms
- **Interview Generation**: <200ms for 5 questions
- **Overall Flow**: <5 minutes for complete creation

## Development Priorities

### Phase 1: Core Data (Week 1)
- ✅ Implement Resource classes (PlayerData, CharacterData, PartyData)
- ✅ Create save/load system with user:// directory
- ✅ Build SceneManager autoload with transition methods

### Phase 2: UI Scenes (Week 2)
- ✅ Character/party selection scene with load functionality
- ✅ Character creation form with validation
- ✅ Party creation form with color picker and logo selection

### Phase 3: Interview System (Week 3)
- ✅ Interview scene with question generation
- ✅ Dynamic questions based on character profile
- ✅ Multiple choice answer system

### Phase 4: Integration (Week 4)
- ✅ End-to-end testing and polish
- ✅ Performance optimization to constitutional standards
- ✅ Accessibility and UI consistency validation

This quickstart provides immediate validation of core user stories and establishes the testing foundation for TDD development.