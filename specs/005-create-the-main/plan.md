
# Implementation Plan: Main Game Dashboard

**Branch**: `005-create-the-main` | **Date**: 2025-09-26 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/005-create-the-main/spec.md`

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
Central dashboard for political party leadership game with four key stats display, interactive Netherlands map for regional campaign management, bill voting system, event calendar, and news feed with comprehensive response options. Implementation uses Godot 4.5 with scene-based architecture, time management system, and signal-based UI interactions.

## Technical Context
**Language/Version**: GDScript 2.0 (Godot 4.5)
**Primary Dependencies**: Godot 4.5 engine, GUT (Godot Unit Test) framework
**Storage**: Godot Resource files (.tres), local filesystem (user:// directory)
**Testing**: GUT (Godot Unit Test) framework for unit and integration tests
**Target Platform**: Desktop (Windows, macOS, Linux)
**Project Type**: single (Godot game project)
**Performance Goals**: 60 FPS target, smooth UI interactions, responsive time controls
**Constraints**: Scene-based modular architecture, signal-driven communication, TDD required
**Scale/Scope**: Single-player political simulation, comprehensive dashboard interface

**Implementation Details**: Dashboard implemented as main Godot scene with UI components: Label nodes for stats display, Polygon2D nodes for Netherlands map provinces (from SVG data), ScrollContainer for bills/news with custom scene instances, global TimeManager autoload for time progression, DashboardManager script for centralized control via signals.

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**I. Scene-First Architecture**: ✅ PASS
- Dashboard implemented as main scene with modular UI components
- Clear separation: UI scenes for presentation, logic scripts for behavior
- Signal-based communication prevents tight coupling

**II. GDScript Standards**: ✅ PASS
- Will follow official GDScript style guide (snake_case, PascalCase)
- Explicit typing required for all variables and functions
- Functions limited to 20 lines maximum

**III. Test-Driven Development**: ✅ PASS
- GUT framework specified for testing
- TDD cycle: Tests → Fail → Implement required
- 80% code coverage target for simulation logic

**IV. Performance-First Design**: ✅ PASS
- 60 FPS target specified in performance goals
- Godot profiler usage planned for performance measurement
- Scene loading considerations for complex UI

**V. UI Consistency**: ✅ PASS
- Comprehensive design system needed for dashboard elements
- Godot theme system will ensure consistent styling
- All interactive elements will have proper states

**VI. Documentation-First Development**: ✅ PASS
- Context7 MCP usage planned for Godot 4.5 documentation
- Official patterns verification required before implementation
- Research phase will consult latest Godot documentation

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
# Godot Game Project Structure
scenes/
├── dashboard/
│   ├── main_dashboard.tscn
│   └── components/
│       ├── stats_panel.tscn
│       ├── netherlands_map.tscn
│       ├── bills_list.tscn
│       ├── news_feed.tscn
│       └── calendar.tscn

scripts/
├── resources/           # Resource class definitions
├── autoloads/          # Global systems (TimeManager, GameState)
├── managers/           # Game logic managers
└── dashboard/
    └── components/     # UI component scripts

resources/
├── data/               # Game data (.tres files)
├── ui/                 # Themes and UI resources
└── maps/               # Netherlands SVG map

tests/
├── unit/               # GUT unit tests
├── integration/        # Scene interaction tests
├── performance/        # Performance validation
└── acceptance/         # User scenario tests
```

**Structure Decision**: Godot project structure with scenes/, scripts/, resources/, and tests/ directories organized by feature and system responsibility

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
- Each resource class → model creation + test tasks [P]
- Each interface contract → implementation + test tasks [P]
- Each UI component → scene creation + script + test tasks
- Integration tasks for dashboard assembly
- SVG map conversion and province setup tasks
- Time management system implementation tasks

**Ordering Strategy**:
- **Phase 1**: Resource classes and data models (parallel)
- **Phase 2**: Autoload systems (TimeManager, GameState) with tests
- **Phase 3**: UI components and scenes (parallel where possible)
- **Phase 4**: Dashboard integration and signal connections
- **Phase 5**: Map implementation and province interaction
- **Phase 6**: Integration testing and performance validation

**Task Categories**:
- **Data Models**: GameState, RegionalData, ParliamentaryBill, etc. [P]
- **Core Systems**: TimeManager, DashboardManager, RegionalManager [P]
- **UI Components**: StatsPanel, BillsList, NewsFeed, Calendar [P]
- **Map System**: SVG conversion, province polygons, interactions
- **Integration**: Signal connections, scene assembly, testing
- **Validation**: User acceptance tests, performance tests

**Estimated Output**: 35-40 numbered, dependency-ordered tasks in tasks.md

**TDD Implementation**: Each implementation task has corresponding test task that must be written first and must fail before implementation begins (per Constitution III).

**IMPORTANT**: This phase is executed by the /tasks command, NOT by /plan

## Phase 3+: Future Implementation
*These phases are beyond the scope of the /plan command*

**Phase 3**: Task execution (/tasks command creates tasks.md)  
**Phase 4**: Implementation (execute tasks.md following constitutional principles)  
**Phase 5**: Validation (run tests, execute quickstart.md, performance validation)

## Complexity Tracking
*Fill ONLY if Constitution Check has violations that must be justified*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |


## Progress Tracking
*This checklist is updated during execution flow*

**Phase Status**:
- [x] Phase 0: Research complete (/plan command)
- [x] Phase 1: Design complete (/plan command)
- [x] Phase 2: Task planning complete (/plan command - describe approach only)
- [ ] Phase 3: Tasks generated (/tasks command)
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:
- [x] Initial Constitution Check: PASS
- [x] Post-Design Constitution Check: PASS
- [x] All NEEDS CLARIFICATION resolved
- [ ] Complexity deviations documented

---
*Based on Constitution v1.1.0 - See `/memory/constitution.md`*
