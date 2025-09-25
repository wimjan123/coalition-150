# Coalition 150 Launch Screen - Developer Quickstart

## Overview
This guide demonstrates how to test and validate the launch screen implementation against the feature specification requirements.

## Prerequisites
- Godot 4.5 engine installed
- GUT testing framework installed
- Coalition 150 project files available
- Basic understanding of Godot scene structure

## Quick Validation Steps

### 1. Visual Verification (2 minutes)
```bash
# Run the launch screen scene directly
godot --scene res://scenes/launch/LaunchScreen.tscn

# Expected behavior:
# ✅ "Coalition 150" title displayed large and centered
# ✅ Progress bar shows 0% initially
# ✅ Background ColorRect fills screen
# ✅ Loading begins automatically
# ✅ Progress bar updates to 100% over 2-5 seconds
# ✅ Automatic transition to main menu after loading
```

### 2. Timeout Testing (30 seconds)
```bash
# Simulate slow loading conditions
# Modify AssetLoader to introduce 15-second delays
godot --scene res://scenes/launch/LaunchScreen.tscn

# Expected behavior:
# ✅ Loading continues for 10 seconds maximum
# ✅ Automatic retry initiated after timeout
# ✅ Up to 3 retry attempts
# ✅ Error handling after final retry failure
```

### 3. Progress Bar Accuracy (1 minute)
```bash
# Enable debug mode to verify progress calculation
godot --scene res://scenes/launch/LaunchScreen.tscn --debug

# Watch console output for:
# ✅ Progress updates from 0% to 100%
# ✅ No fake animations (progress reflects actual loading)
# ✅ Accurate percentage calculation
# ✅ Smooth progress increments
```

### 4. Input Handling Test (30 seconds)
```bash
# Start launch screen and try various inputs
godot --scene res://scenes/launch/LaunchScreen.tscn

# During loading, attempt:
# - Mouse clicks
# - Keyboard presses
# - Alt+Tab, Esc key

# Expected behavior:
# ✅ All input ignored during loading
# ✅ No response to mouse or keyboard
# ✅ System shortcuts still work (Alt+Tab, etc.)
```

### 5. Fade Transition Verification (1 minute)
```bash
# Run full launch sequence
godot --scene res://scenes/launch/LaunchScreen.tscn

# Observe transition:
# ✅ Fade-to-black effect begins after loading completes
# ✅ Smooth transition duration (~1 second)
# ✅ Main menu scene loads after fade
# ✅ No visual artifacts or flickering
```

## Automated Testing

### Unit Tests
```bash
# Run all launch screen unit tests
godot --headless --script res://addons/gut/gut_cmdln.gd -gtest=res://tests/unit/test_launch_screen.gd

# Expected results:
# ✅ test_title_display_correct()
# ✅ test_progress_bar_accuracy()
# ✅ test_timeout_behavior()
# ✅ test_retry_mechanism()
# ✅ test_input_blocking()
```

### Integration Tests
```bash
# Run end-to-end launch flow test
godot --headless --script res://addons/gut/gut_cmdln.gd -gtest=res://tests/integration/test_launch_to_menu.gd

# Expected results:
# ✅ test_complete_launch_sequence()
# ✅ test_error_recovery_flow()
# ✅ test_scene_transition()
# ✅ test_memory_cleanup()
```

## Performance Validation

### Frame Rate Check
```bash
# Monitor FPS during launch sequence
godot --scene res://scenes/launch/LaunchScreen.tscn --monitor-fps

# Requirements:
# ✅ Maintain 60 FPS throughout loading
# ✅ No frame drops during progress updates
# ✅ Smooth fade transition animation
```

### Memory Usage
```bash
# Check memory consumption
godot --scene res://scenes/launch/LaunchScreen.tscn --monitor-memory

# Requirements:
# ✅ Memory usage stays under 50MB
# ✅ No memory leaks after scene transition
# ✅ Proper resource cleanup
```

### Loading Time Measurement
```bash
# Time the loading process
godot --scene res://scenes/launch/LaunchScreen.tscn --benchmark

# Requirements:
# ✅ Scene loading completes under 100ms
# ✅ Asset loading simulation completes within 10 seconds
# ✅ Total time from launch to menu transition under 12 seconds
```

## Common Issues & Solutions

### Issue: Progress bar stuck at 0%
**Cause**: AssetLoader not emitting progress signals
**Solution**: Check signal connections in LaunchScreen.gd
```gdscript
# Verify these connections exist:
asset_loader.progress_updated.connect(_on_progress_updated)
asset_loader.loading_completed.connect(_on_loading_completed)
```

### Issue: Title text not centered
**Cause**: Label anchor/alignment settings incorrect
**Solution**: Set Label properties:
```gdscript
$TitleLabel.anchor_left = 0.5
$TitleLabel.anchor_right = 0.5
$TitleLabel.anchor_top = 0.4
$TitleLabel.anchor_bottom = 0.4
$TitleLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
```

### Issue: Scene transition fails
**Cause**: SceneManager not properly initialized
**Solution**: Check autoload registration:
```
Project Settings > AutoLoad > SceneManager = res://scripts/autoloads/SceneManager.gd
```

### Issue: Input not properly blocked
**Cause**: Control.mouse_filter not set correctly
**Solution**: Set mouse filter in _ready():
```gdscript
func _ready():
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_process_input(false)
```

## Manual Test Checklist

**Visual Requirements**:
- [ ] Title "Coalition 150" displayed prominently
- [ ] Large, centered text positioning
- [ ] Progress bar visible and functional
- [ ] ColorRect background covers full screen
- [ ] Consistent theme styling applied

**Functional Requirements**:
- [ ] Loading starts automatically on scene entry
- [ ] Progress updates accurately reflect loading
- [ ] 10-second timeout enforced
- [ ] Up to 3 automatic retries on failure
- [ ] All keyboard/mouse input ignored during loading
- [ ] Fade transition to main menu after completion

**Performance Requirements**:
- [ ] 60 FPS maintained throughout
- [ ] Scene loads in under 100ms
- [ ] No memory leaks detected
- [ ] Smooth progress bar animation

**Error Handling**:
- [ ] Timeout triggers retry mechanism
- [ ] Error messages displayed appropriately
- [ ] Graceful degradation on permanent failure

## Success Criteria
✅ All automated tests pass
✅ Manual checklist items confirmed
✅ Performance requirements met
✅ No console errors or warnings
✅ Smooth user experience from launch to menu

**Estimated validation time**: 10 minutes for full testing cycle
**Required for**: Feature acceptance and merge approval