# World of Warcraft API Reference - Patch 12.0.5
**Last Updated: Patch 12.0.5 (67186) Apr 23 2026**

This is the official API reference for WoW Patch 12.0.5. All functions listed here are verified to work with this patch.

## API Overview

The WoW API uses the namespace pattern `C_SystemName.FunctionName()` and follows Blizzard's secure execution model introduced in Patch 12.0.0 ("Addon Apocalypse").

**Important**: Patch 12.0.0+ introduced "Secret Values" - a security mechanism that restricts addon operations on tainted execution paths. Check if functions require secure execution contexts.

---

## Patch 12.0.0 Major Changes

**Scale of Changes:**
- 437 new Global APIs added
- 138 Global APIs removed
- 76 new events added
- 8 events removed
- 137 new CVars added
- 153 CVars removed
- 28 new Widget methods added
- 6 new ScriptObjects added

---

## PvP & Arena APIs (C_PvP Namespace)

**Total Functions in C_PvP**: 106 functions

### Arena-Related Functions

```lua
-- Match Information
C_PvP.GetActiveMatchBracket()              -- Returns the current arena bracket (1v1, 2v2, 3v3, 5v5)
C_PvP.GetActiveMatchDuration()             -- Returns match duration in seconds
C_PvP.GetActiveMatchState()                -- Returns match state (nil, "preparation", "running", "complete")
C_PvP.GetActiveMatchWinner()               -- Returns winner (1, 2, or nil)

-- Arena Information
C_PvP.IsArena()                            -- Returns true if player is in any arena match
C_PvP.IsRatedArena()                       -- Returns true if in rated arena
C_PvP.IsMatchConsideredArena()             -- Returns true if match counts as arena

-- Opponent Information  
C_PvP.GetArenaCrowdControlInfo()           -- Returns CC duration information
GetArenaOpponentSpec(index)                -- Returns spec name for opponent 1-5 (DEPRECATED in 12.0.5)

-- Rewards
C_PvP.GetArenaRewards()                    -- Returns match rewards
C_PvP.GetArenaSkirmishRewards()            -- Returns skirmish-specific rewards

-- Arena Status
C_PvP.GetPersonalArenaRating(bracket)      -- Returns personal rating (1=2v2, 2=3v3, 3=5v5)
```

### Events (PvP & Arena)

**Important Arena Events:**
```lua
-- Arena Match Events
"ARENA_MATCH_BEGIN"                -- Fired when arena match starts
"ARENA_MATCH_END"                  -- Fired when arena match ends (winner passed as arg)
"ARENA_PREP_OPPONENT_SPECIALIZATIONS"  -- Fired when opponent specs are known
"ARENA_OPPONENT_UPDATE"            -- Fired when opponent information changes

-- General PvP Events
"PVP_MATCH_ACTIVE"                 -- Active PvP match running
"PVP_MATCH_COMPLETE"               -- PvP match finished
"ARENA_CROWD_CONTROL_CHANGED"      -- CC effects changed
```

---

## Rating & Progression APIs

```lua
-- Personal Rating
GetPersonalRatedInfo(bracket)      -- Returns (rating, seasonTotal, weeklyTotal, seasonBest)
                                    -- bracket: 1=2v2, 2=3v3, 3=5v5
GetPersonalArenaRating(bracket)    -- Returns rating for specific bracket

-- Rating Tiers (Determined by Rating Value)
-- 2400+ = Gladiator (purple)
-- 2100-2399 = Duelist (purple)
-- 1800-2099 = Rival (blue)
-- 1600-1799 = Challenger (green)
-- 0-1599 = Unranked (gray)
```

---

## Unit Information APIs

