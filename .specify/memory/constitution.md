<!--
SYNC IMPACT REPORT
===================
Version Change: 1.0.0 → 1.1.0 (New principle addition)
Modified Principles: None (existing principles unchanged)
Added Principles:
- Added: VI. Documentation-First Development (Context7 MCP requirement for Godot 4.5 documentation)

Added Sections: None
Removed Sections: None

Templates Requiring Updates:
- ✅ Updated: .specify/templates/plan-template.md (constitution check section now includes documentation verification)
- ✅ Updated: .specify/templates/spec-template.md (requirement completeness includes MCP Context7 consultation)
- ✅ Updated: .specify/templates/tasks-template.md (task categories now include documentation research tasks)

Follow-up TODOs: None (all requirements addressed)
-->

# Godot Simulation Game Constitution

## Core Principles

### I. Scene-First Architecture
Every feature starts as a self-contained scene; Scenes must be modular, independently testable, and reusable; Clear responsibility separation - UI scenes handle presentation, logic scenes handle behavior, data scenes handle state; No direct coupling between unrelated scenes - use signals and the event bus pattern.

**Rationale**: Godot's scene system is the fundamental building block. Modular scenes enable parallel development, easier testing, and better maintainability in complex simulation games where systems need to interact without tight coupling.

### II. GDScript Standards
Follow Godot's official GDScript style guide without exception; Use snake_case for variables and functions, PascalCase for classes and resources; Explicit typing required for all variables and function parameters; No @export variables without @export_group or clear documentation; Maximum function length of 20 lines - extract to private methods if exceeded.

**Rationale**: Consistent code style reduces cognitive load and enables team collaboration. Explicit typing prevents runtime errors common in dynamic languages, while short functions improve readability and testability in complex simulation logic.

### III. Test-Driven Development (NON-NEGOTIABLE)
TDD mandatory for all game logic: Tests written → User approved → Tests fail → Then implement; Use GUT (Godot Unit Test) framework for unit tests, integration tests for scene interactions; Red-Green-Refactor cycle strictly enforced - no implementation without failing tests first; Simulation logic must achieve minimum 80% code coverage.

**Rationale**: Simulation games have complex interdependent systems where bugs compound rapidly. TDD ensures system integrity and enables confident refactoring of performance-critical code paths.

### IV. Performance-First Design
Target 60 FPS on modest hardware (integrated graphics, 8GB RAM); Profile early and often using Godot's profiler - no performance assumptions without measurement; Object pooling required for frequently instantiated objects (particles, UI elements, simulation entities); Scene loading must be asynchronous for scenes >100 nodes.

**Rationale**: Simulation games often involve hundreds or thousands of entities with complex interactions. Performance problems compound exponentially with scale, making early optimization essential rather than premature.

### V. UI Consistency
Establish a comprehensive design system with reusable UI components; All UI elements must follow the same visual hierarchy and interaction patterns; Use Godot's theme system for consistent styling across all scenes; UI animations must be 60 FPS and accessible (respect reduced motion preferences); Every interactive element requires hover, focus, and disabled states.

**Rationale**: Simulation games have complex UIs with many panels and controls. Consistent UI patterns reduce learning curve and improve user experience, while proper theming enables easy reskinning and accessibility compliance.

### VI. Documentation-First Development
Always consult the latest Godot 4.5 documentation using Context7 MCP to ensure up-to-date best practices and API usage, especially when implementing new features or resolving issues; Document consultation MUST precede implementation of any new Godot feature or API usage; All code reviews MUST verify that official Godot patterns and recommendations have been followed; When Godot documentation conflicts with existing code, update code to match official patterns unless performance or compatibility requires deviation.

**Rationale**: Godot's rapid development cycle means best practices and API patterns evolve frequently. Context7 MCP provides access to the most current official documentation, preventing the use of deprecated patterns and ensuring optimal performance and compatibility with future Godot versions.

## Quality Standards

**Code Quality Gates**:
- Static analysis via gdtoolkit (gdformat, gdparse) passes without warnings
- All @export variables have tooltips and sensible default values
- No hardcoded values - use project settings or resource files for configuration
- Error handling for all file I/O and network operations
- Logging system integrated for debugging and analytics
- Context7 MCP documentation verification for all new Godot API usage

**Performance Standards**:
- Frame time consistency <16.67ms (60 FPS) under normal load
- Memory usage growth <5% per hour during extended gameplay
- Scene instantiation <100ms for complex scenes, <16ms for simple scenes
- Save/load operations non-blocking with progress indication

**Accessibility Requirements**:
- Keyboard navigation support for all interactive elements
- Colorblind-friendly color schemes with shape/icon alternatives
- Configurable text size and contrast options
- Audio cues for important state changes

## Development Workflow

**Version Control Standards**:
- Feature branches for all non-trivial changes
- Atomic commits with descriptive messages following conventional commit format
- No direct commits to main branch - all changes via pull request
- Godot scene (.tscn) and script (.gd) files must be version controlled in text format

**Code Review Process**:
- All pull requests require review from at least one team member
- Performance-sensitive changes require profiling data in PR description
- UI changes require screenshots/video demonstrating functionality
- Breaking changes require migration guide and backward compatibility plan
- Godot API usage must be verified against Context7 MCP documentation during review

**Testing Gates**:
- Unit tests pass locally before PR submission
- Integration tests pass in CI environment
- Performance regression tests for critical game systems
- Manual testing checklist for UI and gameplay flows

## Governance

This constitution supersedes all other development practices and serves as the authoritative source for project standards. All code reviews, pull requests, and architectural decisions must verify compliance with these principles.

**Amendment Process**:
- Proposed changes require detailed rationale and impact assessment
- Major principle changes require team consensus and migration timeline
- All amendments must be backward compatible or provide clear upgrade path
- Constitution version must be incremented following semantic versioning

**Compliance Review**:
- Weekly architecture reviews to assess adherence to principles
- Monthly performance audits using profiling and metrics
- Quarterly retrospectives to evaluate principle effectiveness
- Annual constitution review for relevance and completeness

**Enforcement**:
- Automated checks integrated into CI/CD pipeline where possible
- Code review templates include constitutional compliance checklist
- New team members must complete constitution training within first week
- Principle violations require explicit justification and remediation plan

**Version**: 1.1.0 | **Ratified**: 2025-09-25 | **Last Amended**: 2025-09-25