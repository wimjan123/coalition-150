# Tasks: Main Game Dashboard

**Input**: Design documents from `/specs/005-create-the-main/`
**Prerequisites**: plan.md (required), research.md, data-model.md, contracts/

## Execution Flow (main)
```
1. Load plan.md from feature directory
   → Extract: GDScript 2.0 (Godot 4.5), GUT framework, scene-based architecture
2. Load optional design documents:
   → data-model.md: GameState, RegionalData, ParliamentaryBill, etc.
   → contracts/: dashboard_interface.gd, time_manager_interface.gd, regional_manager_interface.gd
   → research.md: SVG map source, UI patterns, performance targets
3. Generate tasks by category:
   → Setup: project structure, GUT testing framework, SVG map resources
   → Tests: contract tests, integration tests (TDD required)
   → Core: resource classes, autoload systems, UI components
   → Integration: scene assembly, signal connections, map implementation
   → Polish: performance validation, user acceptance tests
4. Apply task rules per TDD requirements
5. Number tasks sequentially (T001, T002...)
6. Generate dependency graph with parallel execution opportunities
```

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- File paths assume Godot project structure in repository root

## Phase 3.1: Setup

- [ ] T001 Set up GUT (Godot Unit Test) framework in project
- [ ] T002 Create Godot project structure with scenes/, scripts/, resources/, tests/ directories
- [ ] T003 [P] Download and prepare Netherlands provinces SVG map from SimpleMaps (research.md source)
- [ ] T004 [P] Create project.godot autoload entries for TimeManager and GameState
- [ ] T005 [P] Set up basic theme resource in resources/ui/dashboard_theme.tres

## Phase 3.2: Resource Models First (TDD) ⚠️ MUST COMPLETE BEFORE 3.3

**CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation**

- [ ] T006 [P] Test GameState resource in tests/unit/test_game_state.gd
- [ ] T007 [P] Test GameDate resource and time utilities in tests/unit/test_game_date.gd
- [ ] T008 [P] Test RegionalData resource in tests/unit/test_regional_data.gd
- [ ] T009 [P] Test Candidate resource in tests/unit/test_candidate.gd
- [ ] T010 [P] Test ParliamentaryBill resource in tests/unit/test_parliamentary_bill.gd
- [ ] T011 [P] Test CalendarEvent resource in tests/unit/test_calendar_event.gd
- [ ] T012 [P] Test NewsItem resource in tests/unit/test_news_item.gd
- [ ] T013 [P] Test Character resource in tests/unit/test_character.gd

## Phase 3.3: Resource Implementation (ONLY after tests are failing)

- [ ] T014 [P] GameState resource class in scripts/resources/game_state.gd
- [ ] T015 [P] GameDate resource class in scripts/resources/game_date.gd
- [ ] T016 [P] RegionalData resource class in scripts/resources/regional_data.gd
- [ ] T017 [P] Candidate resource class in scripts/resources/candidate.gd
- [ ] T018 [P] ParliamentaryBill resource class in scripts/resources/parliamentary_bill.gd
- [ ] T019 [P] CalendarEvent resource class in scripts/resources/calendar_event.gd
- [ ] T020 [P] NewsItem and ResponseOption resources in scripts/resources/news_item.gd
- [ ] T021 [P] Character and Interaction resources in scripts/resources/character.gd
- [ ] T022 [P] All enums (TimeSpeed, BillPosition, EventType, etc.) in scripts/resources/game_enums.gd

## Phase 3.4: Autoload Systems (TDD)

- [ ] T023 Test TimeManager autoload interface in tests/unit/test_time_manager.gd
- [ ] T024 Test GameState persistence in tests/unit/test_game_state_persistence.gd
- [ ] T025 TimeManager autoload implementation in scripts/autoloads/time_manager.gd
- [ ] T026 GameState autoload implementation in scripts/autoloads/game_state.gd

## Phase 3.5: Manager Interface Tests (TDD)

- [ ] T027 [P] Test DashboardManager interface in tests/unit/test_dashboard_manager.gd
- [ ] T028 [P] Test RegionalManager interface in tests/unit/test_regional_manager.gd
- [ ] T029 [P] Integration test for manager signal communication in tests/integration/test_manager_signals.gd

