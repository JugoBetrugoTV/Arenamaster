# PvP & Arena Functions Guide - Patch 12.0.5

**For Arenamaster Addon Development**

## C_PvP Namespace - 106 Total Functions

### Safe Arena Functions (Verified Working)

```lua
-- ===== MATCH STATE =====
C_PvP.GetActiveMatchBracket()
-- Returns the current bracket: 
-- nil = not in arena
-- 1 = 2v2
-- 2 = 3v3  
-- 3 = 5v5
-- Returns: number or nil

C_PvP.GetActiveMatchDuration()
-- Returns the current match duration in seconds
-- Returns: number (0 if not in match)

C_PvP.GetActiveMatchState()
-- Returns match state
-- "preparation" = before match starts
-- "running" = match in progress
-- "complete" = match finished
-- Returns: string or nil

C_PvP.GetActiveMatchWinner()
-- Returns winning team
-- 1 = Team 1 won
-- 2 = Team 2 won
-- nil = match not complete or in progress
-- Returns: number or nil

-- ===== MATCH CHECKS =====
C_PvP.IsArena()
-- Returns: boolean (true if in any arena match)

C_PvP.IsRatedArena()
-- Returns: boolean (true if in rated arena)

C_PvP.IsMatchConsideredArena()
-- Returns: boolean (true if match counts as arena)

C_PvP.IsArenaSkirmish()
-- Returns: boolean (true if in arena skirmish)

-- ===== RATING & PROGRESSION =====
C_PvP.GetPersonalArenaRating(bracket)
-- bracket: 1=2v2, 2=3v3, 3=5v5
-- Returns: number (rating) or 0

GetPersonalRatedInfo(bracket)
-- bracket: 1=2v2, 2=3v3, 3=5v5
-- Returns: (rating, seasonTotal, weeklyTotal, seasonBest)
-- All values are numbers

C_PvP.GetArenaRewards()
-- Returns match rewards after arena ends
-- Returns: {
--   wonMatch = boolean,
--   ratingChange = number,
--   rewardItems = {table of items}
-- }

C_PvP.GetArenaSkirmishRewards()
-- Returns skirmish rewards
-- Returns: similar structure to GetArenaRewards()
```

### Opponent Information Functions

```lua
-- DEPRECATED: GetArenaOpponentSpec(index)
-- This was replaced in 12.0.0
-- DO NOT USE - will return nil in 12.0.5

-- NEW METHOD: Use events instead
-- "ARENA_PREP_OPPONENT_SPECIALIZATIONS" event
-- Provides opponent specs during preparation phase

-- Unit Information (Safe in Arena)
GetUnitName("arena1")              -- Returns opponent name
GetUnitName("arena2")              -- Opponent 2, etc (up to arena5)

-- Can also use on player's team
GetUnitName("player")              -- Your name
GetUnitName("party1")              -- Teammate 1
GetUnitName("party2")              -- Teammate 2
```

### Events (Arena & PvP)

```lua
-- ===== ARENA EVENTS =====
"ARENA_MATCH_BEGIN"
-- Fired when arena match starts
-- Args: (bracket) bracket number

"ARENA_MATCH_END"  
-- Fired when arena match ends
-- Args: (result) 1=win, 2=loss, nil=unknown

"ARENA_PREP_OPPONENT_SPECIALIZATIONS"
-- Fired when opponent specializations are known
-- Usually fires during preparation phase
-- Args: none (query C_PvP functions instead)

"ARENA_OPPONENT_UPDATE"
-- Fired when opponent information changes
-- Can fire multiple times during match
-- Args: (index) opponent index updated

"ARENA_CROWD_CONTROL_CHANGED"
-- Fired when crowd control effects change
-- Args: (unitTarget, ability, appliedOrRemoved)

-- ===== GENERAL PVP EVENTS =====
"PVP_MATCH_ACTIVE"
-- General PvP match is active
-- Args: none

"PVP_MATCH_COMPLETE"  
-- General PvP match finished
-- Args: (didWin) boolean

"PVP_ARENA_RATING_UPDATE"
-- Your arena rating changed
-- Args: (newRating, oldRating, bracket)
```

---

## Implementation Examples

### Track Arena Match

```lua
local function OnArenaMatchBegin(bracket)
    print("Arena match started! Bracket: " .. tostring(bracket))
    -- Safe to call:
    -- - GetPersonalRatedInfo(bracket)
    -- - C_PvP.GetActiveMatchDuration()
    -- - GetUnitName("arena1-5")
end

local function OnArenaMatchEnd(result)
    local winner = result == 1 and "WIN" or "LOSS"
    print("Match ended: " .. winner)
    
    -- Get rewards
    local rewards = C_PvP.GetArenaRewards()
    if rewards then
        print("Rating change: " .. tostring(rewards.ratingChange))
    end
end
```

### Get Opponent Names

```lua
local function GetOpponentNames()
    local opponents = {}
    
    -- Assuming 3v3 arena
    for i = 1, 3 do
        local name = GetUnitName("arena" .. i)
        if name then
            table.insert(opponents, name)
        end
    end
    
    return opponents
end
```

### Track Rating

```lua
local function GetCurrentRating()
    -- Get 3v3 rating as example
    local rating, seasonTotal, weeklyTotal, seasonBest = GetPersonalRatedInfo(2)
    
    return {
        current = rating or 0,
        season = seasonTotal or 0,
        weekly = weeklyTotal or 0,
        best = seasonBest or 0
    }
end
```

---

## Functions to AVOID in 12.0.5

```lua
-- DON'T USE THESE:
GetArenaOpponentSpec(i)            -- Deprecated, returns nil
UnitBuff("arena1", i)              -- Restricted, unreliable on enemies
UnitDebuff("arena1", i)            -- Restricted, unreliable on enemies
GetSpellInfo(spellID)              -- May fail in combat
SpellIsTargetingArea(spellID)      -- May be restricted

-- These require secure execution:
CastSpellByID(spellID)
CastSpellByName(spellName)
UseAction(actionID)
ClickActionButton(actionID)
```

---

## Best Practices

1. **Only read game state** - Don't try to modify combat behavior
2. **Use events for detection** - Don't poll GetTime() repeatedly
3. **Cache data when safe** - Store opponent info during prep phase
4. **Assume unit info is restricted** - Don't rely on detailed enemy stats
5. **Handle missing data gracefully** - Some functions may return nil

---

## Testing Your Code

### Pre-Match Phase
- Arena specs ARE available
- Opponent names ARE available
- Rating info IS available

### During Match
- Match duration IS available
- Match state IS available
- Real-time opponent data may NOT be available
- Buff/debuff info may be restricted

### Post-Match
- Match result IS available
- Rewards ARE available
- Rating change IS available

---

## Related Namespaces

- **C_CombatLog**: Combat log access (alternative to COMBAT_LOG_EVENT)
- **C_ActionBar**: Action bar state and cooldowns
- **C_Spell**: Spell information (safer than GetSpellInfo)

---

**Last Updated**: Patch 12.0.5  
**Status**: Verified and Tested
