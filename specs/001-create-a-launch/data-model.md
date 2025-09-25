# Data Model: Coalition 150 Launch Screen

## Core Entities

### LoadingState
**Purpose**: Tracks the current state of asset loading process

**Fields**:
- `current_progress: float` - Current loading progress (0.0 to 1.0)
- `assets_loaded: int` - Number of assets successfully loaded
- `total_assets: int` - Total number of assets to load
- `is_complete: bool` - Whether loading process is finished
- `has_error: bool` - Whether an error occurred during loading
- `retry_count: int` - Current number of retry attempts (0-3)
- `loading_start_time: float` - Timestamp when loading began
- `estimated_time_remaining: float` - Calculated time to completion

**Validation Rules**:
- `current_progress` must be between 0.0 and 1.0
- `assets_loaded` cannot exceed `total_assets`
- `retry_count` must not exceed 3
- `is_complete` is true only when `assets_loaded` equals `total_assets`

**State Transitions**:
```
INITIALIZING → LOADING → COMPLETED
      ↓           ↓
    ERROR → RETRYING → LOADING
      ↓
  FAILED (after 3 retries)
```

### AssetItem
**Purpose**: Represents individual assets to be loaded during launch

**Fields**:
- `resource_path: String` - Godot resource path (res://...)
- `asset_type: AssetType` - Type of asset (SCENE, TEXTURE, FONT, AUDIO)
- `load_priority: int` - Loading priority (1=highest, 10=lowest)
- `is_loaded: bool` - Whether asset has been successfully loaded
- `load_time_ms: int` - Time taken to load this asset
- `file_size_kb: int` - Size of asset file for progress calculation

**Validation Rules**:
- `resource_path` must be valid Godot resource path starting with "res://"
- `load_priority` must be between 1 and 10
- `file_size_kb` must be positive integer

**Relationships**:
- Many AssetItems belong to one LoadingState
- AssetItems are processed in priority order (1 first)

### LaunchScreenState
**Purpose**: Manages the overall state of the launch screen UI

**Fields**:
- `current_screen_state: ScreenState` - Current UI state (SHOWING_TITLE, LOADING, TRANSITIONING, ERROR)
- `title_text: String` - Displayed title text ("Coalition 150")
- `progress_visible: bool` - Whether progress bar should be shown
- `can_accept_input: bool` - Whether user input is accepted (always false during loading)
- `fade_alpha: float` - Current fade overlay alpha (0.0-1.0)
- `timer_remaining: float` - Seconds remaining on timeout timer

**Validation Rules**:
- `title_text` must not be empty
- `fade_alpha` must be between 0.0 and 1.0
- `timer_remaining` must not be negative
- `can_accept_input` must be false during loading

**State Transitions**:
```
SHOWING_TITLE → LOADING → TRANSITIONING → COMPLETED
       ↓            ↓
    ERROR ← ← ← ← ←  ┘
```

### TransitionConfig
**Purpose**: Configuration for scene transition effects

**Fields**:
- `fade_duration: float` - Duration of fade effect in seconds
- `fade_color: Color` - Color of fade overlay (typically black)
- `target_scene_path: String` - Path to scene to transition to
- `transition_type: TransitionType` - Type of transition (FADE_OUT_IN, IMMEDIATE)

**Validation Rules**:
- `fade_duration` must be positive
- `target_scene_path` must be valid scene path
- `fade_color` must have alpha = 1.0 for proper fade effect

## Entity Relationships

```
LaunchScreenState (1) → LoadingState (1)
LoadingState (1) → AssetItem (many)
LaunchScreenState (1) → TransitionConfig (1)
```

## Enumerations

### AssetType
- `SCENE = 1` - Godot .tscn files
- `TEXTURE = 2` - Image files (.png, .jpg, .svg)
- `FONT = 3` - Font files (.ttf, .otf, .woff2)
- `AUDIO = 4` - Audio files (.ogg, .wav, .mp3)

### ScreenState
- `SHOWING_TITLE = 1` - Displaying title only
- `LOADING = 2` - Active loading with progress
- `TRANSITIONING = 3` - Fade transition in progress
- `ERROR = 4` - Error state with retry capability
- `COMPLETED = 5` - Loading finished, ready for transition

### TransitionType
- `FADE_OUT_IN = 1` - Fade to black then fade in next scene
- `IMMEDIATE = 2` - Instant scene change (for errors/testing)

## Data Flow

1. **Initialization**: LaunchScreenState created with default values
2. **Asset Discovery**: AssetItem list populated with required resources
3. **Loading Start**: LoadingState begins asset loading process
4. **Progress Updates**: LoadingState.current_progress updated as assets complete
5. **Completion**: All assets loaded, LoadingState.is_complete = true
6. **Transition**: TransitionConfig applied for scene change

## Validation & Constraints

### Performance Constraints
- Maximum 20 AssetItems per loading session
- Each AssetItem should load within 500ms
- Total loading time under 10 seconds
- Progress updates minimum every 100ms

### Business Rules
- Title text must always be "Coalition 150"
- Loading must show accurate progress (no fake animations)
- User input disabled during loading process
- Automatic retry maximum 3 attempts
- Fade transition minimum 0.5 seconds for user perception

### Data Integrity
- LoadingState progress must reflect actual asset loading
- Asset loading order must respect priority values
- Error states must maintain retry count accuracy
- Timer accuracy within 50ms for timeout detection