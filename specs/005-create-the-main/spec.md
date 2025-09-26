# Feature Specification: Main Game Dashboard

**Feature Branch**: `005-create-the-main`
**Created**: 2025-09-26
**Status**: Draft
**Input**: User description: "Create the main game dashboard. The dashboard must be the central hub for the player and have an event-driven and character-focused feel. It must display four key stats at all times: Approval Rating, Party Treasury, Seats in Parliament, and the Current In-Game Date. The primary player interactions will be through a map of the Netherlands for managing regional campaigns, a list of parliamentary bills for voting, a calendar for scheduling events, and a news feed for reacting to events. The game time must pass automatically, with controls to pause and change the speed."

## Execution Flow (main)
```
1. Parse user description from Input
   → If empty: ERROR "No feature description provided"
2. Extract key concepts from description
   → Identify: actors, actions, data, constraints
3. For each unclear aspect:
   → Mark with [NEEDS CLARIFICATION: specific question]
4. Fill User Scenarios & Testing section
   → If no clear user flow: ERROR "Cannot determine user scenarios"
5. Generate Functional Requirements
   → Each requirement must be testable
   → Mark ambiguous requirements
6. Identify Key Entities (if data involved)
7. Run Review Checklist
   → If any [NEEDS CLARIFICATION]: WARN "Spec has uncertainties"
   → If implementation details found: ERROR "Remove tech details"
8. Return: SUCCESS (spec ready for planning)
```

---

## ⚡ Quick Guidelines
- ✅ Focus on WHAT users need and WHY
- ❌ Avoid HOW to implement (no tech stack, APIs, code structure)
- 👥 Written for business stakeholders, not developers

### Section Requirements
- **Mandatory sections**: Must be completed for every feature
- **Optional sections**: Include only when relevant to the feature
- When a section doesn't apply, remove it entirely (don't leave as "N/A")

### For AI Generation
When creating this spec from a user prompt:
1. **Mark all ambiguities**: Use [NEEDS CLARIFICATION: specific question] for any assumption you'd need to make
2. **Don't guess**: If the prompt doesn't specify something (e.g., "login system" without auth method), mark it
3. **Think like a tester**: Every vague requirement should fail the "testable and unambiguous" checklist item
4. **Common underspecified areas**:
   - User types and permissions
   - Data retention/deletion policies
   - Performance targets and scale
   - Error handling behaviors
   - Integration requirements
   - Security/compliance needs

---

## Clarifications

### Session 2025-09-26
- Q: What time speed options should be available to players? → A: Basic speeds: 1x, 2x, 4x
- Q: What types of events should trigger dashboard updates or notifications? → A: All events plus social: Media coverage, public reactions, party member activities
- Q: What information should be shown for parliamentary bills? → A: Comprehensive: Full text, summary, party position, consequences, public opinion, coalition stance, voting deadline
- Q: What specific actions should players be able to take in regional campaign management? → A: Comprehensive: Fund allocation, candidate selection, strategy setting, rally scheduling, local policy positions
- Q: What types of responses should be available for news feed events? → A: Comprehensive: Ignore, public statement, private action, coalition consultation, emergency legislation, media campaign
- Q: How should character relationships and interactions be shown on the dashboard? → A: Character portraits with relationship indicators (trust levels, political alignment)
- Q: What types of events can be scheduled and what are the constraints? → A: Comprehensive events: Meetings, rallies, interviews, travel (time slots, conflicts, costs)
- Q: Can all game features be accessed from the dashboard, or are some activities separate? → A: Things with details behind tabs

---

## User Scenarios & Testing *(mandatory)*

### Primary User Story
As a political party leader, I need a central dashboard that gives me immediate visibility into my party's status and allows me to manage all key political activities in one place. The dashboard should feel like a command center where I can monitor my approval rating, manage finances, track parliamentary representation, respond to current events, and strategically plan campaigns across the Netherlands.

