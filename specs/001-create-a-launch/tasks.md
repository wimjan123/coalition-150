# Tasks: Coalition 150 Launch Screen

**Input**: Design documents from `/specs/001-create-a-launch/`
**Prerequisites**: plan.md (required), research.md, data-model.md, contracts/

## Execution Flow (main)
```
1. Load plan.md from feature directory
   → Tech stack: GDScript in Godot 4.5, Control-based UI, signal-driven architecture
2. Load design documents:
   → data-model.md: LoadingState, AssetItem, LaunchScreenState, TransitionConfig entities
   → contracts/: LaunchScreenInterface, AssetLoaderInterface, SceneManagerInterface
   → research.md: Control-based UI, Signal communication, Tween transitions, GUT testing
3. Generate tasks by category:
   → Setup: Godot project structure, GUT framework, UI theme resources
   → Tests: Contract tests for interfaces, integration tests for loading flow
   → Core: Data model classes, interface implementations, scene files
   → Integration: Signal connections, scene transitions, autoload services
   → Polish: Performance validation, quickstart execution, documentation
4. Apply Godot-specific task rules:
   → Different .tscn/.gd files = mark [P] for parallel
   → Same file modifications = sequential (no [P])
   → GUT tests before GDScript implementation (TDD)
5. Number tasks sequentially (T001, T002...)
6. Generate dependency graph for Godot scene hierarchy
7. Create parallel execution examples with Task agent commands
8. Validate task completeness against contracts and data model
9. Return: SUCCESS (tasks ready for Godot implementation)
```

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different .tscn/.gd files, no dependencies)
- Include exact file paths for Godot project structure

## Path Conventions
- **Godot Project**: Root contains `project.godot`, scenes/, scripts/, assets/
- **Scenes**: `scenes/launch/`, `scenes/ui/`, `scenes/main/`
- **Scripts**: `scripts/autoloads/`, `scripts/utilities/`
- **Tests**: `tests/unit/`, `tests/integration/`

## Phase 3.1: Setup & Configuration
- [X] T001 Create Godot project structure with scenes/, scripts/, assets/, tests/ directories
- [X] T002 [P] Configure project.godot with autoloads for GameManager and SceneManager
- [X] T003 [P] Install and configure GUT testing framework in project
- [X] T004 [P] Create UI theme resource file at assets/themes/ui_theme.tres with consistent styling

## Phase 3.2: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.3
**CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation**
- [X] T005 [P] Contract test LaunchScreenInterface in tests/unit/test_launch_screen_interface.gd
- [X] T006 [P] Contract test AssetLoaderInterface in tests/unit/test_asset_loader_interface.gd
- [X] T007 [P] Contract test SceneManagerInterface in tests/unit/test_scene_manager_interface.gd
- [X] T008 [P] Unit test LoadingState data model in tests/unit/test_loading_state.gd
- [X] T009 [P] Unit test AssetItem data model in tests/unit/test_asset_item.gd
- [X] T010 [P] Unit test LaunchScreenState data model in tests/unit/test_launch_screen_state.gd
- [X] T011 [P] Unit test TransitionConfig data model in tests/unit/test_transition_config.gd
- [X] T012 [P] Integration test complete launch flow in tests/integration/test_launch_to_menu.gd

## Phase 3.3: Core Data Models (ONLY after tests are failing)
- [X] T013 [P] LoadingState class in scripts/data/LoadingState.gd with validation rules
- [X] T014 [P] AssetItem class in scripts/data/AssetItem.gd with type enumeration
- [X] T015 [P] LaunchScreenState class in scripts/data/LaunchScreenState.gd with state transitions
- [X] T016 [P] TransitionConfig class in scripts/data/TransitionConfig.gd with fade settings

## Phase 3.4: Core Services Implementation
- [X] T017 AssetLoader service in scripts/utilities/AssetLoader.gd implementing AssetLoaderInterface
- [X] T018 SceneManager autoload in scripts/autoloads/SceneManager.gd implementing SceneManagerInterface
- [X] T019 GameManager autoload in scripts/autoloads/GameManager.gd for global state management

## Phase 3.5: Scene Creation
- [X] T020 [P] Create LaunchScreen.tscn scene with Control root, ColorRect background, Label title, ProgressBar
- [X] T021 [P] Create ProgressBar.tscn reusable UI component with theme styling
- [X] T022 [P] Create FadeTransition.tscn overlay scene for screen transitions
- [X] T023 [P] Create MainMenu.tscn placeholder scene for transition target