```lua
-- Unit Queries
GetUnitName(unit)                  -- Returns (name, realm)
UnitClass(unit)                    -- Returns (className, classFile, classID)
UnitSpecialization(unit)           -- Returns spec ID
UnitLevel(unit)                    -- Returns level
UnitExists(unit)                   -- Returns true if unit exists

-- Unit Status
UnitHealth(unit)                   -- Returns current health
UnitHealthMax(unit)                -- Returns max health
UnitGetTotalAbsorbs(unit)          -- Returns total absorption shields
UnitCastingInfo(unit)              -- Returns (spellName, ...)
UnitChannelInfo(unit)              -- Returns (spellName, ...)

-- IMPORTANT: These may be restricted on non-friendly units in combat
```

---

## Action Bar & Cooldown APIs

```lua
-- Action Bar System
C_ActionBar.GetActionBarPage()     -- Returns current action bar page
C_ActionBar.GetCooldownForAction(actionID)  -- Returns action cooldown info

-- Spell Cooldowns
GetSpellBaseCooldown(spellID)      -- Returns cooldown duration in milliseconds
GetSpellCooldown(spellID)          -- Returns (start, duration, enabled)
IsSpellInRange(spellID, target)    -- Returns true if spell is in range

-- Combat Log
C_CombatLog.GetCombatLog(filter)   -- Returns combat log entries (COMBAT_LOG event alternative)
```

---

## RESTRICTED APIs (Patch 12.0.5)

**These functions are tainted or restricted in combat scenarios:**

```lua
-- Cannot be used on enemy units in rated PvP
UnitBuff(unit, index)              -- Cannot read enemy buffs reliably
UnitDebuff(unit, index)            -- Cannot read enemy debuffs reliably  
GetSpellInfo()                     -- Restricted in combat on certain paths
SpellIsTargetingArea(spellID)      -- May be restricted

-- Cannot be used to affect game state during PvP
CastSpellByID()                    -- Restricted to secure code
CastSpellByName()                  -- Restricted to secure code
UseAction()                        -- Requires secure execution context
ClickActionButton()                -- Requires secure execution context
```

---

## Events System

```lua
-- Creating Event Frame
local frame = CreateFrame("Frame")
frame:RegisterEvent("EVENT_NAME")
frame:SetScript("OnEvent", function(self, event, ...)
    -- Handle event
end)

-- Unregistering
frame:UnregisterEvent("EVENT_NAME")

-- Important: Not all events fire in combat or for restricted information
```

---

## Global Functions (Available in 12.0.5)

```lua
-- Time
GetTime()                          -- Returns current game time in seconds
date()                             -- Standard Lua date function

-- Math
math.floor()                       -- Standard Lua floor
math.ceil()                        -- Standard Lua ceil
math.max()                         -- Standard Lua max

-- Table Operations  
table.insert()                     -- Standard Lua table insert
table.remove()                     -- Standard Lua table remove

-- String Operations
string.format()                    -- Standard Lua string format
tostring()                         -- Standard Lua tostring
tonumber()                         -- Standard Lua tonumber
```

---

## Critical Information for Addons

### Taint & Security (12.0.0+)

1. **Tainted Execution Paths**: If your function runs during combat and modifies game state, it may be tainted
2. **Secret Values**: Cannot access certain values in tainted execution
3. **Solution**: Use secure headers or avoid combat modifications

### What Works Well

- Reading game state (ratings, stats, opponent info pre-match)
- UI updates and frames
- Event handling for match start/end
- Data collection and statistics
- Configuration options

### What Is Restricted

- Real-time unit buff/debuff reading (enemy)
- Casting spells in combat
- Making in-game decisions based on tainted data
- Using certain GetSpellInfo queries in combat

---

## Version Notes

- **Patch**: 12.0.5 (67186)
- **Release Date**: April 23, 2026
- **Next Major Patch**: 12.1.0 (TBD)

---

## Resources

- **Official WoW Addons Source**: https://github.com/Gethe/wow-ui-source/tree/live/Interface/AddOns/Blizzard_APIDocumentationGenerated
- **In-Game Reference**: Type `/api` in-game
- **Community Wiki**: https://warcraft.wiki.gg