### Acceptance Scenarios
1. **Given** I open the game, **When** I view the dashboard, **Then** I can see all four key stats (Approval Rating, Party Treasury, Seats in Parliament, Current Date) clearly displayed at all times
2. **Given** I'm on the dashboard, **When** I interact with the Netherlands map, **Then** I can access regional campaign management for different provinces
3. **Given** there are pending parliamentary bills, **When** I access the bills list, **Then** I can review and vote on legislation
4. **Given** I want to plan my political activities, **When** I open the calendar, **Then** I can schedule events and see upcoming commitments
5. **Given** current events are happening, **When** I check the news feed, **Then** I can see relevant political news and choose how to respond
6. **Given** the game is running, **When** time passes automatically, **Then** I can see the date advance and can pause or change the speed of time progression

### Edge Cases
- **Approval Rating Thresholds**: When approval rating ≤ 15%, trigger crisis mode with urgent notifications; when ≥ 85%, unlock special campaign opportunities
- **Treasury Management**: When treasury < 0, disable funding-dependent actions and display debt warning; when treasury < -50,000, trigger emergency fundraising event
- **Event Prioritization**: High-priority events (urgency_level = CRITICAL) must display modal notifications that pause time automatically until acknowledged
- **Speed Transition Behavior**: Time speed changes must complete current time increment before applying new speed; UI must show 200ms transition animation between speeds

## Requirements *(mandatory)*

### Functional Requirements
- **FR-001**: System MUST display four key stats (Approval Rating, Party Treasury, Seats in Parliament, Current In-Game Date) prominently and persistently on the dashboard
- **FR-002**: System MUST provide an interactive map of the Netherlands for regional campaign management access
- **FR-003**: System MUST present a list of current parliamentary bills available for voting
- **FR-004**: System MUST include a calendar interface for scheduling and viewing political events
- **FR-005**: System MUST display a news feed showing current political events and allow player responses
- **FR-006**: System MUST automatically advance game time at a default speed
- **FR-007**: System MUST provide pause functionality to stop time progression
- **FR-008**: System MUST allow players to change the speed of time progression with three options: 1x (normal), 2x (fast), 4x (very fast)
- **FR-009**: System MUST maintain an event-driven feel by triggering dashboard updates for political events (bill deadlines, elections, crises), game mechanics (stat changes, time milestones), and social activities (media coverage, public reactions, party member activities)
- **FR-010**: System MUST reflect character-focused gameplay through character portraits with relationship indicators showing trust levels and political alignment
- **FR-011**: Dashboard MUST serve as the central hub with all game features accessible through tabbed interfaces that provide detailed views behind the main dashboard overview
- **FR-012**: Regional campaign management MUST allow comprehensive actions per region including fund allocation, candidate selection, strategy setting, rally scheduling, and local policy positions
- **FR-013**: Bill voting system MUST provide comprehensive information including full text, summary, party position, predicted consequences, public opinion, coalition stance, and voting deadline
- **FR-014**: Event scheduling MUST support comprehensive event types (meetings, rallies, interviews, travel) with constraints including time slot availability, schedule conflict detection, and treasury costs
- **FR-015**: News feed responses MUST allow comprehensive response options including ignore, public statement, private action, coalition consultation, emergency legislation, and media campaign

### Key Entities *(include if feature involves data)*
- **Game State**: Current approval rating, treasury amount, parliamentary seats, game date/time, time speed setting
- **Regional Data**: Campaign status and activities for each province in the Netherlands
- **Parliamentary Bills**: Legislation items with details, voting status, and deadlines
- **Calendar Events**: Scheduled political activities with dates, types, and requirements
- **News Items**: Current political events with response options and potential impacts
- **Time Controller**: Game time progression state, speed multiplier, pause status

---

## Review & Acceptance Checklist
*GATE: Automated checks run during main() execution*

### Content Quality
- [ ] No implementation details (languages, frameworks, APIs)
- [ ] Focused on user value and business needs
- [ ] Written for non-technical stakeholders
- [ ] All mandatory sections completed

### Requirement Completeness
- [ ] No [NEEDS CLARIFICATION] markers remain
- [ ] Requirements are testable and unambiguous
- [ ] Success criteria are measurable
- [ ] Scope is clearly bounded
- [ ] Dependencies and assumptions identified

---

## Execution Status
*Updated by main() during processing*

- [x] User description parsed
- [x] Key concepts extracted
- [x] Ambiguities marked
- [x] User scenarios defined
- [x] Requirements generated
- [x] Entities identified
- [ ] Review checklist passed

---