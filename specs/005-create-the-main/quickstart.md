# Quickstart Guide: Main Game Dashboard

## Development Setup

### Prerequisites
- Godot 4.5 stable
- GUT (Godot Unit Test) framework installed
- Access to SVG map resources for Netherlands provinces

### Project Structure
```
res://
├── scenes/
│   ├── dashboard/
│   │   ├── MainDashboard.tscn          # Main scene
│   │   ├── components/
│   │   │   ├── StatsPanel.tscn         # Four key stats
│   │   │   ├── NetherlandsMap.tscn     # Interactive map
│   │   │   ├── BillsList.tscn          # Parliamentary bills
│   │   │   ├── NewsFeed.tscn           # News and events
│   │   │   └── Calendar.tscn           # Event scheduling
├── scripts/
│   ├── dashboard/
│   │   ├── dashboard_manager.gd        # Central controller
│   │   └── components/
│   ├── autoloads/
│   │   ├── time_manager.gd             # Global time system
│   │   └── game_state.gd               # Game state persistence
├── resources/
│   ├── data/
│   │   ├── game_state.tres             # Current game state
│   │   └── provinces/                  # Province data files
│   └── maps/
│       └── netherlands_provinces.svg   # Map source data
├── tests/
│   ├── unit/
│   │   ├── test_dashboard_manager.gd
│   │   ├── test_time_manager.gd
│   │   └── test_regional_manager.gd
│   └── integration/
│       └── test_dashboard_integration.gd
```

## Implementation Steps

### Step 1: Core Data Structures (TDD)
1. Create failing tests for game state resources
2. Implement `GameState`, `GameDate`, `RegionalData` classes
3. Verify resource serialization works correctly

### Step 2: Time Management System (TDD)
1. Write tests for TimeManager autoload
2. Implement time progression, pause/resume functionality
3. Add speed control (1x, 2x, 4x)
4. Test time-based event triggers

### Step 3: Dashboard Scene Setup
1. Create MainDashboard.tscn with layout containers
2. Add StatsPanel with four Label nodes for key stats
3. Set up basic theme for consistent styling
4. Test scene instantiation and UI layout

### Step 4: Stats Display Component (TDD)
1. Write tests for stats display updates
2. Connect stats panel to game state
3. Implement real-time stat updates
4. Test stat formatting and display

### Step 5: Interactive Map Implementation
1. Import and convert SVG map to Polygon2D nodes
2. Set up one Polygon2D per Netherlands province
3. Add interaction detection (mouse hover, click)
4. Test province selection and highlighting

### Step 6: Parliamentary Bills System (TDD)
1. Write tests for bill data management
2. Create BillsList component with ScrollContainer
3. Implement bill voting interface
4. Add comprehensive bill information display

### Step 7: Calendar System (TDD)
1. Write tests for event scheduling
2. Create Calendar interface with time slot management
3. Implement conflict detection for events
4. Add cost validation for scheduled events

### Step 8: News Feed System (TDD)
1. Write tests for news item management
2. Create NewsFeed component with ScrollContainer
3. Implement response options interface
4. Add consequence system for news responses

### Step 9: Character Relationships Display
1. Create character portrait system
2. Implement trust level indicators
3. Add political alignment visualization
4. Test character state updates

### Step 10: Integration and Testing
1. Connect all systems through DashboardManager
2. Implement signal-based communication
3. Test complete user scenarios
4. Performance testing and optimization

## User Acceptance Testing

### Primary Dashboard Flow Test
```gdscript
# Test script for main dashboard functionality
func test_dashboard_primary_flow():
    # Given: Game is launched
    var dashboard = load_dashboard_scene()

    # When: Dashboard loads
    dashboard._ready()

    # Then: Four key stats are visible
    assert_stats_displayed(dashboard)
    assert_map_interactive(dashboard)
    assert_bills_list_populated(dashboard)
    assert_calendar_accessible(dashboard)
    assert_news_feed_active(dashboard)
    assert_time_controls_functional(dashboard)
```

### Regional Campaign Management Test
```gdscript
func test_regional_campaign_flow():
    # Given: Dashboard is active
    var dashboard = setup_dashboard()

    # When: Player clicks on a province
    dashboard.map.select_province("noord_holland")

    # Then: Regional management options are available
    assert_province_selected("noord_holland")
    assert_funding_allocation_available()
    assert_candidate_selection_available()
    assert_strategy_options_available()
    assert_rally_scheduling_available()
    assert_local_policy_options_available()
```

### Time Management Test
```gdscript
func test_time_management_flow():
    # Given: Dashboard with time controls
    var dashboard = setup_dashboard()
    var initial_time = dashboard.get_current_time()

    # When: Time controls are used
    dashboard.set_time_speed(TimeSpeed.FAST)
    dashboard.advance_time_for_testing(60) # 1 hour

    # Then: Time advances correctly
    var new_time = dashboard.get_current_time()
    assert_time_advanced(initial_time, new_time, 60)
    assert_time_speed_indicator_updated(TimeSpeed.FAST)

    # When: Time is paused
    dashboard.pause_time()

    # Then: Time stops advancing
    assert_time_paused()
    assert_pause_indicator_shown()
```

## Performance Targets

- **Scene Load Time**: MainDashboard.tscn loads in <500ms
- **Map Interaction**: Province selection responds in <50ms
- **UI Updates**: Stat changes reflect in <16ms (60 FPS)
- **Memory Usage**: <50MB for dashboard scene and data
- **Time Progression**: Smooth animation at all speed settings

## Common Issues and Solutions

### SVG Map Import Problems
**Issue**: SVG doesn't convert properly to Polygon2D
**Solution**: Use Inkscape to simplify paths, ensure clean province boundaries

### Performance Issues
**Issue**: Map interaction causes frame drops
**Solution**: Use Area2D collision detection instead of pixel-perfect collision

### Theme Consistency Problems
**Issue**: UI elements have inconsistent styling
**Solution**: Create comprehensive theme resource, apply to all Control nodes

### Signal Connection Errors
**Issue**: UI updates don't reflect data changes
**Solution**: Verify signal connections in _ready(), use typed signals

### Time Management Bugs
**Issue**: Time advances incorrectly at different speeds
**Solution**: Use delta-based calculations, test with fixed time steps

## Debugging Tools

### Dashboard Debug Panel
Add temporary debug information:
```gdscript
func _on_debug_info_requested():
    print("Current Stats: ", game_state.get_current_stats())
    print("Selected Province: ", map.get_selected_province())
    print("Active Bills: ", bills_manager.get_active_bills().size())
    print("Scheduled Events: ", calendar.get_upcoming_events().size())
    print("Time Speed: ", time_manager.get_time_speed())
```

### Performance Profiling
Use Godot's built-in profiler:
- Monitor frame time during UI updates
- Check memory allocation patterns
- Profile signal emission frequency
- Monitor resource loading times

## Ready for Production Checklist

- [ ] All unit tests passing (80% coverage minimum)
- [ ] Integration tests covering user scenarios
- [ ] UI theme consistently applied
- [ ] Performance targets met
- [ ] Netherlands map properly loaded and interactive
- [ ] Time management working at all speeds
- [ ] Save/load functionality tested
- [ ] Error handling for edge cases
- [ ] Documentation complete
- [ ] Code review completed