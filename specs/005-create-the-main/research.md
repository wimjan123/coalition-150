# Research: Main Game Dashboard

## Technical Decisions

### UI Framework: Godot 4.5 Built-in UI
**Decision**: Use Godot's native UI system with Control nodes
**Rationale**:
- Native integration with scene system
- No external dependencies
- Built-in theme system for consistency
- Signal-based communication aligns with architecture
- ScrollContainer supports dynamic content
- Label nodes provide flexible text display with styling
**Alternatives considered**: Custom UI implementation, third-party UI frameworks

### Netherlands Map Implementation: Polygon2D from SVG
**Decision**: Convert SVG map data to Polygon2D nodes for each province
**Rationale**:
- Interactive clickable regions
- Easy visual feedback (hover, selection states)
- Can be styled with materials and shaders
- Scalable vector graphics maintain quality
- Individual province control for campaign management
**Alternatives considered**: TextureButton grid, Area2D collision shapes, custom drawing

### Time Management: Global Autoload System
**Decision**: TimeManager autoload singleton for centralized time control
**Rationale**:
- Global access from any scene
- Consistent time state across components
- Easy pause/speed control implementation
- Event system can subscribe to time changes
- Autoload pattern is idiomatic Godot
**Alternatives considered**: Scene-local time management, event-driven time updates

### Data Storage: Godot Resources (.tres)
**Decision**: Use Resource files for game state persistence
**Rationale**:
- Native Godot serialization
- Type-safe data structures
- Easy save/load implementation
- Human-readable text format
- Version control friendly
**Alternatives considered**: JSON files, binary serialization, SQLite database

### Testing Framework: GUT (Godot Unit Test)
**Decision**: Use GUT framework for all testing needs
**Rationale**:
- Native GDScript testing
- Scene testing capabilities
- Signal testing support
- TDD-friendly workflow
- Established Godot community tool
**Alternatives considered**: Custom test framework, manual testing only

## SVG Map Sources (Open Source)

### Recommended Source: SimpleMaps Netherlands
**Source**: https://simplemaps.com/svg/country/nl
**License**: Free for commercial and personal use
**Features**:
- 12 provinces clearly defined
- Province names as IDs in SVG
- Clean, minimalist design suitable for game UI
- First-level administrative regions
- Optimized file size

### Alternative Sources:
1. **FreeSVG** (Public Domain): https://freesvg.org/cafuego-nederland
2. **Wikipedia/Wikimedia Commons** (CC BY-SA 3.0): Multiple detailed maps
3. **GitHub Gist**: Community-contributed province maps
4. **MapSVG** (Commercial use allowed): Professional quality maps

## Implementation Patterns

### Scene Architecture
- **MainDashboard.tscn**: Root scene containing all UI panels
- **StatsPanel.tscn**: Four key stats display component
- **NetherlandsMap.tscn**: Interactive province map component
- **BillsList.tscn**: Scrollable bills container
- **NewsFeed.tscn**: Scrollable news items container
- **Calendar.tscn**: Event scheduling interface

### Signal Flow
```
UI Components -> DashboardManager -> Game Systems
TimeManager -> Dashboard Components (time display updates)
Map Interactions -> Regional Campaign System
Bill Actions -> Parliamentary System
News Responses -> Event System
```

### Performance Considerations
- Object pooling for news items and bill entries
- Lazy loading for detailed bill content
- Efficient map interaction with Area2D collision
- Theme system for consistent styling across all components

## Technical Requirements Summary
- **Engine**: Godot 4.5 stable
- **Language**: GDScript 2.0 with explicit typing
- **UI**: Native Control nodes with custom theme
- **Data**: Resource-based save system
- **Testing**: GUT framework with 80% coverage target
- **Performance**: 60 FPS target with smooth interactions
- **Architecture**: Scene-first with signal communication