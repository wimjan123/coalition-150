# Research: Character and Party Creation Preset System

## Research Questions Addressed

### 1. Godot 4.5 OptionButton Best Practices

**Decision**: Use OptionButton with item_selected signal for preset selection
**Rationale**:
- Native Godot UI element with built-in dropdown functionality
- Supports both text and icons for each option
- Integrates seamlessly with existing theme system
- Provides keyboard navigation and accessibility support
**Alternatives considered**:
- ItemList: More complex, overkill for simple selection
- Custom buttons: Requires more implementation work
- MenuButton: Less intuitive for single selection

### 2. Resource File Architecture for Presets

**Decision**: Create CharacterBackgroundPresets.gd resource class with exported arrays
**Rationale**:
- Godot Resources are serializable and can be saved as .tres files
- Type-safe with @export annotations
- Hot-reloadable in editor for easy content updates
- Can include metadata like difficulty ratings and descriptions
**Alternatives considered**:
- JSON files: Not type-safe, requires custom parsing
- Hard-coded arrays: Not easily modifiable by designers
- Database: Overkill for static preset data

### 3. Integration with Existing Character Creation Flow

**Decision**: Modify existing CharacterPartyCreation.gd script to handle hybrid input
**Rationale**:
- Maintains existing scene hierarchy and signal flow
- Preserves current save/load functionality
- Minimal disruption to existing user flow
- Can reuse existing validation and state management
**Alternatives considered**:
- Create new scene: Would require reworking navigation flow
- Replace entire creation system: Too disruptive for scope

### 4. Difficulty Rating and Preview System

**Decision**: Create PresetOption resource with rating, preview text, and gameplay impact fields
**Rationale**:
- Structured data enables rich UI display
- Supports future expansion for more metadata
- Can be localized for different languages
- Enables data-driven difficulty balancing
**Alternatives considered**:
- Simple strings: Would limit UI richness and flexibility
- External configuration: Adds complexity without benefit

### 5. Political Balance Implementation

**Decision**: Create balanced array with 8 representative options + 2 satirical options
**Rationale**:
- Meets requirement for political balance and Dutch representation
- Satirical options add humor without overwhelming serious options
- Fixed count (10) enables consistent UI layout
- Order by difficulty provides gameplay progression
**Alternatives considered**:
- Random selection: Would not guarantee balance
- User-configurable balance: Adds complexity beyond requirements

### 6. UI Theme Integration

**Decision**: Extend existing ui_theme.tres with OptionButton styling
**Rationale**:
- Maintains visual consistency with existing UI
- Leverages existing theme system architecture
- Supports hover, focus, and disabled states
- Enables easy future restyling
**Alternatives considered**:
- Custom styling: Would break consistency
- Separate theme: Would create maintenance overhead

## Technical Implementation Approach

### Phase 1: Resource System
1. Create CharacterBackgroundPresets resource class
2. Define PresetOption sub-resource for individual options
3. Create sample preset data in .tres format
4. Add political balance validation to resource

### Phase 2: UI Modification
1. Replace LineEdit with OptionButton in CharacterPartyCreation scene
2. Add preview display components (labels for difficulty/impact)
3. Update theme system for OptionButton styling
4. Implement hover preview functionality

### Phase 3: Logic Integration
1. Modify CharacterPartyCreation.gd to load preset resource
2. Update option population logic
3. Implement selection validation and storage
4. Update save/load system for hybrid data model

### Phase 4: Testing
1. Unit tests for preset resource loading
2. Integration tests for UI interaction
3. Save/load system tests with new data structure
4. Manual testing for political balance and difficulty progression

## Performance Considerations

- OptionButton is lightweight native control
- Resource loading is one-time cost at scene initialization
- Preview text updates are string assignments (minimal cost)
- No additional memory overhead for preset selection vs. free text

## Compatibility Impact

- Existing save files will need migration for character background field
- UI layout may need minor adjustments for OptionButton sizing
- Theme system extension is backward compatible
- No impact on other game systems or scenes