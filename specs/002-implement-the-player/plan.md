
# Implementation Plan: Player and Party Creation Flow

**Branch**: `002-implement-the-player` | **Date**: 2025-01-25 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/002-implement-the-player/spec.md`

## Execution Flow (/plan command scope)
```
1. Load feature spec from Input path
   → If not found: ERROR "No feature spec at {path}"
2. Fill Technical Context (scan for NEEDS CLARIFICATION)
   → Detect Project Type from context (web=frontend+backend, mobile=app+api)
   → Set Structure Decision based on project type
3. Fill the Constitution Check section based on the content of the constitution document.
4. Evaluate Constitution Check section below
   → If violations exist: Document in Complexity Tracking
   → If no justification possible: ERROR "Simplify approach first"
   → Update Progress Tracking: Initial Constitution Check
5. Execute Phase 0 → research.md
   → If NEEDS CLARIFICATION remain: ERROR "Resolve unknowns"
6. Execute Phase 1 → contracts, data-model.md, quickstart.md, agent-specific template file (e.g., `CLAUDE.md` for Claude Code, `.github/copilot-instructions.md` for GitHub Copilot, `GEMINI.md` for Gemini CLI, `QWEN.md` for Qwen Code or `AGENTS.md` for opencode).
7. Re-evaluate Constitution Check section
   → If new violations: Refactor design, return to Phase 1
   → Update Progress Tracking: Post-Design Constitution Check
