# Tasks: Player and Party Creation Flow

**Input**: Design documents from `/specs/002-implement-the-player/`
**Prerequisites**: plan.md (required), research.md, data-model.md, contracts/, quickstart.md

## Execution Flow
```
1. Load plan.md from feature directory → Coalition 150 player creation flow
2. Extract: Godot 4.5, GDScript 2.0, GUT framework, Resource system
3. Load design documents:
   → data-model.md: 4 Resource classes → model tasks
   → contracts/: 3 interface files → contract test tasks
   → research.md: Godot best practices → setup tasks
4. Generate tasks by TDD approach:
   → Setup: project structure, autoloads, themes
   → Tests: contract tests for all 3 interfaces
   → Models: 4 Resource classes for data persistence
   → Services: SceneManager, save/load system
   → Scenes: 3 UI scenes with scripts
   → Integration: complete flow testing and polish
5. Apply Godot-specific rules:
   → Scene files = mark [P] for parallel
   → Resource classes = mark [P] for parallel
   → Shared scripts = sequential dependencies
   → TDD mandatory for all game logic
```

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths in Godot project structure

## Path Conventions (Godot 4.5 Project)
- **Scenes**: `scenes/player/`, `scenes/main/`
- **Scripts**: `scripts/autoloads/`, `scripts/data/`, `scripts/player/`
- **Tests**: `tests/unit/`, `tests/integration/`, `tests/contract/`
- **Assets**: `assets/themes/`, `assets/fonts/`

## Phase 3.1: Setup and Project Structure
- [ ] **T001** Create Godot project directories per plan (scenes/player/, scripts/autoloads/, scripts/data/, scripts/player/, scripts/ui/, tests/)
- [ ] **T002** Configure GUT testing framework in project settings and enable plugin
- [ ] **T003** [P] Create player creation theme resource at assets/themes/player_creation_theme.tres
- [ ] **T004** [P] Add SceneManager to project autoloads in project settings

## Phase 3.2: Contract Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.3
**CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation**
- [ ] **T005** [P] Contract test SceneManagerInterface in tests/contract/test_scene_manager_interface.gd
- [ ] **T006** [P] Contract test CharacterCreationInterface in tests/contract/test_character_creation_interface.gd
- [ ] **T007** [P] Contract test MediaInterviewInterface in tests/contract/test_media_interview_interface.gd

## Phase 3.3: Data Models (ONLY after contract tests failing)
- [ ] **T008** [P] PlayerData Resource class in scripts/data/PlayerData.gd
- [ ] **T009** [P] CharacterData Resource class in scripts/data/CharacterData.gd
- [ ] **T010** [P] PartyData Resource class in scripts/data/PartyData.gd
- [ ] **T011** [P] InterviewResponse Resource class in scripts/data/InterviewResponse.gd

## Phase 3.4: Core Services Implementation
- [ ] **T012** SceneManager autoload implementation in scripts/autoloads/SceneManager.gd
- [ ] **T013** Save/Load system with user:// directory support in scripts/data/SaveSystem.gd

## Phase 3.5: Scene Implementations
- [ ] **T014** [P] CharacterPartySelection scene at scenes/player/CharacterPartySelection.tscn
- [ ] **T015** [P] CharacterPartySelection script at scripts/player/CharacterPartySelection.gd
- [ ] **T016** [P] CharacterPartyCreation scene at scenes/player/CharacterPartyCreation.tscn
- [ ] **T017** [P] CharacterPartyCreation script at scripts/player/CharacterPartyCreation.gd
- [ ] **T018** [P] MediaInterview scene at scenes/player/MediaInterview.tscn
- [ ] **T019** [P] MediaInterview script at scripts/player/MediaInterview.gd

## Phase 3.6: UI Components and Integration
- [ ] **T020** [P] Color picker integration for party creation in scripts/ui/ColorPickerManager.gd
- [ ] **T021** [P] Logo selection system in scripts/ui/LogoSelector.gd
- [ ] **T022** Modify MainMenu scene to add Load Game button with state management at scenes/main/MainMenu.tscn

## Phase 3.7: Interview System Implementation
- [ ] **T023** Question generation algorithm in scripts/player/InterviewQuestionGenerator.gd
- [ ] **T024** Multiple choice answer system integration in MediaInterview script
- [ ] **T025** Interview completion flow and data compilation in MediaInterview script