## Phase 3.6: Scene Scripts Implementation
- [X] T024 LaunchScreen.gd script implementing LaunchScreenInterface with signal connections
- [X] T025 [P] ProgressBar.gd script for custom progress bar behavior and styling
- [X] T026 [P] FadeTransition.gd script for Tween-based fade effects

## Phase 3.7: Integration & Wiring
- [X] T027 Connect AssetLoader signals to LaunchScreen progress updates
- [X] T028 Connect LaunchScreen transition signals to SceneManager
- [X] T029 Configure timeout Timer and retry mechanism in LaunchScreen
- [X] T030 Set up MainMenu scene as transition target in SceneManager

## Phase 3.8: Polish & Validation
- [X] T031 [P] Performance validation: Ensure 60 FPS and <100ms scene loading
- [X] T032 [P] Execute quickstart.md validation steps and verify all requirements
- [X] T033 [P] Godot profiler integration to validate constitution performance requirements
- [X] T034 [P] Error handling validation: Test timeout, retry, and failure scenarios
- [X] T035 [P] UI consistency validation: Theme application and accessibility features

## Dependencies
- Setup tasks (T001-T004) before all other tasks
- Tests (T005-T012) before implementation (T013-T026)
- Data models (T013-T016) before services (T017-T019)
- Services (T017-T019) before scenes (T020-T023)
- Scenes (T020-T023) before scene scripts (T024-T026)
- Core implementation before integration (T027-T030)
- Integration complete before polish (T031-T035)

## Parallel Execution Examples
```
# Launch Phase 3.2 tests together (all different files):
Task: "Contract test LaunchScreenInterface in tests/unit/test_launch_screen_interface.gd"
Task: "Contract test AssetLoaderInterface in tests/unit/test_asset_loader_interface.gd"
Task: "Contract test SceneManagerInterface in tests/unit/test_scene_manager_interface.gd"
Task: "Unit test LoadingState data model in tests/unit/test_loading_state.gd"

# Launch Phase 3.3 data models together:
Task: "LoadingState class in scripts/data/LoadingState.gd with validation rules"
Task: "AssetItem class in scripts/data/AssetItem.gd with type enumeration"
Task: "LaunchScreenState class in scripts/data/LaunchScreenState.gd with state transitions"
Task: "TransitionConfig class in scripts/data/TransitionConfig.gd with fade settings"

# Launch Phase 3.5 scenes together:
Task: "Create LaunchScreen.tscn scene with Control root, ColorRect background, Label title, ProgressBar"
Task: "Create ProgressBar.tscn reusable UI component with theme styling"
Task: "Create FadeTransition.tscn overlay scene for screen transitions"
Task: "Create MainMenu.tscn placeholder scene for transition target"
```

## Notes
- [P] tasks = different .tscn/.gd files, no dependencies
- Verify GUT tests fail before implementing corresponding classes/scenes
- All scenes must use ui_theme.tres for consistent styling
- Commit after completing each phase
- Follow GDScript naming conventions: snake_case for methods, PascalCase for classes

## Godot-Specific Validation Rules
1. **Scene Structure**: LaunchScreen.tscn must contain Background, TitleLabel, ProgressBar, LoadingTimer, FadeOverlay nodes
2. **Signal Connections**: All interface signals properly connected in _ready() methods
3. **Theme Application**: UI theme consistently applied across all Control nodes
4. **Performance**: Godot profiler confirms 60 FPS during loading and transitions
5. **TDD Compliance**: All GUT tests written first and failing before implementation

## Task Generation Rules Applied
- Each contract file → contract test task [P] (T005-T007)
- Each data model entity → model creation task [P] (T013-T016)
- Each interface → implementation task (T017-T019, T024-T026)
- Each scene requirement → scene creation task [P] (T020-T023)
- Complete launch flow → integration test [P] (T012)
- Different files marked [P] for parallel execution
- Sequential dependencies respected (tests → models → services → scenes → scripts)

## Validation Checklist
*GATE: Checked before task execution*

- [x] All contract interfaces have corresponding tests (LaunchScreen, AssetLoader, SceneManager)
- [x] All data model entities have model tasks (LoadingState, AssetItem, LaunchScreenState, TransitionConfig)
- [x] All tests come before implementation (TDD order)
- [x] Parallel tasks truly independent (different .tscn/.gd files)
- [x] Each task specifies exact Godot file path
- [x] No task modifies same file as another [P] task
- [x] Godot project structure follows research.md architecture decisions
- [x] GUT testing framework integration planned for TDD compliance