## Phase 3.6: Manager Implementation

- [ ] T030 DashboardManager implementation in scripts/managers/dashboard_manager.gd
- [ ] T031 RegionalManager implementation in scripts/managers/regional_manager.gd
- [ ] T032 Connect managers to autoload systems and signal routing

## Phase 3.7: UI Component Tests (TDD)

- [ ] T033 [P] Test StatsPanel component in tests/unit/test_stats_panel.gd
- [ ] T034 [P] Test BillsList component in tests/unit/test_bills_list.gd
- [ ] T035 [P] Test NewsFeed component in tests/unit/test_news_feed.gd
- [ ] T036 [P] Test Calendar component in tests/unit/test_calendar.gd
- [ ] T037 [P] Test NetherlandsMap component in tests/unit/test_netherlands_map.gd

## Phase 3.8: UI Components and Scenes

- [ ] T038 [P] StatsPanel scene and script in scenes/dashboard/components/stats_panel.tscn + scripts/dashboard/components/stats_panel.gd
- [ ] T039 [P] BillsList scene with ScrollContainer in scenes/dashboard/components/bills_list.tscn + scripts/dashboard/components/bills_list.gd
- [ ] T040 [P] NewsFeed scene with ScrollContainer in scenes/dashboard/components/news_feed.tscn + scripts/dashboard/components/news_feed.gd
- [ ] T041 [P] Calendar scene and interface in scenes/dashboard/components/calendar.tscn + scripts/dashboard/components/calendar.gd
- [ ] T042 Convert SVG map to Polygon2D provinces in scenes/dashboard/components/netherlands_map.tscn
- [ ] T043 NetherlandsMap interaction script in scripts/dashboard/components/netherlands_map.gd

## Phase 3.9: Dashboard Integration

- [ ] T044 MainDashboard scene layout with all components in scenes/dashboard/main_dashboard.tscn
- [ ] T045 MainDashboard controller script connecting all components in scripts/dashboard/main_dashboard.gd
- [ ] T046 Connect time controls (pause, speed buttons) to TimeManager
- [ ] T047 Implement signal routing between components and managers

## Phase 3.10: Integration Testing

- [ ] T048 [P] Integration test dashboard scene loading in tests/integration/test_dashboard_scene_loading.gd
- [ ] T049 [P] Integration test time management flow in tests/integration/test_time_management_flow.gd
- [ ] T050 [P] Integration test regional campaign management in tests/integration/test_regional_campaign_flow.gd
- [ ] T051 [P] Integration test bill voting system in tests/integration/test_bill_voting_flow.gd
- [ ] T052 [P] Integration test news response system in tests/integration/test_news_response_flow.gd

## Phase 3.11: Data and Content

- [ ] T053 [P] Create sample game state data in resources/data/initial_game_state.tres
- [ ] T054 [P] Create sample regional data for 12 Netherlands provinces in resources/data/provinces/
- [ ] T055 [P] Create sample parliamentary bills in resources/data/sample_bills.tres
- [ ] T056 [P] Create sample news items in resources/data/sample_news.tres
- [ ] T057 [P] Create sample characters and relationships in resources/data/sample_characters.tres

## Phase 3.12: Polish and Validation

- [ ] T058 [P] Performance validation test (60 FPS, <50MB memory) in tests/performance/test_dashboard_performance.gd
- [ ] T059 [P] User acceptance test scenarios from quickstart.md in tests/acceptance/test_user_scenarios.gd
- [ ] T060 [P] Theme consistency validation across all UI components
- [ ] T061 [P] Signal connection validation and error handling
- [ ] T062 [P] Save/load game state validation test in tests/integration/test_save_load.gd

## Dependencies

**Critical Dependencies (Must Complete First):**
- Setup (T001-T005) before everything else
- Resource tests (T006-T013) before resource implementation (T014-T022)
- Autoload tests (T023-T024) before autoload implementation (T025-T026)
- Manager tests (T027-T029) before manager implementation (T030-T032)
- Component tests (T033-T037) before component implementation (T038-T043)