## Phase 3.8: Integration Tests and Polish
- [ ] **T026** [P] Complete player creation flow integration test in tests/integration/test_complete_player_flow.gd
- [ ] **T027** [P] Save/load system integration test in tests/integration/test_save_load_system.gd
- [ ] **T028** [P] Scene transition integration test in tests/integration/test_scene_transitions.gd
- [ ] **T029** Performance validation for 60 FPS requirement and <100ms scene transitions
- [ ] **T030** UI consistency validation and theme application across all scenes
- [ ] **T031** Manual testing using quickstart.md validation scenarios

## Dependencies
- Setup (T001-T004) before all other phases
- Contract tests (T005-T007) before implementation (T008-T031)
- Data models (T008-T011) before services (T012-T013)
- Services (T012-T013) before scenes (T014-T019)
- Scenes (T014-T019) before UI components (T020-T022)
- Core implementation complete before interview system (T023-T025)
- All implementation before integration tests (T026-T031)

## Parallel Execution Examples
```bash
# Launch contract tests together (T005-T007):
Task: "Contract test SceneManagerInterface in tests/contract/test_scene_manager_interface.gd"
Task: "Contract test CharacterCreationInterface in tests/contract/test_character_creation_interface.gd"
Task: "Contract test MediaInterviewInterface in tests/contract/test_media_interview_interface.gd"

# Launch data model creation together (T008-T011):
Task: "PlayerData Resource class in scripts/data/PlayerData.gd"
Task: "CharacterData Resource class in scripts/data/CharacterData.gd"
Task: "PartyData Resource class in scripts/data/PartyData.gd"
Task: "InterviewResponse Resource class in scripts/data/InterviewResponse.gd"

# Launch scene creation together (T014, T016, T018):
Task: "CharacterPartySelection scene at scenes/player/CharacterPartySelection.tscn"
Task: "CharacterPartyCreation scene at scenes/player/CharacterPartyCreation.tscn"
Task: "MediaInterview scene at scenes/player/MediaInterview.tscn"

# Launch integration tests together (T026-T028):
Task: "Complete player creation flow integration test in tests/integration/test_complete_player_flow.gd"
Task: "Save/load system integration test in tests/integration/test_save_load_system.gd"
Task: "Scene transition integration test in tests/integration/test_scene_transitions.gd"
```

## Constitutional Compliance Requirements
Each task must maintain compliance with Coalition 150's 6 constitutional principles:

1. **Scene-First Architecture**: All scenes (T014, T016, T018) must be modular with clear responsibilities
2. **GDScript Standards**: All scripts must use explicit typing, snake_case/PascalCase conventions, <20 line functions
3. **Test-Driven Development**: Contract tests (T005-T007) MUST fail before any implementation begins
4. **Performance-First Design**: Tasks T029 validates 60 FPS and <100ms scene loading requirements
5. **UI Consistency**: Task T030 ensures theme system integration and consistent styling
6. **Documentation-First Development**: Use Context7 MCP consultation before implementing new Godot API patterns

## Notes
- [P] tasks target different files with no shared dependencies
- All GDScript files must include explicit typing and follow Godot 4.5 conventions
- Contract tests must fail initially to prove TDD methodology
- Scene files (.tscn) and script files (.gd) can be developed in parallel when targeting different scenes
- Save system uses Godot's `user://` directory for cross-platform compatibility
- Interview questions dynamically generated based on character profile data
- All UI components must integrate with the established theme system

## Task Generation Rules Applied
1. **From Contracts**: 3 contract files → 3 contract test tasks [P] (T005-T007)
2. **From Data Model**: 4 entities → 4 model creation tasks [P] (T008-T011)
3. **From User Stories**: 3 stories → 3 integration tests [P] (T026-T028)
4. **From Requirements**: Scene creation, UI components, interview system
5. **Ordering**: Setup → Tests → Models → Services → Scenes → UI → Interview → Integration

## Validation Checklist
- [x] All 3 contracts have corresponding tests (T005-T007)
- [x] All 4 entities have model tasks (T008-T011)
- [x] All tests come before implementation (T005-T007 before T008+)
- [x] Parallel tasks truly independent (different files, no shared dependencies)
- [x] Each task specifies exact Godot file path
- [x] No [P] task modifies same file as another [P] task
- [x] TDD methodology enforced with failing tests first
- [x] Constitutional compliance requirements integrated
- [x] 31 total tasks covering complete implementation scope