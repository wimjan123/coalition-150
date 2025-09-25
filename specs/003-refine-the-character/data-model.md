# Data Model: Character and Party Creation Preset System

## Core Entities

### PresetOption (Resource)
**Purpose**: Individual preset option with metadata for character backgrounds

**Fields**:
- `id: String` - Unique identifier for the preset option
- `display_name: String` - User-facing name shown in dropdown
- `background_text: String` - Full background story/description
- `character_archetype: String` - Category/type of character (e.g., "Activist", "Academic", "Entrepreneur")
- `difficulty_rating: int` - Numeric difficulty from 1-10 (1=easiest, 10=hardest)
- `difficulty_label: String` - Display text for difficulty (e.g., "Easy", "Hard")
- `gameplay_impact: String` - Preview text describing gameplay effects
- `political_alignment: String` - Political category (e.g., "Progressive", "Conservative", "Satirical")
- `is_satirical: bool` - Flag indicating if this is a satirical option

**Validation Rules**:
- `id` must be unique within preset collection
- `difficulty_rating` must be 1-10
- `display_name` and `background_text` cannot be empty
- Satirical options must have `is_satirical = true`

**State Transitions**: Static data, no state changes

### CharacterBackgroundPresets (Resource)
**Purpose**: Collection of all available character background presets

**Fields**:
- `preset_options: Array[PresetOption]` - Array of exactly 10 preset options
- `version: String` - Version identifier for preset data updates

**Validation Rules**:
- Array must contain exactly 10 options
- Exactly 2 options must have `is_satirical = true`
- All `id` values must be unique
- Difficulty ratings should span range 1-10 for balanced progression
- Political alignments should be balanced across Dutch political spectrum

**Relationships**:
- Contains: PresetOption[] (composition)
- Used by: CharacterPartyCreation scene

### Modified CharacterData (Existing Resource)
**Purpose**: Extended existing character data to support hybrid input model

**New Fields**:
- `selected_background_preset_id: String` - ID of selected preset (replaces free-text background)

**Unchanged Fields**:
- `character_name: String` - Custom character name
- `party_name: String` - Custom party name (remains free text)
- `party_slogan: String` - Custom party slogan (remains free text)
- Other existing fields preserved

**Migration Requirements**:
- Existing save files with free-text backgrounds need conversion
- Default preset ID for legacy data without preset selection

### Modified PartyData (Existing Resource)
**Purpose**: Maintains existing party data structure

**Unchanged Fields**:
- `party_name: String` - Custom party name (free text maintained)
- `party_slogan: String` - Custom party slogan (free text maintained)
- Other existing party fields preserved

**No Changes Required**: Party data structure remains compatible

## Data Flow

### Preset Loading Flow
```
1. Scene loads CharacterPartyCreation
2. Script loads CharacterBackgroundPresets.tres resource
3. Populates OptionButton with preset_options array
4. Sorts options by difficulty_rating (ascending)
5. Ready for user selection
```

### Selection Flow
```
1. User selects option from OptionButton
2. UI displays difficulty_label and gameplay_impact preview
3. User confirms selection
4. selected_background_preset_id stored in CharacterData
5. Full preset data retrieved for game logic when needed
```

### Save/Load Flow
```
Save:
1. CharacterData includes selected_background_preset_id
2. Serialized to user:// directory as existing .tres file

Load:
1. CharacterData deserialized from save file
2. Preset ID used to look up full preset from CharacterBackgroundPresets
3. Character background reconstructed from preset data
```

## Validation Logic

### Runtime Validation
- Validate preset ID exists in current preset collection
- Handle missing preset gracefully (fallback to default)
- Verify political balance when loading preset collection

### Editor Validation
- Resource validation ensures exactly 10 presets
- Checks for 2 satirical options
- Warns about political balance distribution
- Validates difficulty progression coverage

## Performance Characteristics

### Memory Usage
- PresetOption: ~200 bytes per option (estimated)
- CharacterBackgroundPresets: ~2KB total for 10 options
- Minimal overhead vs. free text storage

### Load Time
- Resource loading: <1ms (cached after first load)
- OptionButton population: <1ms for 10 items
- No impact on scene load time

### Scalability
- Fixed 10-option limit prevents UI scaling issues
- Resource system supports hot-reload for content updates
- Preset system extensible for future categories (if needed)

## Localization Support

### Localizable Fields
- `display_name` - Dropdown option text
- `background_text` - Full character background
- `difficulty_label` - Difficulty display text
- `gameplay_impact` - Preview description text

### Implementation
- Use Godot's localization system (CSV/PO files)
- Resource fields marked with tr() calls
- Multiple preset resource files for different languages (optional)

## Backward Compatibility

### Save File Migration
- Detect legacy save files with free-text backgrounds
- Map free text to closest matching preset (best effort)
- Provide default preset fallback for unmatchable text
- Log migration events for debugging

### UI Compatibility
- Existing theme system supports OptionButton styling
- Layout adjustments minimal (LineEdit vs OptionButton similar size)
- Signal system remains compatible (text_changed vs item_selected)

## Error Handling

### Missing Preset Resource
- Fallback to hardcoded default presets
- Log error for debugging
- Continue with reduced functionality

### Invalid Preset Data
- Skip invalid options during loading
- Log validation errors
- Continue with valid subset of presets

### Save File Corruption
- Graceful fallback to preset selection screen
- Clear error message to user
- Option to reset character creation