**Sequential Dependencies:**
- T025 (TimeManager) blocks T046 (time controls)
- T030 (DashboardManager) blocks T045 (MainDashboard controller)
- T042-T043 (map components) blocks T050 (regional campaign integration test)
- T038-T041 (UI components) blocks T044 (MainDashboard scene)
- T044-T047 (dashboard integration) blocks T048-T052 (integration tests)

**Data Dependencies:**
- T053-T057 (sample data) can run after T014-T022 (resource classes)
- T058-T062 (validation) must be last, after all implementation complete

## Parallel Execution Examples

**Phase 3.2 - Resource Tests (All Parallel):**
```bash
# Launch T006-T013 together:
Task: "Test GameState resource in tests/unit/test_game_state.gd"
Task: "Test GameDate resource in tests/unit/test_game_date.gd"
Task: "Test RegionalData resource in tests/unit/test_regional_data.gd"
Task: "Test Candidate resource in tests/unit/test_candidate.gd"
Task: "Test ParliamentaryBill resource in tests/unit/test_parliamentary_bill.gd"
Task: "Test CalendarEvent resource in tests/unit/test_calendar_event.gd"
Task: "Test NewsItem resource in tests/unit/test_news_item.gd"
Task: "Test Character resource in tests/unit/test_character.gd"
```

**Phase 3.3 - Resource Implementation (All Parallel):**
```bash
# Launch T014-T022 together after tests are failing:
Task: "GameState resource class in scripts/resources/game_state.gd"
Task: "GameDate resource class in scripts/resources/game_date.gd"
Task: "RegionalData resource class in scripts/resources/regional_data.gd"
Task: "Candidate resource class in scripts/resources/candidate.gd"
Task: "ParliamentaryBill resource class in scripts/resources/parliamentary_bill.gd"
Task: "CalendarEvent resource class in scripts/resources/calendar_event.gd"
Task: "NewsItem resource class in scripts/resources/news_item.gd"
Task: "Character resource class in scripts/resources/character.gd"
Task: "All enums in scripts/resources/game_enums.gd"
```

**Phase 3.8 - UI Components (All Parallel):**
```bash
# Launch T038-T041 together:
Task: "StatsPanel scene and script in scenes/dashboard/components/stats_panel.tscn + scripts/dashboard/components/stats_panel.gd"
Task: "BillsList scene in scenes/dashboard/components/bills_list.tscn + scripts/dashboard/components/bills_list.gd"
Task: "NewsFeed scene in scenes/dashboard/components/news_feed.tscn + scripts/dashboard/components/news_feed.gd"
Task: "Calendar scene in scenes/dashboard/components/calendar.tscn + scripts/dashboard/components/calendar.gd"
```

## Notes

- **[P] tasks** = different files, no dependencies, can run in parallel
- **TDD Compliance**: All tests MUST be written first and MUST fail before implementation
- **Performance**: Target 60 FPS, <500ms scene load, <50ms map interaction
- **Architecture**: Scene-first with signal-based communication per constitution
- **Testing**: GUT framework with 80% code coverage requirement
- **Godot Version**: 4.5 stable with GDScript 2.0 explicit typing

## Task Generation Rules Applied

1. **From Contracts**: 3 interface files → 3 contract test tasks + 3 implementation tasks
2. **From Data Model**: 8 resource classes → 8 test tasks + 8 implementation tasks [P]
3. **From UI Requirements**: 5 components → 5 test tasks + 5 scene/script tasks [P]
4. **From User Stories**: Primary scenarios → 6 integration test tasks [P]
5. **From Architecture**: Autoload systems, managers, main scene integration
6. **Ordering**: Setup → Tests → Models → Systems → UI → Integration → Polish

## Validation Checklist

- [x] All contracts have corresponding tests (T027-T029)
- [x] All resource entities have model tasks (T006-T022)
- [x] All tests come before implementation (TDD phases)
- [x] Parallel tasks are truly independent (different files, no shared state)
- [x] Each task specifies exact file path
- [x] No task modifies same file as another [P] task
- [x] Dependencies clearly mapped and enforced