8. Plan Phase 2 → Describe task generation approach (DO NOT create tasks.md)
9. STOP - Ready for /tasks command
```

**IMPORTANT**: The /plan command STOPS at step 7. Phases 2-4 are executed by other commands:
- Phase 2: /tasks command creates tasks.md
- Phase 3-4: Implementation execution (manual or via tools)

## Summary
Implement a comprehensive player and party creation flow for Coalition 150, a single-player political campaign game against AI opponents. The feature includes three new Godot scenes (character/party selection, creation form, interview), custom Godot Resources for data persistence, global SceneManager for transitions, and a media interview system with dynamically generated questions based on character profiles.

## Technical Context
**Language/Version**: GDScript 2.0 (Godot 4.5)
**Primary Dependencies**: Godot 4.5, GUT (Godot Unit Test) framework
**Storage**: Godot Resource files (.tres) for save data, local filesystem
**Testing**: GUT framework for unit and integration tests
**Target Platform**: Desktop (Windows/macOS/Linux)
**Project Type**: Single game project - Godot structure
**Performance Goals**: 60 FPS, <100ms scene transitions, <16ms UI responsiveness
**Constraints**: <100MB memory, offline single-player game
**Scale/Scope**: 3 new scenes, ~15 new scripts, custom Resource classes, save/load system

**Implementation Details from User**:
- Three new Godot scenes: character/party selection, creation form, media interview
- Custom Godot Resources for player and party data persistence
- Main menu 'Load Game' button disabled until save file exists
- Global SceneManager autoload for scene transitions
- Interview UI with labels for questions and buttons for multiple-choice answers
- Use Context7 MCP for latest Godot 4.5 documentation

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**I. Scene-First Architecture**: ✅ PASS
- Three modular scenes (selection, creation, interview) with clear responsibilities
- UI scenes handle presentation, logic scenes handle behavior
- Scene transitions via signals and SceneManager autoload (event bus pattern)

**II. GDScript Standards**: ✅ PASS
- Will follow Godot's official style guide with snake_case/PascalCase conventions
- Explicit typing required for all variables and functions
- @export variables with proper documentation
- Functions limited to 20 lines maximum

**III. Test-Driven Development**: ✅ PASS
- GUT framework for unit and integration tests
- Red-Green-Refactor cycle with failing tests first
- Target 80% code coverage for game logic

**IV. Performance-First Design**: ✅ PASS
- Target 60 FPS on modest hardware
- Scene loading <100ms (simple UI scenes)
- Resource pooling for UI elements
- Profiling planned using Godot's profiler

**V. UI Consistency**: ✅ PASS
- Will establish design system with reusable components
- Godot theme system for consistent styling
- All interactive elements with hover/focus/disabled states
- 60 FPS UI animations with accessibility support

**VI. Documentation-First Development**: ✅ PASS
- Context7 MCP consultation for latest Godot 4.5 documentation
- Will verify official patterns before implementation
- Documentation consultation before any new Godot API usage

**No constitutional violations detected - proceeding to Phase 0**

## Project Structure

### Documentation (this feature)
```
specs/[###-feature]/
├── plan.md              # This file (/plan command output)
├── research.md          # Phase 0 output (/plan command)
├── data-model.md        # Phase 1 output (/plan command)
├── quickstart.md        # Phase 1 output (/plan command)
├── contracts/           # Phase 1 output (/plan command)
└── tasks.md             # Phase 2 output (/tasks command - NOT created by /plan)
```

### Source Code (repository root)
```
# Godot 4.5 Project Structure
scenes/
├── player/
│   ├── CharacterPartySelection.tscn
│   ├── CharacterPartyCreation.tscn
│   └── MediaInterview.tscn
├── main/
│   └── MainMenu.tscn (existing, to be modified)
└── ui/
    └── [shared UI components]

scripts/
├── autoloads/
│   └── SceneManager.gd
├── data/
│   ├── PlayerData.gd (Resource)
│   ├── CharacterData.gd (Resource)
│   └── PartyData.gd (Resource)
├── player/
│   ├── CharacterPartySelection.gd
│   ├── CharacterPartyCreation.gd
│   └── MediaInterview.gd
└── ui/
    └── [shared UI component scripts]

tests/
├── integration/
│   └── test_player_creation_flow.gd
├── unit/
│   ├── test_player_data.gd
│   ├── test_character_data.gd
│   └── test_party_data.gd
└── contract/
    └── test_scene_manager.gd

assets/
├── themes/
│   └── player_creation_theme.tres
└── fonts/
    └── [UI fonts]
```

**Structure Decision**: Godot 4.5 project structure with scene-first architecture

## Phase 0: Outline & Research
1. **Extract unknowns from Technical Context** above:
   - For each NEEDS CLARIFICATION → research task
   - For each dependency → best practices task
   - For each integration → patterns task

2. **Generate and dispatch research agents**:
   ```
   For each unknown in Technical Context:
     Task: "Research {unknown} for {feature context}"
   For each technology choice:
     Task: "Find best practices for {tech} in {domain}"
   ```

3. **Consolidate findings** in `research.md` using format:
   - Decision: [what was chosen]
   - Rationale: [why chosen]
   - Alternatives considered: [what else evaluated]

**Output**: research.md with all NEEDS CLARIFICATION resolved

## Phase 1: Design & Contracts
*Prerequisites: research.md complete*

1. **Extract entities from feature spec** → `data-model.md`:
   - Entity name, fields, relationships
   - Validation rules from requirements
   - State transitions if applicable

2. **Generate API contracts** from functional requirements:
   - For each user action → endpoint
   - Use standard REST/GraphQL patterns
   - Output OpenAPI/GraphQL schema to `/contracts/`

3. **Generate contract tests** from contracts:
   - One test file per endpoint
   - Assert request/response schemas
   - Tests must fail (no implementation yet)

4. **Extract test scenarios** from user stories:
   - Each story → integration test scenario
   - Quickstart test = story validation steps

5. **Update agent file incrementally** (O(1) operation):
   - Run `.specify/scripts/bash/update-agent-context.sh claude`
     **IMPORTANT**: Execute it exactly as specified above. Do not add or remove any arguments.
   - If exists: Add only NEW tech from current plan
   - Preserve manual additions between markers
   - Update recent changes (keep last 3)
   - Keep under 150 lines for token efficiency
   - Output to repository root

**Output**: data-model.md, /contracts/*, failing tests, quickstart.md, agent-specific file

## Phase 2: Task Planning Approach
*This section describes what the /tasks command will do - DO NOT execute during /plan*

**Task Generation Strategy**:
- Load `.specify/templates/tasks-template.md` as base
- Generate tasks from Phase 1 design docs (contracts, data model, quickstart)
- TDD approach: Contract tests → Data model tests → Implementation → Integration tests

**Specific Task Categories**:
1. **Contract Tests** (3 tasks) [P]:
   - SceneManagerInterface test (T001)
   - CharacterCreationInterface test (T002)
   - MediaInterviewInterface test (T003)

2. **Data Model Implementation** (4 tasks) [P]:
   - PlayerData Resource class (T004)
   - CharacterData Resource class (T005)
   - PartyData Resource class (T006)
   - InterviewResponse Resource class (T007)

3. **Core Services** (2 tasks):
   - SceneManager autoload implementation (T008)
   - Save/Load system with user:// directory (T009)

4. **Scene Implementation** (3 tasks) [P]:
   - CharacterPartySelection scene + script (T010)
   - CharacterPartyCreation scene + script (T011)
   - MediaInterview scene + script (T012)

5. **UI Components** (2 tasks) [P]:
   - Color picker integration (T013)
   - Logo selection system (T014)

6. **Main Menu Integration** (1 task):
   - Add Load Game button with state management (T015)

7. **Interview System** (3 tasks):
   - Question generation algorithm (T016)
   - Multiple choice answer system (T017)
   - Interview completion flow (T018)

8. **Integration Tests** (3 tasks):
   - Complete player creation flow test (T019)
   - Save/load system integration test (T020)
   - Scene transition integration test (T021)

**Ordering Strategy**:
- **Phase 1 (T001-T007)**: Contract tests + Data models (parallel execution)
- **Phase 2 (T008-T009)**: Core services (depends on data models)
- **Phase 3 (T010-T015)**: Scene implementations (depends on services)
- **Phase 4 (T016-T018)**: Interview system (depends on scenes)
- **Phase 5 (T019-T021)**: Integration tests (depends on all implementations)

**Constitutional Compliance**:
- TDD mandatory: All tests written before implementation
- GUT framework for all testing
- Scene-first architecture maintained
- Performance targets validated in integration tests

**Estimated Output**: 21 numbered, ordered tasks in tasks.md with clear dependencies

**IMPORTANT**: This phase is executed by the /tasks command, NOT by /plan

## Phase 3+: Future Implementation
*These phases are beyond the scope of the /plan command*

**Phase 3**: Task execution (/tasks command creates tasks.md)  
**Phase 4**: Implementation (execute tasks.md following constitutional principles)  
**Phase 5**: Validation (run tests, execute quickstart.md, performance validation)

## Complexity Tracking
*Fill ONLY if Constitution Check has violations that must be justified*

**No constitutional violations detected**

All design decisions align with the Coalition 150 constitution:
- Scene-First Architecture: ✅ Three modular scenes with clear separation
- GDScript Standards: ✅ Planned compliance with style guide and typing
- Test-Driven Development: ✅ Contract tests before implementation
- Performance-First: ✅ 60 FPS targets and <100ms scene loading
- UI Consistency: ✅ Theme system integration planned
- Documentation-First: ✅ Context7 MCP consultation completed

No complexity deviations require justification.


## Progress Tracking
*This checklist is updated during execution flow*

**Phase Status**:
- [x] Phase 0: Research complete (/plan command) - Context7 consultation complete
- [x] Phase 1: Design complete (/plan command) - Data model, contracts, quickstart created
- [x] Phase 2: Task planning complete (/plan command - describe approach only)
- [ ] Phase 3: Tasks generated (/tasks command)
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:
- [x] Initial Constitution Check: PASS - No violations, all principles align
- [x] Post-Design Constitution Check: PASS - Design maintains constitutional compliance
- [x] All NEEDS CLARIFICATION resolved - Feature specification fully clarified
- [x] Complexity deviations documented - No deviations required

---
*Based on Constitution v2.1.1 - See `/memory/constitution.md`*
