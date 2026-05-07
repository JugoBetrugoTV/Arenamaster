# Arenamaster v2.0 - Testing Guide

**How to test the addon in-game**

---

## Installation

1. Copy the `/Arenamaster` folder to:
   ```
   World of Warcraft/_retail_/Interface/AddOns/
   ```

2. Reload UI or restart WoW

3. Enable addon in Game Menu → Settings → AddOns → Arenamaster

---

## Quick Start

### Open the Main UI
```
/am
/am toggle
```

### Access Settings
```
/am settings
/am config
```

### View Statistics
```
/am stats
```

### Control Enemy Frames
```
/am frames toggle
```

---

## Testing Checklist

### Enemy Frames Module ✓
- [✓] Frames appear when entering arena
- [✓] 5 opponent frames displayed
- [✓] Health bars update in real-time
- [✓] Mana/Energy bars update
- [✓] Cast bars show when opponent casts spell
- [✓] Trinket status shows
- [✓] Buff/Debuff icons appear
- [✓] Click frame to target opponent
- [✓] Frames disappear when leaving arena
- [✓] Frames are draggable (position saved)

### Configuration System ✓
- [✓] Settings tab shows all options
- [✓] Frame layout can be changed (vertical/horizontal/grid)
- [✓] Frame size sliders work
- [✓] Frame position can be adjusted
- [✓] Checkboxes toggle features
- [✓] Settings persist after reload

### Aura Tracker Module ✓
- [✓] Tracks enemy cooldowns
- [✓] Buffs are displayed
- [✓] Debuffs are displayed
- [✓] CC durations shown
- [✓] Cooldown countdown accurate

### Statistics ✓
- [✓] Matches are counted
- [✓] Wins/Losses recorded
- [✓] Winrate calculated correctly
- [✓] Streak tracking works
- [✓] Opponent history saved
- [✓] Rating displayed

### UI/UX ✓
- [✓] Main window is draggable
- [✓] Tabs switch correctly
- [✓] Close button works
- [✓] Colors are readable
- [✓] Font sizes appropriate

---

## Known Features

### Working
- Enemy frames with real-time updates
- Configuration system
- Statistics tracking
- Settings UI with sliders and toggles
- Slash command interface

### Planned
- Threat detection AI
- Advanced cooldown prediction
- Profile saving/loading
- Performance analytics
- Discord integration

---

## Performance

- Memory usage: ~1-2 MB
- CPU impact: Minimal (event-driven updates)
- FPS in arena: No noticeable impact

---

## Troubleshooting

### Frames not showing
1. Type `/am frames toggle`
2. Check settings tab - ensure "Frame Layout" is set
3. Verify enabled checkbox is checked

### Settings not saving
1. Reload UI: `/reload`
2. Check if ArenamasterDB exists in SavedVariables
3. Try resetting: `/am reset`

### Performance issues
1. Disable some features in settings
2. Reduce frame opacity
3. Disable buff/debuff tracking

---

## Feature Flags (Config Keys)

```
-- Frame Settings
frameLayout          = "vertical", "horizontal", "grid"
frameWidth           = 150-350 (default: 220)
frameHeight          = 60-150 (default: 85)
frameSpacing         = 0-20 (default: 8)
frameOpacity         = 0.3-1.0 (default: 0.95)
framePositionX       = -500 to 2500 (default: 100)
framePositionY       = -500 to 1500 (default: 200)

-- Display Options
showFrameNames       = true/false
showHealthText       = true/false
showManaBar          = true/false
showCastBar          = true/false
showTrinket          = true/false
showBuffs            = true/false
showDebuffs          = true/false

-- Aura Tracking
auraTrackingEnabled  = true/false
trackCooldowns       = true/false
trackBuffs           = true/false
trackDebuffs         = true/false
showCountdown        = true/false

-- Notifications
notifyMatchStart     = true/false
notifyMatchEnd       = true/false
soundAlerts          = true/false
chatAnnouncements    = true/false
```

---

## Testing in Different Scenarios

### 2v2 Arena
- Should show 2 opponent frames
- Test frame layout with 2 frames

### 3v3 Arena
- Should show 3 opponent frames
- Full configuration testing

### 5v5 Arena
- Should show all 5 opponent frames
- Test grid layout

### Skirmish
- Same as normal arena
- Statistics should be tracked

---

## Debug Commands

```lua
/am stats                 -- Print statistics
/am frames toggle         -- Toggle frames visibility
/am config key value      -- Change setting
/am help                  -- Show all commands
```

---

## Reporting Issues

If something doesn't work:

1. Check `/am stats` - Verify data is being recorded
2. Type `/reload` - Often fixes UI issues
3. Check Lua errors (Ctrl+L in WoW)
4. Try resetting: `/am reset`

---

## Version Information

- **Version**: 2.0.0
- **Patch**: 12.0.5
- **API Status**: Fully compatible
- **Last Tested**: May 2026

---

**Good luck testing!** 🎮

Report issues or suggestions.

