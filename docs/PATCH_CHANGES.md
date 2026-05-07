# Patch 12.0.0 → 12.0.5 API Changes

## Overview: "Addon Apocalypse"

Patch 12.0.0 introduced fundamental changes to addon security and API access. This document outlines what changed and what still works.

---

## Major Changes Summary

### New APIs Added
- **437 Global APIs** added to various C_* namespaces
- **76 new events** for better event-driven architecture
- **137 new CVars** for settings and configuration

### APIs Removed  
- **138 Global APIs** deprecated or removed
- **8 events** removed (see details below)
- **153 CVars** removed or consolidated

### New Technologies
- **Secret Values**: Restrict addon access to tainted values
- **Secure Execution Contexts**: Required for certain operations
- **New Widget Methods**: 28 new frame/widget capabilities

---

## Critical Changes for PvP Addons

### Removed (12.0.0+)

```lua
-- GetArenaOpponentSpec(index)
-- REPLACED BY: "ARENA_PREP_OPPONENT_SPECIALIZATIONS" event
-- STATUS: Returns nil in 12.0.5+

-- GetBattlefieldStatus(index)
-- REPLACED BY: C_PvP namespace functions
-- STATUS: Deprecated

-- Several unit query functions
-- REASON: Security restrictions on enemy units
-- STATUS: Unreliable in PvP scenarios
```

### Added (12.0.0+)

```lua
-- C_ActionBar namespace (30+ functions)
-- New action bar state management

-- C_CombatLog namespace
-- Structured combat log access

-- C_DamageMeter namespace
-- Damage metrics and statistics

-- C_PvP namespace (106 functions)
-- Comprehensive PvP/arena information

-- Arena-specific events:
"ARENA_PREP_OPPONENT_SPECIALIZATIONS"
"ARENA_OPPONENT_UPDATE"
"ARENA_CROWD_CONTROL_CHANGED"
"PVP_ARENA_RATING_UPDATE"
"PVP_MATCH_ACTIVE"
"PVP_MATCH_COMPLETE"
```

---

## Taint System (New in 12.0.0)

### What is Taint?

When code runs during combat and affects game state, execution becomes "tainted." Tainted code cannot access certain "secret values."

### Why This Matters

Addons can no longer:
- Read enemy buffs/debuffs reliably
- Make real-time decisions in combat
- Access restricted spell information
- Modify game behavior based on combat data

### Solution for Arenamaster

1. **Read data during prep phase** - Before combat starts
2. **Use events for notifications** - React to match start/end
3. **Store historical data** - Don't need real-time access
4. **Accept data restrictions** - Some info simply isn't available

---

## Removed Events (12.0.0+)

These 8 events are no longer fired:

```lua
"ARENA_OPPONENT_UPDATE"            -- WAIT: Re-added later in 12.0.0
"BATTLEFIELD_OBJECTIVES_UPDATE"
"OBJECTIVE_PROGRESS_UPDATE"
"MATCH_STARTED"                    -- Replaced by ARENA_MATCH_BEGIN
"MATCH_ENDED"                      -- Replaced by ARENA_MATCH_END
"RATING_UPDATE"                    -- Replaced by PVP_ARENA_RATING_UPDATE
-- (2 more, exact names not documented)
```

**Note**: Some removed events were re-added in patches 12.0.1-12.0.5

---

## New Events Added (76 Total)

### Key Arena Events

```lua
"ARENA_MATCH_BEGIN"                -- Match starts (NEW)
"ARENA_MATCH_END"                  -- Match ends (NEW)
"ARENA_PREP_OPPONENT_SPECIALIZATIONS"  -- Prep phase (NEW)
"ARENA_OPPONENT_UPDATE"            -- Opponent info changes (RE-ADDED)
"ARENA_CROWD_CONTROL_CHANGED"      -- CC effects (NEW)
"PVP_ARENA_RATING_UPDATE"         -- Rating changed (NEW)
"PVP_MATCH_ACTIVE"                -- PvP active (NEW)
"PVP_MATCH_COMPLETE"              -- PvP complete (NEW)
```

### UI Events

```lua
"PLAYER_SPECIALIZATION_CHANGED"    -- Spec changed
"PLAYER_EQUIPMENT_CHANGED"         -- Equipment changed
-- ... many others
```

---

## New Combat Log System

### Old Method (Still Works)

```lua
-- Raw event
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
```

### New Method (Preferred)

```lua
-- Structured access
C_CombatLog.GetCombatLog(filter)
-- Returns: {
--   {timestamp, event, sourceGUID, sourceName, ...},
--   ...
-- }
```

**Advantage**: Better filtering, less event spam

---

## New CVars Added (137)

Many new CVars added for:
- **Arena settings**: Match duration, bracket visibility
- **UI options**: Frame positioning, transparency
- **Performance**: Particle effects, distance rendering
- **Accessibility**: Text scaling, contrast

**Removed CVars (153)**: Mostly obsolete legacy settings

---

## Compatibility with 12.0.5

Your addon will work on 12.0.5 if:

✅ You use C_PvP functions instead of deprecated functions  
✅ You read data during appropriate phases (prep, not combat)  
✅ You use events for notifications  
✅ You accept that some unit data isn't available  
✅ You avoid tainted execution paths  

❌ Don't try to:
- Read real-time enemy buff/debuff data
- Cast spells based on combat decisions
- Modify action bars during combat
- Access restricted spell information

---

## Migration Guide for Old Addons

### Before (Patch 11.0)
```lua
local spec = GetArenaOpponentSpec(1)
local buff = UnitBuff("arena1", 1)
```

### After (Patch 12.0+)
```lua
-- Register for event instead
frame:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")

-- Store spec when available
local opponents = {}
frame:SetScript("OnEvent", function(self, event)
    if event == "ARENA_PREP_OPPONENT_SPECIALIZATIONS" then
        opponents[1] = GetUnitName("arena1")
        -- Don't try to get detailed spec info in combat
    end
end)
```

---

## Version Timeline

- **12.0.0**: Initial "Addon Apocalypse" changes
- **12.0.1-12.0.4**: Hotfixes and balance adjustments
- **12.0.5**: Current stable version (April 23, 2026)
  - Additional bug fixes
  - API refinements
  - Performance improvements

---

## Resources

- Official Changes: `/api` in-game  
- Source: https://github.com/Gethe/wow-ui-source
- Community Updates: https://warcraft.wiki.gg

---

**Last Updated**: Patch 12.0.5  
**Relevance**: Current
