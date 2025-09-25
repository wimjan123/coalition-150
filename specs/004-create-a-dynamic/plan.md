
# Implementation Plan: Dynamic and Branching Interview System

**Branch**: `004-create-a-dynamic` | **Date**: 2025-09-25 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/004-create-a-dynamic/spec.md`

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
Create a dynamic branching interview system that loads questions from an external JSON file, prioritizes questions based on player presets, and enables conditional dialogue paths. The system will use an InterviewManager autoload script for state management and a scene-based UI for presentation, following Godot's scene-first architecture principles.

## Technical Context
**Language/Version**: GDScript 2.0 (Godot 4.5)
**Primary Dependencies**: Godot 4.5 engine, GUT (Godot Unit Test) framework
**Storage**: JSON resource files (interviews.json), Godot Resource files (.tres) for presets
**Testing**: GUT (Godot Unit Test) framework for unit tests, integration tests for scene interactions
**Target Platform**: Multi-platform (Windows, macOS, Linux via Godot engine)
**Project Type**: single (Godot game project - scene-based architecture)
**Performance Goals**: 60 FPS gameplay, <100ms scene transitions, <16ms UI updates
**Constraints**: Scene-first modular architecture, TDD mandatory, explicit typing required
**Scale/Scope**: Single-player simulation game, JSON-driven content, branching narrative system

**Implementation Details**: The interview scene will contain a script responsible for managing the interview flow. It will parse 'res://interviews.json' at runtime into a dictionary for quick lookup. A global autoload script (InterviewManager) will handle filtering initial questions based on player data tags (from character/party presets) and storing the current interview state. When an answer is selected, the InterviewManager will process its effects and then retrieve the *next question* using the 'next_question_id' specified in the chosen answer. The UI will dynamically update the question Label and answer Buttons for each new question. If no 'next_question_id' is provided, the interview will conclude or transition to a default closing sequence.

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**I. Scene-First Architecture**: ✅ PASS - Interview system designed as self-contained scene with InterviewManager autoload
**II. GDScript Standards**: ✅ PASS - Will follow snake_case, explicit typing, <20 line functions per constitution
**III. Test-Driven Development**: ✅ PASS - GUT framework specified, TDD cycle mandatory per constitution
**IV. Performance-First Design**: ✅ PASS - 60 FPS target specified, JSON parsing optimized for runtime lookup
**V. UI Consistency**: ✅ PASS - Dynamic UI updates using Godot's Label/Button controls with consistent theming
**VI. Documentation-First Development**: ✅ PASS - Will consult Context7 MCP for Godot 4.5 best practices

**Overall Status**: PASS - No constitutional violations detected

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
# Godot Project Structure (Scene-First Architecture)
res://
├── scenes/
│   └── InterviewScene.tscn
├── scripts/
│   ├── models/
│   ├── InterviewManager.gd
│   └── InterviewScene.gd
└── tests/
    ├── integration/
    ├── performance/
    └── edge_cases/

# Option 2: Web application (when "frontend" + "backend" detected)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# Option 3: Mobile + API (when "iOS/Android" detected)
api/
└── [same as backend above]

ios/ or android/
└── [platform-specific structure]
```

**Structure Decision**: Option 1 (Single project) - Godot project with scene-based architecture

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
- Generate TDD-based tasks following constitutional requirements
- JSON Schema validation tasks from contracts/json-schema.json
- InterviewManager autoload implementation (singleton pattern)
- Interview scene creation with dynamic UI updates
- Integration tests for preset filtering and question branching

**Specific Task Categories**:
- **Data Validation**: JSON schema tests, interview data validation
- **Core Logic**: InterviewManager methods, question filtering, state management
- **UI Implementation**: Scene creation, dynamic button generation, progress display
- **Integration**: Character preset integration, game state effect application
- **Testing**: Unit tests for each component, integration tests for complete flow

**Ordering Strategy**:
- TDD order: Tests first, then implementation
- Foundation first: JSON validation → InterviewManager → Scene → Integration
- Scene-first architecture: Independent scenes can be developed in parallel [P]
- Autoload singleton before dependent scenes

**Estimated Output**: 20-25 numbered tasks following Godot constitutional principles

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
- [x] Complexity deviations documented (none required)

---
*Based on Constitution v2.1.1 - See `/memory/constitution.md`*
